import SwiftUI

@main
struct FlowBreakApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate

    var body: some Scene {
        MenuBarExtra {
            DashboardView(model: delegate.model)
        } label: {
            MenuBarIcon(model: delegate.model)
        }
        .menuBarExtraStyle(.window)
        Settings { SettingsView(settings: delegate.model.settings, model: delegate.model) }
    }
}

private struct MenuBarIcon: View {
    @ObservedObject var model: AppModel
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: model.symbol)
            if !model.engine.sharing {
                if model.engine.session.activeBreak != nil {
                    Text(timeString(model.engine.breakRemaining)).monospacedDigit()
                } else if let remaining = model.engine.wakeRemaining {
                    Text(timeString(remaining)).monospacedDigit()
                }
            }
        }.accessibilityLabel("FlowBreak")
    }
}
