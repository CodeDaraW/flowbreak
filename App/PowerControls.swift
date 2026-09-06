import SwiftUI

struct PowerControls: View {
    @ObservedObject var model: AppModel
    @State private var minutes = 30.0
    @State private var editingEnd = false
    @State private var endDate = Date().addingTimeInterval(1800)
    private func text(_ key: String) -> String { model.settings.text(key) }
    private var active: Bool { model.engine.session.keepAwakeRequested }
    private var paused: Bool { model.engine.session.timingPaused }
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label(text(paused ? "agent.start" : "wake.title"), systemImage: paused ? "sparkles" : "cup.and.saucer")
                    .font(.title3.bold())
                Spacer()
                Text(text(active ? "power.running" : "power.ready")).font(.caption).foregroundStyle(.secondary)
            }
            if active {
                FlowCard(accent: .blue) {
                    VStack(alignment: .leading, spacing: 9) {
                        Text(text("power.remaining")).font(.caption).foregroundStyle(.secondary)
                        Text(model.engine.wakeRemaining.map(timeString) ?? text("wake.unlimited"))
                            .font(.system(size: 36, weight: .semibold, design: .rounded)).monospacedDigit()
                        Text(text(paused ? "agent.running.help" : "wake.running.help")).font(.caption).foregroundStyle(.secondary)
                        if let started = model.engine.pauseStartedAt {
                            Text(text("power.paused.for") + " " + timeString(model.engine.time - started)).font(.caption).monospacedDigit()
                        }
                    }
                }
                if model.engine.wakeRemaining != nil {
                    HStack {
                        Text(text("wake.extend")).font(.caption)
                        Button("+15 " + text("minutes")) { model.extendWake(seconds: 900) }
                        Button("+30 " + text("minutes")) { model.extendWake(seconds: 1800) }
                    }.buttonStyle(FlowButtonStyle())
                }
                Button(text("power.editEnd")) {
                    endDate = Date().addingTimeInterval(model.engine.wakeRemaining ?? 1800)
                    editingEnd.toggle()
                }.buttonStyle(.borderless)
                if editingEnd {
                    DatePicker(text("power.endsAt"), selection: $endDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                    Button(text("power.apply")) {
                        model.startWake(seconds: endDate.timeIntervalSinceNow, agent: false)
                        editingEnd = false
                    }.buttonStyle(FlowButtonStyle()).disabled(endDate <= Date())
                }
                Button(text(paused ? "timing.resume" : "agent.handBack")) {
                    model.act { if $0.session.timingPaused { $0.resumeTiming() } else { $0.pauseTiming() } }
                }.buttonStyle(FlowButtonStyle(prominent: true))
                Button(text(paused ? "agent.end" : "wake.stop")) {
                    model.act { if $0.session.timingPaused { $0.endAgent() } else { $0.stopKeepAwake() } }
                }.buttonStyle(FlowButtonStyle())
            } else {
                Text(text("agent.summary")).font(.callout).foregroundStyle(.secondary)
                Picker(text("power.duration"), selection: $minutes) {
                    Text("30 " + text("minutes")).tag(30.0)
                    Text("60 " + text("minutes")).tag(60.0)
                    Text(text("power.custom")).tag(-1.0)
                }.pickerStyle(.segmented)
                if minutes == -1 { CustomWakeDuration(model: model) }
                else {
                    HStack {
                        Button(text("agent.start")) { model.startWake(seconds: minutes * 60, agent: true) }
                            .buttonStyle(FlowButtonStyle(prominent: true))
                        Button(text("wake.start")) { model.startWake(seconds: minutes * 60, agent: false) }
                            .buttonStyle(FlowButtonStyle())
                    }
                }
                if paused { Button(text("timing.resume")) { model.act { $0.resumeTiming() } }.buttonStyle(FlowButtonStyle()) }
            }
            if active {
                Toggle(text("wake.system"), isOn: Binding(get: { active }, set: { value in
                    if !value { model.settings.keepDisplayOn = false; model.act { $0.stopKeepAwake() } }
                })).toggleStyle(.switch).controlSize(.small)
            }
            Toggle(text("wake.display"), isOn: Binding(get: { model.settings.keepDisplayOn }, set: { model.settings.keepDisplayOn = $0 }))
                .toggleStyle(.switch).controlSize(.small)
            Text(text("wake.help")).font(.caption).foregroundStyle(.secondary)
        }
    }
}

private struct CustomWakeDuration: View {
    @ObservedObject var model: AppModel
    @State private var minutes = 90.0
    var body: some View {
        VStack {
            TextField(model.settings.text("minutes"), value: $minutes, format: .number).textFieldStyle(.roundedBorder)
            HStack {
                Button(model.settings.text("agent.start")) { model.startWake(seconds: minutes * 60, agent: true) }
                Button(model.settings.text("wake.start")) { model.startWake(seconds: minutes * 60, agent: false) }
            }.buttonStyle(FlowButtonStyle(prominent: true)).disabled(!minutes.isFinite || minutes <= 0 || minutes > 1440)
        }
    }
}
