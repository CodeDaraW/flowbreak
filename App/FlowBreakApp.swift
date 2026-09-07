import SwiftUI

@main
struct FlowBreakApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate

    var body: some Scene {
        Settings { SettingsView(settings: delegate.model.settings, model: delegate.model) }
    }
}
