import Foundation

public struct Reminder: Equatable, Sendable {
    public var eye: Bool
    public var movement: Bool
    public var strong: Bool
}

public struct SessionSnapshot: Codable, Sendable {
    public var version = 1
    public var savedAt: Date
    public var eye: Double
    public var movement: Double
    public var snoozeRemaining: Double
    public var eyeRepeatRemaining: Double
    public var strongRepeatRemaining: Double
    public var softShown: Bool
}

/// Single deterministic writer. All timestamps belong to the caller's monotonic clock.
public struct BreakEngine: Sendable {
    public private(set) var session = WorkSession()
    public private(set) var policy: BreakPolicy
    public private(set) var time: Double
    public private(set) var idleSeconds: Double = 0
    public private(set) var available = true
    public private(set) var sharing = false
    public private(set) var snoozeUntil: Double = 0
    public private(set) var breakEndsAt: Double?
    public private(set) var wakeEndsAt: Double?
    public private(set) var pauseStartedAt: Double?
    public private(set) var lastReset: String?
    public private(set) var events: [String] = []
    private var breakStartedAt: Double?
    private var unavailableSince: Double?
    private var idleEpoch: Double = 0
    private var recoveryUntil: Double = 0
    private var nextEyeReminder: Double = 0
    private var nextStrongReminder: Double = 0
    private var softShown = false
    private var undoState: UndoState?

    private struct UndoState: Sendable {
        var eye: Double
        var movement: Double
        var resetEye: Bool
        var resetMovement: Bool
        var snooze: Double
        var nextEye: Double
        var nextStrong: Double
        var soft: Bool
    }

    public init(now: Double = 0, policy: BreakPolicy = BreakPolicy()) {
        self.time = now
        self.idleEpoch = now
        self.policy = policy.isValid ? policy : BreakPolicy()
    }

    public var canUndo: Bool { undoState != nil }
    public var breakRemaining: Double { max(0, (breakEndsAt ?? time) - time) }
    public var wakeRemaining: Double? { wakeEndsAt.map { max(0, $0 - time) } }
    public var automaticallySuppressed: Bool {
        !available || sharing || session.timingPaused || session.activeBreak != nil
            || idleSeconds >= policy.idlePauseThreshold || time < snoozeUntil || time < recoveryUntil
    }

    public mutating func updatePolicy(_ value: BreakPolicy) {
        if value.isValid { policy = value }
    }

    /// Sampling interval can vary. idleSeconds is time since the latest input event.
    public mutating func tick(now: Double, idle: Double) {
        guard now.isFinite, now >= time, idle.isFinite, idle >= 0 else { return }
        let start = time
        let delta = now - start
        let lastInput = now - idle
        let inputOccurred = lastInput > start + 0.001
        let previousIdle = idleSeconds
        idleSeconds = min(idle, max(0, now - idleEpoch))

        // A returning user may have been idle beyond the reset threshold between samples.
        if available && !sharing && !session.timingPaused && session.activeBreak == nil,
           inputOccurred && previousIdle + max(0, lastInput - start) >= policy.naturalRestThreshold {
            reset(.movement, reason: "naturalRest")
        }

        // Split at power expiry so only the time actually paused is treated as rest.
        var cursor = start
        if let expiry = wakeEndsAt, expiry <= now {
            integrate(from: cursor, to: max(cursor, expiry), lastInput: lastInput)
            time = max(cursor, expiry)
            stopKeepAwake()
            resumeTiming()
            cursor = time
        }
        // Clip eligible work at the idle threshold, while active breaks use elapsed time.
        if available && !sharing && session.activeBreak == nil && !session.timingPaused {
            if inputOccurred {
                let beforeInput = max(0, min(lastInput - cursor, policy.idlePauseThreshold - previousIdle))
                session.advance(by: beforeInput)
                let afterInput = max(0, min(now - max(cursor, lastInput), policy.idlePauseThreshold))
                session.advance(by: afterInput)
            } else {
                session.advance(by: max(0, min(now - cursor, policy.idlePauseThreshold - previousIdle)))
            }
        } else {
            integrate(from: cursor, to: now, lastInput: lastInput)
        }
        time = now
        // Silence long-return notifications for a short settling period.
        if delta > 0 && inputOccurred && previousIdle >= policy.idlePauseThreshold {
            recoveryUntil = max(recoveryUntil, now + 2)
        }
    }

