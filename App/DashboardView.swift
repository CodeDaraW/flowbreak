import SwiftUI
import FlowBreakCore

struct DashboardView: View {
    @ObservedObject var model: AppModel
    @ObservedObject private var settings: SettingsStore
    init(model: AppModel) { self.model = model; self.settings = model.settings }
    private func text(_ key: String) -> String { settings.text(key) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Label("FlowBreak", systemImage: "leaf.fill").font(.title2.bold())
                    Spacer()
                    Text(text(model.statusKey)).font(.caption).foregroundStyle(.secondary)
                }
                if let error = model.errorKey { Text(text(error)).font(.caption).foregroundStyle(.red) }
                if model.lastEvent == "breakInterrupted" {
                    Text(text("break.interrupted")).font(.caption).foregroundStyle(.orange)
                }
                timerCard("eye.title", symbol: "eye", elapsed: model.engine.session.eyeElapsed,
                          target: model.engine.policy.eyeInterval)
                timerCard("movement.title", symbol: "figure.walk", elapsed: model.engine.session.movementElapsed,
                          target: model.engine.policy.movementStrongInterval)
                if !model.engine.isWaitingForStrong && model.engine.snoozeUntil > model.engine.time {
                    Text(text("snooze.remaining") + " " + timeString(model.engine.snoozeUntil - model.engine.time))
                        .font(.caption).foregroundStyle(.secondary)
                }
                if let kind = model.engine.session.activeBreak {
                    HStack {
                        Text(text(kind == .eye ? "eye.title" : "movement.title"))
                        Spacer()
                        Text(timeString(model.engine.breakRemaining)).monospacedDigit().font(.title2)
                        Button(text("cancel")) { model.act { $0.cancelBreak() } }
                    }
                } else {
                    HStack {
                        Button(text("eye.start")) { model.act { $0.beginBreak(.eye) } }
                        Button(text("movement.start")) { model.act { $0.beginBreak(.movement) } }
                    }.disabled(model.engine.session.timingPaused)
                }
                HStack {
                    Menu(text("rest.mark")) {
                        Button(text("eye.done")) { model.act { $0.markRest(.eye) } }
                        Button(text("movement.done")) { model.act { $0.markRest(.movement) } }
                    }
                    Button(text("undo")) { model.act { $0.undo() } }.disabled(!model.engine.canUndo)
                    Menu(text("reminder.actions")) {
                        Button(text("snooze.3")) { model.act { $0.snooze(seconds: 180) } }
                        Button(text("snooze.5")) { model.act { $0.snooze(seconds: 300) } }
                        if model.engine.session.eyeElapsed >= model.engine.policy.eyeInterval {
                            Button(text("eye.skip")) { model.act { $0.skip(.eye) } }
                        }
                        if model.engine.session.movementElapsed >= model.engine.policy.movementStrongInterval {
                            Button(text("movement.skip")) { model.act { $0.skip(.movement) } }
                        } else if model.engine.session.movementElapsed >= model.engine.policy.movementSoftInterval {
                            Button(text("movement.wait")) { model.act { $0.waitUntilStrong() } }
                        }
                    }
                }
                Divider()
                wakeSection
                Toggle(text("sharing.manual"), isOn: Binding(
                    get: { model.engine.sharing }, set: { value in model.act { $0.setSharing(value) } }))
                Text(text("sharing.help")).font(.caption).foregroundStyle(.secondary)
                DisclosureGroup(text("history.title")) {
                    VStack(alignment: .leading, spacing: 6) {
                        if model.history.isEmpty { Text(text("history.empty")) }
                        ForEach(Array(model.history.suffix(8).reversed())) { event in
                            HStack {
                                Text(event.date, style: .time).monospacedDigit()
                                Text(text("event." + event.kind))
                            }.font(.caption)
                        }
                        Button(text("history.open")) { model.openDataDirectory() }
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }
                Divider()
                HStack {
                    SettingsLink { Text(text("settings.title")) }
                    Spacer()
                    Button(text("quit")) { NSApplication.shared.terminate(nil) }
                }
            }.padding(20)
        }.frame(width: 390, height: 650)
    }

    private func timerCard(_ key: String, symbol: String, elapsed: Double, target: Double) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(text(key), systemImage: symbol)
                Spacer()
                Text(timeString(elapsed)).monospacedDigit().font(.title3.weight(.medium))
            }
            ProgressView(value: min(1, elapsed / target)).tint(elapsed >= target ? .orange : .green)
            if key == "movement.title" && elapsed >= model.engine.policy.movementSoftInterval {
                Text(text(elapsed >= target ? "movement.overdue" : "movement.suggested"))
                    .font(.caption).foregroundStyle(.orange)
            } else {
                Text(text("next.in") + " " + timeString(max(0, (key == "movement.title" ? model.engine.policy.movementSoftInterval : target) - elapsed)))
                    .font(.caption).foregroundStyle(.secondary)
            }
        }.padding(12).background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 12))
    }

    private var wakeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(text("wake.title"), systemImage: "cup.and.saucer")
                Spacer()
                if model.engine.session.keepAwakeRequested {
                    Text(model.engine.wakeRemaining.map(timeString) ?? text("wake.unlimited"))
                        .monospacedDigit().foregroundStyle(.secondary)
                }
            }
            if model.engine.session.keepAwakeRequested {
                HStack {
                    if model.engine.wakeRemaining != nil {
                        Menu(text("wake.extend")) {
                            ForEach([15, 30, 60], id: \.self) { minutes in
                                Button("+\(minutes) " + text("minutes")) { model.extendWake(seconds: Double(minutes * 60)) }
                            }
                        }
                    }
                    Button(text("wake.stop")) { model.act { $0.stopKeepAwake() } }
                }
            } else {
                HStack {
                    wakeMenu(agent: false)
                    wakeMenu(agent: true)
                }
            }
            HStack {
                Button(text(model.engine.session.timingPaused ? "timing.resume" : "timing.pause")) {
                    model.act { engine in
                        if engine.session.timingPaused { engine.resumeTiming() } else { engine.pauseTiming() }
                    }
                }
                if model.engine.session.timingPaused {
                    Button(text("agent.end")) { model.act { $0.endAgent() } }
                } else if model.engine.session.keepAwakeRequested {
                    Button(text("agent.handBack")) { model.act { $0.pauseTiming() } }
                }
            }
        }
    }

    private func wakeMenu(agent: Bool) -> some View {
        Menu(text(agent ? "agent.start" : "wake.start")) {
            ForEach([15, 30, 60, 120], id: \.self) { minutes in
                Button("\(minutes) " + text("minutes")) { model.startWake(seconds: Double(minutes * 60), agent: agent) }
            }
            Button(text("wake.unlimited")) { model.startWake(seconds: nil, agent: agent) }
        }
    }
}

func timeString(_ seconds: Double) -> String {
    let total = Int(max(0, min(seconds, Double(Int.max / 2))).rounded(.up))
    return String(format: "%02d:%02d", total / 60, total % 60)
}
