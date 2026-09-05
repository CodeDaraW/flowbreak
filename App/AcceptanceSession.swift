import Foundation

/// Debug-only data isolation and windowed entry for native accessibility runners.
/// It does not replace the scheduler, system adapters, views or user actions.
enum AcceptanceSession {
    static var directory: URL? {
        #if DEBUG
        let args = ProcessInfo.processInfo.arguments
        if let index = args.firstIndex(of: "--e2e-workspace"), index + 1 < args.count {
            return URL(fileURLWithPath: args[index + 1], isDirectory: true)
        }
        #endif
        return nil
    }
    static var defaults: UserDefaults {
        if let directory {
            return UserDefaults(suiteName: "org.flowbreak.e2e." + directory.lastPathComponent)!
        }
        return .standard
    }
}
