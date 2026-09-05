import Foundation
import IOKit.pwr_mgt
import FlowBreakCore

public enum WakeError: Error { case assertionFailed(Int32), invalidDuration }

/// Owned by one coordinator. Assertions die with this process, never a detached helper.
public final class WakeController {
    public private(set) var assertionIDs: [IOPMAssertionID] = []
    public var isActive: Bool { !assertionIDs.isEmpty }

    public init() {}

    public func start(seconds: Double?, keepDisplayOn: Bool) throws {
        if let seconds, !seconds.isFinite || seconds <= 0 { throw WakeError.invalidDuration }
        var acquired: [IOPMAssertionID] = []
        let types = keepDisplayOn
            ? [kIOPMAssertionTypePreventUserIdleSystemSleep, kIOPMAssertionTypePreventUserIdleDisplaySleep]
            : [kIOPMAssertionTypePreventUserIdleSystemSleep]
        do {
            for type in types {
                var properties: [String: Any] = [
                    kIOPMAssertionTypeKey: type,
                    kIOPMAssertionNameKey: "FlowBreak keep awake",
                    kIOPMAssertionLevelKey: kIOPMAssertionLevelOn
                ]
                if let seconds {
                    properties[kIOPMAssertionTimeoutKey] = seconds
                    properties[kIOPMAssertionTimeoutActionKey] = kIOPMAssertionTimeoutActionRelease
                }
                var identifier: IOPMAssertionID = 0
                let result = IOPMAssertionCreateWithProperties(properties as CFDictionary, &identifier)
                guard result == kIOReturnSuccess else { throw WakeError.assertionFailed(result) }
                acquired.append(identifier)
            }
        } catch {
            acquired.forEach { _ = IOPMAssertionRelease($0) }
            throw error
        }
        stop()
        assertionIDs = acquired
    }

    /// Commit system and core intent together, after the caller has sampled elapsed time.
    public func startSession(engine: inout BreakEngine, seconds: Double?, agent: Bool, keepDisplayOn: Bool) throws {
        try start(seconds: seconds, keepDisplayOn: keepDisplayOn)
        engine.startKeepAwake(seconds: seconds)
        if agent { engine.pauseTiming() }
    }

    public func extendSession(engine: inout BreakEngine, seconds: Double, keepDisplayOn: Bool) throws {
        guard let remaining = engine.wakeRemaining else { return }
        try start(seconds: remaining + seconds, keepDisplayOn: keepDisplayOn)
        engine.extendKeepAwake(seconds: seconds)
    }

    public func stop() {
        assertionIDs.forEach { _ = IOPMAssertionRelease($0) }
        assertionIDs.removeAll()
    }

    deinit { assertionIDs.forEach { _ = IOPMAssertionRelease($0) } }
}