    private mutating func integrate(from start: Double, to end: Double, lastInput: Double) {
        guard end > start else { return }
        if let finish = breakEndsAt, let began = breakStartedAt, let kind = session.activeBreak {
            let interrupted = available && lastInput > began + 2 && lastInput >= start && lastInput < finish
            let boundary = interrupted ? lastInput : finish
            if available { session.advance(by: max(0, min(end, boundary) - start)) }
            if boundary <= end {
                if interrupted {
                    session.interruptBreak()
                    record("breakInterrupted")
                } else {
                    reset(kind, reason: "breakCompleted")
                }
                breakEndsAt = nil
                breakStartedAt = nil
                if available {
                    session.advance(by: min(max(0, end - max(start, boundary)), policy.idlePauseThreshold))
                }
            }
        } else if available {
            session.advance(by: end - start)
        }
    }

    public mutating func setAvailable(_ value: Bool) {
        guard value != available else { return }
        if !value {
            unavailableSince = time
        } else {
            if let since = unavailableSince, time - since >= policy.naturalRestThreshold,
               session.activeBreak == nil { reset(.movement, reason: "systemRest") }
            unavailableSince = nil
            idleEpoch = time
            idleSeconds = 0
            recoveryUntil = time + 2
        }
        available = value
    }

    public mutating func setSharing(_ value: Bool) {
        guard sharing != value else { return }
        sharing = value
        if !value {
            recoveryUntil = time + policy.sharingRecoveryDelay
            idleEpoch = time
            idleSeconds = 0
        }
        record(value ? "sharingStarted" : "sharingEnded")
    }

    public var reminder: Reminder? {
        guard !automaticallySuppressed, idleSeconds >= 2 else { return nil }
        let eyeDue = session.eyeElapsed >= policy.eyeInterval
        let movementDue = session.movementElapsed >= policy.movementSoftInterval
        let strong = session.movementElapsed >= policy.movementStrongInterval
        let newEye = eyeDue && time >= nextEyeReminder
        let newMovement = movementDue && (strong ? time >= nextStrongReminder : !softShown)
        guard newEye || newMovement else { return nil }
        if !movementDue && eyeDue && policy.movementSoftInterval - session.movementElapsed <= policy.mergeWindow {
            return nil
        }
        return Reminder(eye: eyeDue, movement: movementDue, strong: strong)
    }

    public mutating func markPresented(_ reminder: Reminder) {
        if reminder.eye { nextEyeReminder = time + 600 }
        if reminder.movement {
            softShown = true
            if reminder.strong { nextStrongReminder = time + 600 }
        }
        record(reminder.strong ? "strongReminder" : "gentleReminder")
    }

    public mutating func snooze(seconds: Double) {
        guard seconds.isFinite, seconds > 0 else { return }
        snoozeUntil = time + seconds
        nextEyeReminder = 0
        nextStrongReminder = 0
        softShown = false
        record("snoozed")
    }

    public mutating func waitUntilStrong() {
        snooze(seconds: max(1, policy.movementStrongInterval - session.movementElapsed))
    }

    public mutating func beginBreak(_ kind: BreakKind) {
        guard !session.timingPaused else { return }
        undoState = nil
        session.beginBreak(kind)
        breakStartedAt = time
        breakEndsAt = time + (kind == .eye ? policy.eyeDuration : policy.movementDuration)
        record(kind == .eye ? "eyeStarted" : "movementStarted")
    }

    public mutating func cancelBreak() {
        session.interruptBreak()
        breakStartedAt = nil
        breakEndsAt = nil
        record("breakCancelled")
    }

    public mutating func markRest(_ kind: BreakKind) {
        captureUndo(resetEye: true, resetMovement: kind == .movement)
        reset(kind, reason: "manualRest", preserveUndo: true)
    }

    public mutating func skip(_ kind: BreakKind) {
        // Soft movement suggestions are dismissed, never skipped as a completed cycle.
        if kind == .movement && session.movementElapsed < policy.movementStrongInterval {
            waitUntilStrong()
            return
        }
        captureUndo(resetEye: kind == .eye, resetMovement: kind == .movement)
        session.skip(kind)
        clearReminder(kind)
        record(kind == .eye ? "eyeSkipped" : "movementSkipped")
    }

