import Foundation
import CoreGraphics

public enum SystemActivity {
    /// Reads duration only; never installs an event tap or records key content.
    public static func idleSeconds() -> Double? {
        let value = CGEventSource.secondsSinceLastEventType(
            .combinedSessionState, eventType: CGEventType(rawValue: UInt32.max)!)
        return value.isFinite && value >= 0 ? value : nil
    }
}
