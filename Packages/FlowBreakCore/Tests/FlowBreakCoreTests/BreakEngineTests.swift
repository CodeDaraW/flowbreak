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
    work(&engine, 50)
    engine.undo()
    #expect(engine.session.eyeElapsed == 1050)
    #expect(engine.session.movementElapsed == 1050)
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

@Test func softSkipWaitsUntilStrongInsteadOfResetting() {
    var engine = BreakEngine()
    work(&engine, 2400)
    engine.skip(.movement)
    #expect(engine.session.movementElapsed == 2400)
    #expect(engine.snoozeUntil == 3600)
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
    #expect(late.session.eyeElapsed == 0)
    var rollback = BreakEngine()
    rollback.restore(saved, at: date.addingTimeInterval(-10))
    #expect(rollback.session.eyeElapsed == 1200)
    #expect(rollback.events.last == "clockChanged")
}