    public mutating func undo() {
        guard let saved = undoState else { return }
        session.setAccumulation(
            eye: session.eyeElapsed + (saved.resetEye ? saved.eye : 0),
            movement: session.movementElapsed + (saved.resetMovement ? saved.movement : 0))
        snoozeUntil = saved.snooze
        nextEyeReminder = saved.nextEye
        nextStrongReminder = saved.nextStrong
        softShown = saved.soft
        undoState = nil
        record("undo")
    }

    public mutating func startKeepAwake(seconds: Double?) {
        guard seconds == nil || (seconds!.isFinite && seconds! > 0) else { return }
        session.setKeepAwake(true)
        wakeEndsAt = seconds.map { time + $0 }
        record("wakeStarted")
    }

    public mutating func extendKeepAwake(seconds: Double) {
        guard session.keepAwakeRequested, let end = wakeEndsAt, seconds.isFinite, seconds > 0 else { return }
        wakeEndsAt = end + seconds
        record("wakeExtended")
    }

    public mutating func stopKeepAwake() {
        session.stopKeepAwake()
        wakeEndsAt = nil
        record("wakeStopped")
    }

    public mutating func pauseTiming() {
        guard !session.timingPaused else { return }
        cancelBreakIfNeeded()
        pauseStartedAt = time
        session.pauseTiming()
        record("timingPaused")
    }

    public mutating func resumeTiming() {
        guard session.timingPaused else { return }
        if let began = pauseStartedAt, time - began >= policy.naturalRestThreshold {
            reset(.movement, reason: "agentRest")
        }
        pauseStartedAt = nil
        session.resumeTiming()
        idleEpoch = time
        idleSeconds = 0
        recoveryUntil = time + 2
        record("timingResumed")
    }

    public mutating func endAgent() { stopKeepAwake(); resumeTiming() }

    public func snapshot(at date: Date) -> SessionSnapshot {
        SessionSnapshot(savedAt: date, eye: session.eyeElapsed, movement: session.movementElapsed,
                        snoozeRemaining: max(0, snoozeUntil - time),
                        eyeRepeatRemaining: max(0, nextEyeReminder - time),
                        strongRepeatRemaining: max(0, nextStrongReminder - time), softShown: softShown)
    }

    public mutating func restore(_ saved: SessionSnapshot, at date: Date) {
        let values = [saved.eye, saved.movement, saved.snoozeRemaining, saved.eyeRepeatRemaining, saved.strongRepeatRemaining]
        guard saved.version == 1, values.allSatisfy({ $0.isFinite && $0 >= 0 }) else {
            record("snapshotRejected"); return
        }
        let gap = date.timeIntervalSince(saved.savedAt)
        guard gap.isFinite else { record("snapshotRejected"); return }
        if gap >= policy.naturalRestThreshold { record("restartRest"); return }
        session.setAccumulation(eye: saved.eye, movement: saved.movement)
        snoozeUntil = time + max(0, saved.snoozeRemaining - max(0, gap))
        nextEyeReminder = time + max(0, saved.eyeRepeatRemaining - max(0, gap))
        nextStrongReminder = time + max(0, saved.strongRepeatRemaining - max(0, gap))
        softShown = saved.softShown
        recoveryUntil = time + 2
        record(gap < 0 ? "clockChanged" : "restored")
    }

    public mutating func drainEvents() -> [String] {
        let result = events
        events.removeAll()
        return result
    }

    private mutating func captureUndo(resetEye: Bool, resetMovement: Bool) {
        undoState = UndoState(eye: session.eyeElapsed, movement: session.movementElapsed,
                              resetEye: resetEye, resetMovement: resetMovement,
                              snooze: snoozeUntil, nextEye: nextEyeReminder, nextStrong: nextStrongReminder, soft: softShown)
    }

    private mutating func cancelBreakIfNeeded() {
        if session.activeBreak != nil { cancelBreak() }
    }

    private mutating func reset(_ kind: BreakKind, reason: String, preserveUndo: Bool = false) {
        session.confirmRest(kind)
        breakEndsAt = nil
        breakStartedAt = nil
        clearReminder(.eye)
        if kind == .movement { clearReminder(.movement) }
        if !preserveUndo { undoState = nil }
        lastReset = reason
        record(reason)
    }

    private mutating func clearReminder(_ kind: BreakKind) {
        if kind == .eye { nextEyeReminder = 0 } else { nextStrongReminder = 0; softShown = false }
        snoozeUntil = 0
    }

    private mutating func record(_ event: String) {
        events.append(event)
        if events.count > 100 { events.removeFirst(events.count - 100) }
    }
}
