import Foundation
import CoreGraphics

public enum SystemActivity {
    /// Reads duration only; never installs an event tap or records key content.
    public static func idleSeconds() -> Double? {
        // The session table can lag HID activity (observed in native E2E).
        // Any recent input in either public state table means the Mac is active.
        let event = CGEventType(rawValue: UInt32.max)!
        let readings = [
            CGEventSource.secondsSinceLastEventType(.hidSystemState, eventType: event),
            CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: event)
        ]
        return readings.filter { $0.isFinite && $0 >= 0 }.min()
    }
}
