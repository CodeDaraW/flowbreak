import Foundation
import Testing
@testable import FlowBreakCore

private func work(_ engine: inout BreakEngine, _ seconds: Int) {
    for _ in 0..<seconds { engine.tick(now: engine.time + 1, idle: 0) }
}

@Test func mergesAtFortyMinutesAndEscalatesAtSixty() throws {
    var engine = BreakEngine()
    work(&engine, 2398)
    engine.tick(now: 2400, idle: 2)
    let reminder = try #require(engine.reminder)
    #expect(reminder.eye && reminder.movement && !reminder.strong)
    engine.markPresented(reminder)
    work(&engine, 1198)
    engine.tick(now: 3600, idle: 2)
    #expect(engine.reminder?.strong == true)
}

@Test func snoozeProtectsWholeIntervalAcrossStrongThreshold() throws {
    var engine = BreakEngine()
    work(&engine, 3500)
    engine.snooze(seconds: 300)
    work(&engine, 298)
    engine.tick(now: 3800, idle: 2)
    #expect(engine.reminder?.strong == true)
    engine.snooze(seconds: 300)
    work(&engine, 100)
    #expect(engine.reminder == nil)
    #expect(engine.session.movementElapsed == 3900)
}

@Test func nearMovementEyeReminderWaitsForMerge() {
    var engine = BreakEngine()
    work(&engine, 1200)
    engine.markRest(.eye)
    work(&engine, 1000)
    // Move the eye deadline earlier through a valid user policy.
    var policy = BreakPolicy(); policy.eyeInterval = 1000
    engine.updatePolicy(policy)
    engine.tick(now: 2202, idle: 2)
    #expect(engine.reminder?.eye == true) // 198 seconds is outside 180-second merge window.
    work(&engine, 20)
    engine.tick(now: 2224, idle: 2)
    #expect(engine.reminder == nil)
}

@Test func eyeCountdownOnlyFreezesEyeAndCompletes() {
    var engine = BreakEngine()
    work(&engine, 1200)
    engine.beginBreak(.eye)
    engine.tick(now: 1220, idle: 20)
    #expect(engine.session.eyeElapsed == 0)
    #expect(engine.session.movementElapsed == 1220)
    #expect(engine.session.activeBreak == nil)
}

@Test func actualInputInterruptsBeforeCompletion() {
    var engine = BreakEngine()
    work(&engine, 1200)
    engine.beginBreak(.eye)
    engine.tick(now: 1210, idle: 1) // Input at t=1209.
    #expect(engine.session.activeBreak == nil)
    #expect(engine.session.eyeElapsed == 1201)
    #expect(engine.session.movementElapsed == 1210)
}

@Test func inputAfterCountdownStillCountsCompletedBreak() {
    var engine = BreakEngine()
    work(&engine, 1200)
    engine.beginBreak(.eye)
    engine.tick(now: 1222, idle: 1)
    #expect(engine.session.eyeElapsed == 2)
    #expect(engine.session.activeBreak == nil)
}

@Test func idlePausesAndLongIdleResetsOnReturn() {
    var engine = BreakEngine()
    work(&engine, 1000)
    engine.tick(now: 1120, idle: 120)
    engine.tick(now: 1300, idle: 300)
    #expect(engine.session.eyeElapsed == 1120)
    engine.tick(now: 1301, idle: 0)
    #expect(engine.session.eyeElapsed <= 1)
    #expect(engine.lastReset == "naturalRest")
}

@Test func shortIdlePreservesAccumulation() {
    var engine = BreakEngine()
    work(&engine, 1000)
    engine.tick(now: 1180, idle: 180)
    engine.tick(now: 1181, idle: 0)
    #expect(engine.session.eyeElapsed == 1120)
}

@Test func sharingCountsIdleButNeverDisplays() {
    var engine = BreakEngine()
    engine.setSharing(true)
    engine.tick(now: 4000, idle: 4000)
    #expect(engine.session.movementElapsed == 4000)
    #expect(engine.reminder == nil)
    engine.setSharing(false)
    work(&engine, 18)
    engine.tick(now: 4020, idle: 2)
    #expect(engine.reminder?.strong == true)
}

