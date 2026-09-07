import SwiftUI
import FlowBreakCore

struct DashboardView: View {
    @ObservedObject var model: AppModel
    @ObservedObject private var settings: SettingsStore
    @State private var powerPage = false
    private let nativePopoverBackground: Bool
    init(model: AppModel, nativePopoverBackground: Bool = false) {
        self.model = model; self.settings = model.settings
        self.nativePopoverBackground = nativePopoverBackground
    }
    private func text(_ key: String) -> String { settings.text(key) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    Image(systemName: "leaf.fill").foregroundStyle(.green).font(.title3)
                    Text("FlowBreak").font(.system(size: 17, weight: .bold))
                    Spacer()
                    Text(text(model.statusKey)).font(.system(size: 10, weight: .medium))
                        .padding(.horizontal, 8).padding(.vertical, 5)
                        .background(.green.opacity(0.10), in: Capsule())
                }
                if let error = model.errorKey { notice(text(error), symbol: "exclamationmark.triangle", color: .red) }
                if model.lastEvent == "breakInterrupted" { notice(text("break.interrupted"), symbol: "cursorarrow", color: .orange) }
                if powerPage {
                    Button { powerPage = false } label: { Label(text("nav.back"), systemImage: "chevron.left") }.buttonStyle(FlowButtonStyle(quiet: true, fullWidth: false))
                    PowerControls(model: model)
                } else {
                    HStack(alignment: .top, spacing: 10) {
                        timerCard(eye: true)
                        timerCard(eye: false)
                    }
                    if model.engine.session.activeBreak != nil {
                        RestContent(model: model)
                    } else {
                        SectionCaption(title: text("dashboard.start"))
                        HStack(spacing: 10) {
                            Button { model.act { $0.beginBreak(.eye) } } label: {
                                Label(text("eye.start"), systemImage: "eye")
                            }.buttonStyle(FlowButtonStyle(prominent: true))
                            Button { model.act { $0.beginBreak(.movement) } } label: {
                                Label(text("movement.start"), systemImage: "figure.walk")
                            }.buttonStyle(FlowButtonStyle(prominent: true, tint: .green))
                        }.disabled(model.engine.session.timingPaused)
                    }
                    if model.engine.snoozeUntil > model.engine.time {
                        notice(text("snooze.remaining") + "  " + timeString(model.engine.snoozeUntil - model.engine.time), symbol: "clock", color: .accentColor)
                    } else if model.engine.isWaitingForStrong {
                        notice(text("movement.wait.help"), symbol: "clock", color: .orange)
                    }
                    if let next = model.engine.nextReminderEstimate {
                        HStack {
                            Text(text("next.estimated"))
                            Spacer()
                            Text(Date().addingTimeInterval(next.seconds), style: .time).monospacedDigit()
                            Text(text(next.eye && next.movement ? "reminder.merged" : (next.eye ? "eye.title" : "movement.title")))
                        }.font(.system(size: 10)).foregroundStyle(.secondary)
                    }
                    SectionCaption(title: text("dashboard.mode"))
                    HStack(spacing: 10) {
                        modeButton("agent.start", detail: "agent.summary", symbol: "sparkles", active: model.engine.session.timingPaused)
                        modeButton("wake.title", detail: "wake.summary", symbol: "cup.and.saucer", active: model.engine.session.keepAwakeRequested)
                    }
                    if model.engine.session.keepAwakeRequested || model.engine.session.timingPaused {
                        HStack {
                            Image(systemName: "timer").foregroundStyle(.blue)
                            Text(model.engine.wakeRemaining.map(timeString) ?? text("wake.unlimited")).monospacedDigit()
                            Spacer()
                            Button(text(model.engine.session.timingPaused ? "timing.resume" : "wake.stop")) {
                                model.act { if $0.session.timingPaused { $0.resumeTiming() } else { $0.stopKeepAwake() } }
                            }.buttonStyle(FlowButtonStyle(quiet: true, fullWidth: false))
                        }.font(.caption).padding(10).background(.blue.opacity(0.06), in: RoundedRectangle(cornerRadius: 9))
                    }
                    SectionCaption(title: text("rest.mark"))
                    HStack(spacing: 10) {
                        Button(text("eye.done")) { model.act { $0.markRest(.eye) } }
                        Button(text("movement.done")) { model.act { $0.markRest(.movement) } }
                    }.buttonStyle(FlowButtonStyle())
                    HStack(alignment: .top) {
                        Text(text("rest.mark.help")).font(.system(size: 10)).foregroundStyle(.secondary)
                        Spacer()
                        if let event = model.engine.undoEvent { Button(text("undo." + event)) { model.act { $0.undo() } }.font(.caption).buttonStyle(FlowButtonStyle(quiet: true, fullWidth: false)) }
                    }
                    DisclosureGroup(text("reminder.actions")) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                if settings.showSnooze3 { Button(text("snooze.3")) { model.act { $0.snooze(seconds: 180) } } }
                                if settings.showSnooze5 { Button(text("snooze.5")) { model.act { $0.snooze(seconds: 300) } } }
                            }.buttonStyle(FlowButtonStyle())
                            HStack {
                                Button(text("eye.skip")) { model.act { $0.skip(.eye) } }
                                Button(text("movement.skip")) { model.act { $0.skip(.movement) } }
                            }.buttonStyle(FlowButtonStyle(quiet: true, fullWidth: false))
                            Toggle(text("sharing.manual"), isOn: Binding(get: { model.engine.sharing }, set: { value in model.act { $0.setSharing(value) } }))
                                .toggleStyle(.switch).controlSize(.small)
                            Text(text("sharing.help")).font(.caption).foregroundStyle(.secondary)
                        }.padding(.top, 8)
                    }.font(.caption)
                }
                if model.engine.focusQuiet { notice(text(model.focusStatusKey), symbol: "moon.fill", color: .blue) }
                if model.engine.sharing { notice(text("sharing.active"), symbol: "rectangle.on.rectangle.slash", color: .blue) }
                Divider()
                HStack {
                    SettingsLink { Label(text("settings.title"), systemImage: "gearshape") }.buttonStyle(FlowButtonStyle(quiet: true, fullWidth: false))
                    Spacer()
                    Button(text("quit")) { NSApplication.shared.terminate(nil) }.buttonStyle(FlowButtonStyle(quiet: true, fullWidth: false)).foregroundStyle(.secondary)
                }.font(.caption)
            }.padding(18)
        }.frame(width: 390, height: 650).background(nativePopoverBackground ? Color.clear : FlowStyle.canvas).preferredColorScheme(settings.colorScheme)
    }

    private func notice(_ message: String, symbol: String, color: Color) -> some View {
        Label(message, systemImage: symbol).font(.caption).foregroundStyle(color)
            .padding(10).frame(maxWidth: .infinity, alignment: .leading)
            .background(color.opacity(0.07), in: RoundedRectangle(cornerRadius: 10))
    }

    private func modeButton(_ key: String, detail: String, symbol: String, active: Bool) -> some View {
        Button { powerPage = true } label: {
            HStack(spacing: 8) {
                Image(systemName: symbol).foregroundStyle(active ? .blue : .secondary)
                VStack(alignment: .leading, spacing: 3) {
                    Text(text(key)).font(.system(size: 12, weight: .semibold))
                    Text(text(detail)).font(.system(size: 9)).foregroundStyle(.secondary).lineLimit(2)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right").font(.system(size: 8)).foregroundStyle(.tertiary)
            }.padding(10).frame(maxWidth: .infinity, minHeight: 50, alignment: .leading)
                .background(active ? Color.blue.opacity(0.07) : FlowStyle.card, in: RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(active ? .blue.opacity(0.3) : FlowStyle.border))
        }.buttonStyle(FlowButtonStyle(quiet: true, fullWidth: false))
    }

    private func timerCard(eye: Bool) -> some View {
        let elapsed = eye ? model.engine.session.eyeElapsed : model.engine.session.movementElapsed
        let target = eye ? model.engine.policy.eyeInterval : model.engine.policy.movementStrongInterval
        let soft = eye ? target : model.engine.policy.movementSoftInterval
        let due = elapsed >= soft
        let tint: Color = due ? .orange : (eye ? .blue : .green)
        return FlowCard(accent: due ? .orange : .clear) {
            VStack(alignment: .leading, spacing: 10) {
                Label(text(eye ? "eye.title" : "movement.title"), systemImage: eye ? "eye" : "figure.walk")
                    .font(.system(size: 12, weight: .semibold))
                Text(timeString(elapsed)).font(.system(size: 26, weight: .semibold, design: .rounded)).monospacedDigit()
                Text(text("timer.accumulated")).font(.system(size: 10)).foregroundStyle(.secondary)
                ProgressView(value: min(1, elapsed / target)).tint(tint)
                Text(due ? text(elapsed >= target ? "timer.due" : "timer.soft") : text("next.in") + " " + timeString(soft - elapsed))
                    .font(.system(size: 10, weight: .medium)).foregroundStyle(due ? tint : .secondary)
                if !eye && due && elapsed < target {
                    Text(text("timer.strong.in") + " " + timeString(target - elapsed)).font(.system(size: 9)).foregroundStyle(.secondary)
                }
            }.frame(maxWidth: .infinity, minHeight: 142, alignment: .topLeading)
        }
    }
}
