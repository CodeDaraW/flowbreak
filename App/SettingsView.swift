import SwiftUI
import FlowBreakCore

struct SettingsView: View {
    @ObservedObject var settings: SettingsStore
    @ObservedObject var model: AppModel
    @State private var selected = "settings.general"
    private let sections = ["settings.general", "settings.timer", "settings.reminders", "settings.displays", "wake.title", "history.title"]
    private let symbols = ["gearshape", "timer", "bell", "display", "cup.and.saucer", "clock.arrow.circlepath"]
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Label("FlowBreak", systemImage: "leaf.fill").font(.headline).padding(.bottom, 20)
                ForEach(Array(sections.enumerated()), id: \.element) { index, key in
                    Button { selected = key } label: {
                        Label(settings.text(key), systemImage: symbols[index])
                            .font(.system(size: 12, weight: .medium))
                            .frame(maxWidth: .infinity, alignment: .leading).padding(10)
                            .background(selected == key ? Color.accentColor.opacity(0.12) : .clear, in: RoundedRectangle(cornerRadius: 8))
                            .foregroundStyle(selected == key ? Color.accentColor : .primary)
                    }.buttonStyle(.plain)
                }
                Spacer()
            }.padding(16).frame(width: 176).background(.quaternary.opacity(0.2))
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(settings.text(selected)).font(.system(size: 24, weight: .bold))
                    Text(settings.text("settings.saved")).font(.caption).foregroundStyle(.secondary)
                    content
                    if !settings.policy.isValid { Text(settings.text("settings.invalid")).font(.caption).foregroundStyle(.red) }
                    if settings.loadFailed { Text(settings.text("settings.recovery")).font(.caption).foregroundStyle(.orange) }
                }.padding(26).frame(maxWidth: .infinity, alignment: .leading)
            }
        }.frame(width: 760, height: 640).background(FlowStyle.canvas).preferredColorScheme(settings.colorScheme)
    }

    @ViewBuilder private var content: some View {
        switch selected {
        case "settings.general":
            FlowCard {
                Picker(settings.text("language"), selection: $settings.language) {
                    Text(settings.text("language.system")).tag("system")
                    Text("简体中文").tag("zh-Hans")
                    Text("English").tag("en")
                }
            }
            FlowCard {
                Picker(settings.text("appearance"), selection: $settings.appearance) {
                    ForEach(["system", "light", "dark"], id: \.self) { mode in Text(settings.text("appearance." + mode)).tag(mode) }
                }
            }
            Text(settings.text("settings.privacy")).font(.callout).foregroundStyle(.secondary)
            Button(settings.text("settings.reset")) { settings.reset() }
        case "settings.timer":
            FlowCard {
                VStack(spacing: 18) {
                    duration("eye.interval", \.eyeInterval, minutes: true)
                    duration("eye.duration", \.eyeDuration)
                    Divider()
                    duration("movement.soft", \.movementSoftInterval, minutes: true)
                    duration("movement.strong", \.movementStrongInterval, minutes: true)
                    duration("movement.duration", \.movementDuration, minutes: true)
                }
            }
            FlowCard {
                VStack(spacing: 18) {
                    duration("idle.pause", \.idlePauseThreshold)
                    duration("idle.reset", \.naturalRestThreshold, minutes: true)
                    Text(settings.text("idle.approximation")).font(.caption).foregroundStyle(.secondary)
                }
            }
        case "settings.reminders":
            FlowCard {
                VStack(spacing: 18) {
                    duration("merge.window", \.mergeWindow)
                    duration("sharing.delay", \.sharingRecoveryDelay)
                }
            }
            FlowCard {
                VStack(alignment: .leading, spacing: 14) {
                    Toggle(settings.text("snooze.3"), isOn: $settings.showSnooze3)
                    Toggle(settings.text("snooze.5"), isOn: $settings.showSnooze5)
                    Stepper(settings.text("reminder.weak.duration") + " \(Int(settings.weakDuration)) " + settings.text("seconds"), value: $settings.weakDuration, in: 3...60)
                    Stepper(settings.text("reminder.strong.duration") + " \(Int(settings.strongDuration)) " + settings.text("seconds"), value: $settings.strongDuration, in: 5...120)
                    Stepper(settings.text("reminder.repeat") + " \(Int(settings.strongRepeat / 60)) " + settings.text("minutes"), value: $settings.strongRepeat, in: 60...3600, step: 60)
                    Toggle(settings.text("sound.reminder"), isOn: $settings.reminderSound)
                    Toggle(settings.text("sound.completion"), isOn: $settings.completionSound)
                    Toggle(settings.text("rest.fullscreen"), isOn: $settings.fullscreenRest)
                }.font(.callout).toggleStyle(.switch).controlSize(.small)
            }
            Text(settings.text("reminder.nonblocking")).font(.callout).foregroundStyle(.secondary)
            Toggle(settings.text("sharing.manual"), isOn: Binding(get: { model.engine.sharing }, set: { value in model.act { $0.setSharing(value) } }))
            FlowCard {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle(settings.text("focus.follow"), isOn: $settings.followFocus)
                    Text(settings.text(model.focusStatusKey)).font(.callout)
                    Text(settings.text("focus.setup")).font(.caption).foregroundStyle(.secondary)
                    Button(settings.text("focus.openSettings")) { model.openFocusSettings() }
                }
            }
        case "settings.displays":
            FlowCard {
                Picker(settings.text("screen.title"), selection: $settings.reminderScreen) {
                    Text(settings.text("screen.current")).tag("current")
                    Text(settings.text("screen.primary")).tag("primary")
                    ForEach(model.screens, id: \.self) { screen in Text(screen.localizedName).tag(screenIdentifier(screen)) }
                    if !["current", "primary"].contains(settings.reminderScreen), !model.screens.contains(where: { screenIdentifier($0) == settings.reminderScreen }) {
                        Text(settings.text("screen.missing")).tag(settings.reminderScreen)
                    }
                }
            }
            Picker(settings.text("screen.corner"), selection: $settings.reminderCorner) {
                ForEach(["topRight", "topLeft", "bottomRight", "bottomLeft"], id: \.self) { corner in
                    Text(settings.text("corner." + corner)).tag(corner)
                }
            }
            Text(settings.text("screen.corner.help")).font(.caption).foregroundStyle(.secondary)
        case "wake.title": PowerControls(model: model)
        default:
            if model.history.isEmpty { Text(settings.text("history.empty")).foregroundStyle(.secondary) }
            ForEach(Array(model.history.suffix(50).reversed())) { event in
                HStack {
                    Text(event.date, style: .time).font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                    Text(settings.text("event." + event.kind)).font(.callout)
                }
                Divider()
            }
            Button(settings.text("history.open")) { model.openDataDirectory() }
        }
    }

    private func duration(_ key: String, _ path: WritableKeyPath<BreakPolicy, Double>, minutes: Bool = false) -> some View {
        HStack {
            Text(settings.text(key)).font(.callout)
            Spacer()
            TextField(settings.text(key), value: Binding(get: { settings.policy[keyPath: path] / (minutes ? 60 : 1) }, set: { settings.policy[keyPath: path] = $0 * (minutes ? 60 : 1) }), format: .number)
                .labelsHidden().multilineTextAlignment(.trailing).textFieldStyle(.roundedBorder).frame(width: 76)
            Text(settings.text(minutes ? "minutes" : "seconds")).font(.caption).foregroundStyle(.secondary).frame(width: 48, alignment: .leading)
        }
    }
}