@Test func shortSleepPreservesButLongSleepResets() {
    var engine = BreakEngine()
    work(&engine, 1000)
    engine.setAvailable(false)
    engine.tick(now: 1010, idle: 10)
    engine.setAvailable(true)
    #expect(engine.session.eyeElapsed == 1000)
    engine.setAvailable(false)
    engine.tick(now: 1400, idle: 400)
    engine.setAvailable(true)
    #expect(engine.session.eyeElapsed == 0)
}

@Test func movementCountdownCanCompleteDuringSleep() {
    var engine = BreakEngine()
    work(&engine, 1000)
    engine.beginBreak(.movement)
    engine.setAvailable(false)
    engine.tick(now: 1200, idle: 200)
    engine.setAvailable(true)
    #expect(engine.session.eyeElapsed == 0)
    #expect(engine.session.activeBreak == nil)
}

@Test func agentTakeoverLeavesWakeAndResetsOnlyAfterLongPause() {
    var engine = BreakEngine()
    work(&engine, 1000)
    engine.startKeepAwake(seconds: 3600)
    engine.pauseTiming()
    engine.tick(now: 1010, idle: 0)
    engine.resumeTiming()
    #expect(engine.session.eyeElapsed == 1000)
    #expect(engine.session.keepAwakeRequested)
    engine.pauseTiming()
    engine.tick(now: 1500, idle: 0)
    engine.resumeTiming()
    #expect(engine.session.eyeElapsed == 0)
    #expect(engine.session.keepAwakeRequested)
}

@Test func agentExpiresWithoutCountingPausedInterval() {
    var engine = BreakEngine()
    work(&engine, 1000)
    engine.startKeepAwake(seconds: 600)
    engine.pauseTiming()
    engine.tick(now: 1601, idle: 0)
    #expect(!engine.session.keepAwakeRequested)
    #expect(!engine.session.timingPaused)
    #expect(engine.session.eyeElapsed <= 1)
}

@Test func stopPowerDoesNotImplicitlyResumeTiming() {
    var engine = BreakEngine()
    engine.startKeepAwake(seconds: nil)
    engine.pauseTiming()
    engine.stopKeepAwake()
    #expect(engine.session.timingPaused)
    engine.endAgent()
    #expect(!engine.session.timingPaused)
}

@Test func undoRestKeepsWorkSinceCorrection() {
    var engine = BreakEngine()
    work(&engine, 1000)
    engine.markRest(.movement)
    work(&engine, 5)
    engine.undo()
    #expect(engine.session.eyeElapsed == 1005)
    #expect(engine.session.movementElapsed == 1005)
    #expect(!engine.canUndo)
}

@Test func skipMovementNeverResetsEye() {
    var engine = BreakEngine()
    work(&engine, 3600)
    engine.skip(.movement)
    #expect(engine.session.eyeElapsed == 3600)
    #expect(engine.session.movementElapsed == 0)
    engine.undo()
    #expect(engine.session.movementElapsed == 3600)
}

@Test func explicitSoftSkipRestartsMovementOnly() {
    var engine = BreakEngine()
    work(&engine, 2400)
    engine.skip(.movement)
    #expect(engine.session.movementElapsed == 0)
    #expect(engine.session.eyeElapsed == 2400)
    #expect(engine.events.last == "movementSkipped")
}

