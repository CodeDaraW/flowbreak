import Foundation
import Testing
import IOKit.pwr_mgt
import FlowBreakCore
@testable import FlowBreakMac

@Test func nativeIdleDurationIsReadable() throws {
    let seconds = try #require(SystemActivity.idleSeconds())
    #expect(seconds >= 0 && seconds.isFinite)
}

@Test func actualPowerAssertionCanBeReadAndReleased() throws {
    let controller = WakeController()
    defer { controller.stop() }
    try controller.start(seconds: 30, keepDisplayOn: false)
    let id = try #require(controller.assertionIDs.first)
    #expect(IOPMAssertionCopyProperties(id) != nil)
    controller.stop()
    #expect(!controller.isActive)
    #expect(IOPMAssertionCopyProperties(id) == nil)
}

@Test func invalidReplacementDoesNotReleaseExistingAssertion() throws {
    let controller = WakeController()
    defer { controller.stop() }
    try controller.start(seconds: 30, keepDisplayOn: false)
    let ids = controller.assertionIDs
    #expect(throws: WakeError.self) { try controller.start(seconds: -1, keepDisplayOn: true) }
    #expect(controller.assertionIDs == ids)
}

@Test func repositoryRoundTripAndRetention() throws {
    let path = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: path) }
    let repository = try SessionRepository(directory: path)
    #expect(try repository.loadSnapshot() == nil)
    var engine = BreakEngine()
    engine.tick(now: 20, idle: 0)
    try repository.saveSnapshot(engine.snapshot(at: Date()))
    #expect(try repository.loadSnapshot()?.eye == 20)
    let events = (0..<1100).map { ActivityEvent(date: Date(), kind: "event\($0)") }
    try repository.saveEvents(events)
    let stored = try repository.loadEvents()
    #expect(stored.count == 1000)
    #expect(stored.first?.kind == "event100")
}

@Test func damagedSnapshotIsReportedNotSilentlyOverwritten() throws {
    let path = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: path) }
    let repository = try SessionRepository(directory: path)
    let file = path.appendingPathComponent("session-v1.json")
    try Data("broken".utf8).write(to: file)
    #expect(throws: (any Error).self) { _ = try repository.loadSnapshot() }
    #expect(try String(contentsOf: file, encoding: .utf8) == "broken")
}

@Test func agentSessionOwnsRealPowerAfterHumanTakeover() throws {
    let power = WakeController()
    defer { power.stop() }
    var engine = BreakEngine()
    try power.startSession(engine: &engine, seconds: 30, agent: true, keepDisplayOn: false)
    #expect(engine.session.timingPaused)
    #expect(engine.session.keepAwakeRequested)
    let id = try #require(power.assertionIDs.first)
    engine.tick(now: 5, idle: 0)
    engine.resumeTiming()
    #expect(!engine.session.timingPaused)
    #expect(engine.session.keepAwakeRequested)
    #expect(IOPMAssertionCopyProperties(id) != nil)
    try power.extendSession(engine: &engine, seconds: 30, keepDisplayOn: false)
    #expect(engine.wakeEndsAt == 60)
    #expect(power.isActive)
}
