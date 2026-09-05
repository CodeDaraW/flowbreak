import Testing
@testable import FlowBreakCore

@Test func eyeRestDoesNotEraseSittingTime() {
    var session = WorkSession()
    session.advance(by: 1200)
    session.beginBreak(.eye)
    session.advance(by: 20)
    session.confirmRest(.eye)
    #expect(session.eyeElapsed == 0)
    #expect(session.movementElapsed == 1220)
}

@Test func interruptedEyeRestPreservesAccumulation() {
    var session = WorkSession()
    session.advance(by: 1200)
    session.beginBreak(.eye)
    session.advance(by: 10)
    session.interruptBreak()
    session.advance(by: 5)
    #expect(session.eyeElapsed == 1205)
    #expect(session.movementElapsed == 1215)
}

@Test func completedMovementRestResetsBoth() {
    var session = WorkSession()
    session.advance(by: 3600)
    session.beginBreak(.movement)
    session.advance(by: 180)
    #expect(session.movementElapsed == 3600)
    session.confirmRest(.movement)
    #expect(session.eyeElapsed == 0)
    #expect(session.movementElapsed == 0)
}

@Test func humanTakeoverKeepsPowerRequest() {
    var session = WorkSession()
    session.advance(by: 100)
    session.startAgentMode()
    session.advance(by: 600)
    #expect(session.eyeElapsed == 100)
    session.resumeTiming()
    session.advance(by: 10)
    #expect(session.eyeElapsed == 110)
    #expect(session.keepAwakeRequested)
    #expect(!session.timingPaused)
}

@Test func thresholdsAreInclusive() {
    var session = WorkSession()
    let policy = BreakPolicy()
    session.advance(by: 2399)
    #expect(session.movementStage(policy: policy) == .working)
    session.advance(by: 1)
    #expect(session.movementStage(policy: policy) == .suggested)
    session.advance(by: 1200)
    #expect(session.movementStage(policy: policy) == .overdue)
}

@Test func invalidElapsedTimeCannotCorruptSession() {
    var session = WorkSession()
    for delta in [-1.0, Double.infinity, Double.nan] { session.advance(by: delta) }
    #expect(session.eyeElapsed == 0)
}

@Test func policyRejectsConflictingThresholds() {
    var policy = BreakPolicy()
    #expect(policy.isValid)
    policy.naturalRestThreshold = policy.idlePauseThreshold
    #expect(!policy.isValid)
}