@Test func snapshotRoundTripAndClockRollback() throws {
    var engine = BreakEngine()
    work(&engine, 1200)
    engine.snooze(seconds: 300)
    let date = Date(timeIntervalSince1970: 1000)
    let encoded = try JSONEncoder().encode(engine.snapshot(at: date))
    let saved = try JSONDecoder().decode(SessionSnapshot.self, from: encoded)
    var restored = BreakEngine(now: 9000)
    restored.restore(saved, at: date.addingTimeInterval(10))
    #expect(restored.session.eyeElapsed == 1200)
    #expect(restored.snoozeUntil == 9290)
    var late = BreakEngine()
    late.restore(saved, at: date.addingTimeInterval(301))
    #expect(late.session.eyeElapsed == 1200)
    var rollback = BreakEngine()
    rollback.restore(saved, at: date.addingTimeInterval(-10))
    #expect(rollback.session.eyeElapsed == 1200)
    #expect(rollback.events.last == "clockChanged")
}

@Test func eyeCompletionDoesNotBreakMovementSnooze() {
    var engine = BreakEngine()
    work(&engine, 3600)
    engine.snooze(seconds: 300)
    engine.beginBreak(.eye)
    engine.tick(now: 3620, idle: 20)
    #expect(engine.session.eyeElapsed == 0)
    #expect(engine.snoozeUntil == 3900)
    #expect(engine.reminder == nil)
}

@Test func standalonePowerExpiryDoesNotCountIdleTime() {
    var engine = BreakEngine()
    engine.startKeepAwake(seconds: 600)
    engine.tick(now: 601, idle: 601)
    #expect(!engine.session.keepAwakeRequested)
    #expect(engine.session.eyeElapsed == 120)
}

@Test func checkpointAfterLongIdleCannotRestoreOldDebt() {
    var engine = BreakEngine()
    work(&engine, 3600)
    engine.tick(now: 4000, idle: 400)
    let date = Date()
    let saved = engine.snapshot(at: date)
    var restored = BreakEngine()
    restored.restore(saved, at: date.addingTimeInterval(1))
    #expect(restored.session.eyeElapsed == 0)
    #expect(restored.session.movementElapsed == 0)
}

@Test func checkpointDuringLongPauseOrLockRestoresFreshSession() {
    for agent in [true, false] {
        var engine = BreakEngine()
        work(&engine, 3600)
        if agent { engine.pauseTiming() } else { engine.setAvailable(false) }
        engine.tick(now: 4000, idle: 0)
        let date = Date()
        var restored = BreakEngine()
        restored.restore(engine.snapshot(at: date), at: date.addingTimeInterval(1))
        #expect(restored.session.eyeElapsed == 0)
        #expect(!restored.session.timingPaused)
        #expect(!restored.session.keepAwakeRequested)
    }
}

@Test func waitingForStrongUsesWorkTimeNotWallTime() {
    var engine = BreakEngine()
    work(&engine, 2400)
    engine.waitUntilStrong()
    engine.tick(now: 2580, idle: 180) // Only 120 seconds count.
    work(&engine, 1018)
    engine.tick(now: 3600, idle: 2)
    #expect(engine.session.movementElapsed < 3600)
    #expect(engine.reminder?.eye == true)
    #expect(engine.reminder?.movement == false)
    #expect(engine.isWaitingForStrong)
    work(&engine, 60)
    engine.tick(now: 3662, idle: 2)
    #expect(engine.reminder?.strong == true)
}

