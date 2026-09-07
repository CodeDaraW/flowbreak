import SwiftUI
import ServiceManagement

/// System registration is authoritative, including changes made outside this app.
struct LoginItemView: View {
    @ObservedObject var settings: SettingsStore
    @State private var status = SMAppService.mainApp.status
    @State private var failed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Toggle(settings.text("login.title"), isOn: Binding(
                get: { status == .enabled || status == .requiresApproval },
                set: { value in update(value) }
            )).toggleStyle(.switch).controlSize(.small)
            Text(settings.text("login.help")).font(.caption).foregroundStyle(.secondary)
            if status == .requiresApproval {
                Text(settings.text("login.approval")).font(.caption).foregroundStyle(.orange)
                Button(settings.text("login.settings")) { SMAppService.openSystemSettingsLoginItems() }
            }
            if failed {
                Text(settings.text("login.error")).font(.caption).foregroundStyle(.red)
            }
        }
        .onAppear { status = SMAppService.mainApp.status }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            status = SMAppService.mainApp.status
        }
    }

    private func update(_ enabled: Bool) {
        failed = false
        do {
            if enabled { try SMAppService.mainApp.register() }
            else { try SMAppService.mainApp.unregister() }
        } catch { failed = true }
        status = SMAppService.mainApp.status
    }
}
