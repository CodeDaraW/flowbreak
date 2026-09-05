import SwiftUI
import FlowBreakCore

struct SettingsView: View {
    @ObservedObject var settings: SettingsStore

    var body: some View {
        Form {
            Picker(settings.text("language"), selection: $settings.language) {
                Text(settings.text("language.system")).tag("system")
                Text("简体中文").tag("zh-Hans")
                Text("English").tag("en")
            }
            Section(settings.text("settings.timing")) {
                duration("eye.interval", \.eyeInterval)
                duration("eye.duration", \.eyeDuration)
                duration("movement.soft", \.movementSoftInterval)
                duration("movement.strong", \.movementStrongInterval)
                duration("movement.duration", \.movementDuration)
                duration("idle.pause", \.idlePauseThreshold)
                duration("idle.reset", \.naturalRestThreshold)
                duration("merge.window", \.mergeWindow)
                duration("sharing.delay", \.sharingRecoveryDelay)
            }
            if !settings.policy.isValid {
                Text(settings.text("settings.invalid")).foregroundStyle(.red)
            }
            if settings.loadFailed {
                Text(settings.text("settings.recovery")).foregroundStyle(.orange)
            }
            Text(settings.text("sharing.unavailable")).foregroundStyle(.secondary)
            Text(settings.text("bootstrap.notice")).font(.caption).foregroundStyle(.secondary)
            Button(settings.text("settings.reset")) { settings.reset() }
        }
        .formStyle(.grouped)
        .frame(width: 540, height: 670)
    }

    private func duration(_ key: String, _ path: WritableKeyPath<BreakPolicy, Double>) -> some View {
        TextField(settings.text(key), value: Binding(
            get: { settings.policy[keyPath: path] },
            set: { settings.policy[keyPath: path] = $0 }
        ), format: .number)
    }
}