@Test func waitingForMovementDoesNotSilenceDueEyes() throws {
    var engine = BreakEngine()
    work(&engine, 2400)
    engine.tick(now: 2402, idle: 2)
    engine.markPresented(try #require(engine.reminder))
    engine.waitUntilStrong()
    #expect(engine.snoozeUntil == 0)
    #expect(engine.reminder?.eye == true)
    #expect(engine.reminder?.movement == false)
    engine.snooze(seconds: 180)
    #expect(engine.reminder == nil)
}

@Test func dismissedEyeReminderWaitsForExplicitSnooze() throws {
    var engine = BreakEngine()
    work(&engine, 1200)
    engine.tick(now: 1202, idle: 2)
    engine.markPresented(try #require(engine.reminder))
    work(&engine, 610)
    engine.tick(now: 1814, idle: 2)
    #expect(engine.reminder == nil)
    engine.snooze(seconds: 3)
    engine.tick(now: 1817, idle: 5)
    #expect(engine.reminder?.eye == true)
}

@Test func extendedMovementRestDoesNotCompleteAtOldDeadline() {
    var engine = BreakEngine()
    work(&engine, 600)
    engine.beginBreak(.movement)
    engine.extendBreak(seconds: 60)
    engine.tick(now: 780, idle: 180)
    #expect(engine.session.activeBreak == .movement)
    #expect(engine.breakRemaining == 60)
    engine.tick(now: 840, idle: 240)
    #expect(engine.session.activeBreak == nil)
    #expect(engine.session.eyeElapsed == 0)
}

@Test func configurableStrongReminderIntervalIsRespected() throws {
    var engine = BreakEngine()
    engine.strongRepeatInterval = 120
    work(&engine, 3600)
    engine.tick(now: 3602, idle: 2)
    engine.markPresented(try #require(engine.reminder))
    work(&engine, 116)
    engine.tick(now: 3720, idle: 2)
    #expect(engine.reminder == nil)
    engine.tick(now: 3722, idle: 4)
    #expect(engine.reminder?.strong == true)
}

@Test func pointerMotionDoesNotInterruptButDeliberateInputDoes() {
    var engine = BreakEngine()
    work(&engine, 600)
    engine.beginBreak(.eye)
    engine.tick(now: 605, idle: 0, restInputIdle: 5)
    #expect(engine.session.activeBreak == .eye)
    engine.tick(now: 610, idle: 0, restInputIdle: 0)
    #expect(engine.session.activeBreak == nil)
    #expect(engine.session.eyeElapsed == 600)
    #expect(engine.session.movementElapsed == 610)
}

@Test func manualCorrectionUndoExpiresAtTenSeconds() {
    var engine = BreakEngine()
    work(&engine, 100)
    engine.markRest(.movement)
    work(&engine, 10)
    #expect(!engine.canUndo)
    engine.undo()
    #expect(engine.session.eyeElapsed == 10)
}

@Test func combinedSkipHasOneUndoSnapshot() {
    var engine = BreakEngine()
    work(&engine, 100)
    engine.skipBoth()
    work(&engine, 5)
    engine.undo()
    #expect(engine.session.eyeElapsed == 105)
    #expect(engine.session.movementElapsed == 105)
}

@Test func eyeCorrectionClearsOnlyEyeOwnedSnooze() {
    var engine = BreakEngine()
    work(&engine, 1200)
    engine.snooze(seconds: 180, kind: .eye)
    engine.snooze(seconds: 300, kind: .movement)
    engine.markRest(.eye)
    #expect(engine.eyeSnoozeUntil == 0)
    #expect(engine.movementSnoozeUntil == 1500)
    #expect(engine.automaticallySuppressed)
    #expect(engine.undoEvent == "eyeMarked")
    engine.undo()
    #expect(engine.eyeSnoozeUntil == 1380)
    #expect(engine.movementSnoozeUntil == 1500)
}

@Test func startingRestClearsCoveredSnoozeOwnership() {
    var engine = BreakEngine()
    engine.snooze(seconds: 300)
    engine.beginBreak(.eye)
    #expect(engine.eyeSnoozeUntil == 0)
    #expect(engine.movementSnoozeUntil == 300)
    engine.cancelBreak()
    engine.beginBreak(.movement)
    #expect(engine.snoozeUntil == 0)
}

@Test func singleEyeSnoozeStillSuppressesStrongMovement() {
    var engine = BreakEngine()
    work(&engine, 3480)
    engine.snooze(seconds: 300, kind: .eye)
    work(&engine, 120)
    engine.tick(now: 3602, idle: 2)
    #expect(engine.reminder == nil)
    #expect(engine.movementSnoozeUntil == 0)
    work(&engine, 178)
    engine.tick(now: 3782, idle: 2)
    #expect(engine.reminder == Reminder(eye: true, movement: true, strong: true))
}

@Test func snoozeOwnershipSurvivesSnapshotAndLegacyStillDecodes() throws {
    var engine = BreakEngine()
    engine.snooze(seconds: 180, kind: .eye)
    let date = Date(timeIntervalSince1970: 100)
    let encoded = try JSONEncoder().encode(engine.snapshot(at: date))
    let decoded = try JSONDecoder().decode(SessionSnapshot.self, from: encoded)
    var restored = BreakEngine(now: 500)
    restored.restore(decoded, at: date.addingTimeInterval(10))
    #expect(restored.eyeSnoozeUntil == 670)
    #expect(restored.movementSnoozeUntil == 500)
    restored.markRest(.eye)
    restored.tick(now: 502, idle: 2)
    #expect(!restored.automaticallySuppressed)
    #expect(restored.snoozeUntil <= restored.time)
    var object = try #require(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
    object.removeValue(forKey: "eyeSnoozeRemaining")
    object.removeValue(forKey: "movementSnoozeRemaining")
    let legacy = try JSONDecoder().decode(SessionSnapshot.self, from: JSONSerialization.data(withJSONObject: object))
    var oldRestored = BreakEngine(now: 500)
    oldRestored.restore(legacy, at: date)
    #expect(oldRestored.eyeSnoozeUntil == 680)
    #expect(oldRestored.movementSnoozeUntil == 680)
}

@Test func reminderEstimateHonorsMergeAndSnooze() {
    var engine = BreakEngine()
    #expect(engine.nextReminderEstimate == ReminderEstimate(seconds: 1200, eye: true, movement: false))
    work(&engine, 2300)
    #expect(engine.nextReminderEstimate == ReminderEstimate(seconds: 100, eye: true, movement: true))
    engine.snooze(seconds: 300, kind: .eye)
    #expect(engine.nextReminderEstimate == ReminderEstimate(seconds: 300, eye: true, movement: true))
}

@Test func dismissedEyeEstimateMovesToMovementAndHidesWhilePaused() throws {
    var engine = BreakEngine()
    work(&engine, 1200)
    engine.tick(now: 1202, idle: 2)
    engine.markPresented(try #require(engine.reminder))
    #expect(engine.nextReminderEstimate?.seconds == 1198)
    engine.pauseTiming()
    #expect(engine.nextReminderEstimate == nil)
    engine.resumeTiming()
    engine.setSharing(true)
    #expect(engine.nextReminderEstimate == nil)
}

@Test func extendedBreakProgressUsesExtendedTotal() {
    var engine = BreakEngine()
    engine.beginBreak(.movement)
    engine.tick(now: 30, idle: 30)
    engine.extendBreak(seconds: 120)
    #expect(engine.breakDuration == 300)
    #expect(engine.breakRemaining == 270)
}

@Test func sharingEndReconsidersPreviouslyPresentedDueReminder() throws {
    var engine = BreakEngine()
    work(&engine, 3600)
    engine.tick(now: 3602, idle: 2)
    engine.markPresented(try #require(engine.reminder))
    engine.setSharing(true)
    engine.tick(now: 3612, idle: 12)
    engine.setSharing(false)
    engine.tick(now: 3631, idle: 19)
    #expect(engine.reminder == nil)
    engine.tick(now: 3632, idle: 20)
    #expect(engine.reminder == Reminder(eye: true, movement: true, strong: true))
    engine.markPresented(try #require(engine.reminder))
    engine.tick(now: 3633, idle: 21)
    #expect(engine.reminder == nil)
}

@Test func sharingEndRearmDoesNotEraseAnExplicitSnooze() {
    var engine = BreakEngine()
    work(&engine, 3600)
    engine.snooze(seconds: 300, kind: .eye)
    engine.setSharing(true)
    engine.tick(now: 3610, idle: 10)
    engine.setSharing(false)
    engine.tick(now: 3630, idle: 20)
    #expect(engine.reminder == nil)
    #expect(engine.eyeSnoozeUntil == 3900)
}
