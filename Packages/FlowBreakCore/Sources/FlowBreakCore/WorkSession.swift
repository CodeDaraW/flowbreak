import Foundation

public enum BreakKind: String, Codable, Sendable { case eye, movement }
public enum MovementStage: Sendable { case working, suggested, overdue }

/// A deterministic accumulator, not the full reminder scheduler.
/// Its caller supplies eligible elapsed time after idle/sleep classification.
public struct WorkSession: Equatable, Sendable {
    public private(set) var eyeElapsed: TimeInterval = 0
    public private(set) var movementElapsed: TimeInterval = 0
    public private(set) var activeBreak: BreakKind?
    public private(set) var timingPaused = false
    // Desired power state only. The future IOKit adapter owns actual assertions.
    public private(set) var keepAwakeRequested = false

    public init() {}

    public mutating func advance(by seconds: TimeInterval) {
        guard seconds.isFinite, seconds > 0, !timingPaused else { return }
        if activeBreak == nil { eyeElapsed += seconds }
        if activeBreak != .movement { movementElapsed += seconds }
    }

    public mutating func beginBreak(_ kind: BreakKind) { activeBreak = kind }
    public mutating func interruptBreak() { activeBreak = nil }

    /// Invoked only after duration/input validation, or explicit manual confirmation.
    public mutating func confirmRest(_ kind: BreakKind) {
        eyeElapsed = 0
        if kind == .movement { movementElapsed = 0 }
        activeBreak = nil
    }

    public mutating func startAgentMode() {
        timingPaused = true
        keepAwakeRequested = true
    }

    public mutating func resumeTiming() { timingPaused = false }
    public mutating func stopKeepAwake() { keepAwakeRequested = false }

    public func movementStage(policy: BreakPolicy) -> MovementStage {
        if movementElapsed >= policy.movementStrongInterval { return .overdue }
        if movementElapsed >= policy.movementSoftInterval { return .suggested }
        return .working
    }
}
