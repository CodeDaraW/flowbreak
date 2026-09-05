import SwiftUI
import AppKit

@main
struct FlowBreakApp: App {
    @StateObject private var settings = SettingsStore()

    var body: some Scene {
        MenuBarExtra("FlowBreak", systemImage: "leaf") {
            VStack(alignment: .leading, spacing: 14) {
                Text("FlowBreak").font(.title2.bold())
                Text(settings.text("bootstrap.notice"))
                    .font(.callout).foregroundStyle(.secondary)
                Divider()
                Label(settings.text("eye.title"), systemImage: "eye")
                Text(settings.text("eye.summary")).font(.caption)
                Label(settings.text("movement.title"), systemImage: "figure.walk")
                Text(settings.text("movement.summary")).font(.caption)
                Divider()
                SettingsLink { Text(settings.text("settings.title")) }
                Button(settings.text("quit")) { NSApplication.shared.terminate(nil) }
            }
            .padding(20)
            .frame(width: 300)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView(settings: settings)
        }
    }
}
