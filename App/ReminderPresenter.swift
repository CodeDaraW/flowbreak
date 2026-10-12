import AppKit
import SwiftUI
import FlowBreakCore

@MainActor
private final class ReminderPanel: NSPanel {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}

@MainActor
final class ReminderPresenter {
    private weak var model: AppModel?
    private var panel: ReminderPanel?
    private var hideAt: Double = 0
    private var lastTick: Double = 0
    private var expanded = false
    private var currentReminder: Reminder?
    private var resting = false
    var isVisible: Bool { panel?.isVisible == true }

    init(model: AppModel) { self.model = model }

    @discardableResult
    func show(_ reminder: Reminder) -> Bool {
        guard let model else { return false }
        let result = present(AnyView(ReminderView(model: model, reminder: reminder)), height: reminderHeight(reminder, expanded: false))
        currentReminder = reminder
        resting = false
        hideAt = model.engine.time + (reminder.strong ? model.settings.strongDuration : model.settings.weakDuration)
        lastTick = model.engine.time
        return result
    }

    func showRest() {
        guard let model, destinationScreen(model.settings.reminderScreen) != nil else { return }
        model.restPanelWillShow.send()
        let fullscreen = model.settings.fullscreenRest && model.engine.session.activeBreak == .movement
        let content = RestContent(model: model)
            .frame(maxWidth: fullscreen ? 480 : .infinity)
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(FlowStyle.canvas, in: RoundedRectangle(cornerRadius: 16))
        _ = present(AnyView(content), height: model.engine.session.activeBreak == .movement ? 380 : 310)
        resting = true
        if model.settings.fullscreenRest, model.engine.session.activeBreak == .movement,
           let screen = destinationScreen(model.settings.reminderScreen) {
            panel?.setFrame(screen.frame, display: true)
        }
    }

    private func present(_ content: AnyView, height: Double) -> Bool {
        guard let model, destinationScreen(model.settings.reminderScreen) != nil else { return false }
        hide()
        let window = ReminderPanel(contentRect: NSRect(x: 0, y: 0, width: 370, height: height),
                                   styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        // Above ordinary app, floating and modal windows without taking input focus.
        window.level = .popUpMenu
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
        window.isReleasedWhenClosed = false
        window.hidesOnDeactivate = false
        window.isMovable = false
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        let hosting = NSHostingView(rootView: content.preferredColorScheme(model.settings.colorScheme))
        // Window dimensions belong to this presenter, including the optional full-screen frame.
        hosting.sizingOptions = []
        window.contentView = hosting
        panel = window
        reposition()
        window.orderFrontRegardless()
        return true
    }

    func setExpanded(_ value: Bool) {
        expanded = value
        guard let panel, let model, let reminder = currentReminder,
              let screen = destinationScreen(model.settings.reminderScreen) else { return }
        let height = min(reminderHeight(reminder, expanded: value), screen.visibleFrame.height - 40)
        var frame = panel.frame
        if !model.settings.reminderCorner.hasPrefix("bottom") { frame.origin.y += frame.height - height }
        frame.size.height = height
        panel.setFrame(frame, display: true)
        reposition()
    }

    /// Keep visible work on screen when a display disappears or changes geometry.
    func reposition() {
        guard let panel, let model else { return }
        guard let screen = destinationScreen(model.settings.reminderScreen) else { hide(); return }
        if resting && model.settings.fullscreenRest && model.engine.session.activeBreak == .movement {
            panel.setFrame(screen.frame, display: true)
            return
        }
        let bounds = screen.visibleFrame.insetBy(dx: 20, dy: 20)
        let width = min(370, bounds.width)
        let height = min(panel.frame.height, bounds.height)
        let corner = model.settings.reminderCorner
        panel.setFrame(NSRect(x: corner.hasSuffix("Left") ? bounds.minX : bounds.maxX - width,
                              y: corner.hasPrefix("bottom") ? bounds.minY : bounds.maxY - height,
                              width: width, height: height), display: true)
    }

    private func reminderHeight(_ reminder: Reminder, expanded: Bool) -> Double {
        let base: Double = reminder.eye && reminder.movement ? 410 : (reminder.movement ? 370 : 330)
        return base + (expanded ? 140 : 0)
    }

    func expire(at time: Double) {
        guard isVisible, !resting else { return }
        if expanded || panel?.frame.contains(NSEvent.mouseLocation) == true {
            hideAt += max(0, time - lastTick)
        }
        lastTick = time
        if time >= hideAt { hide() }
    }

    func hide() {
        panel?.orderOut(nil)
        panel = nil
        currentReminder = nil
        expanded = false
    }

    private func destinationScreen(_ selection: String) -> NSScreen? {
        let screens = NSScreen.screens
        if selection == "current" {
            return screens.first { $0.frame.contains(NSEvent.mouseLocation) } ?? screens.first
        }
        if selection == "primary" { return screens.first }
        return screens.first { screenIdentifier($0) == selection } ?? screens.first
    }
}

func screenIdentifier(_ screen: NSScreen) -> String {
    guard let number = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber else { return "primary" }
    if let uuid = CGDisplayCreateUUIDFromDisplayID(number.uint32Value)?.takeRetainedValue() {
        return CFUUIDCreateString(nil, uuid) as String
    }
    return number.stringValue
}

private struct ReminderView: View {
    @ObservedObject var model: AppModel
    let reminder: Reminder
    @State private var expanded = false
    private func text(_ key: String) -> String { model.settings.text(key) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label(text(reminder.eye && reminder.movement ? "reminder.merged" : (reminder.movement ? "movement.title" : "eye.title")),
                          systemImage: reminder.movement ? "figure.walk" : "eye")
                        .font(.system(size: 12, weight: .semibold)).foregroundStyle(reminder.strong ? .orange : .blue)
                    Spacer()
                    Button { model.dismissReminder() } label: { Image(systemName: "xmark") }
                        .buttonStyle(FlowButtonStyle(quiet: true, fullWidth: false)).accessibilityLabel(text("close"))
                }
                Text(text(reminder.movement ? (reminder.strong ? "reminder.strong" : "reminder.movement.gentle") : "rest.lookAway"))
                    .font(.system(size: 20, weight: .semibold))
                Text(text(reminder.movement ? "rest.move.help" : "rest.eye.help")).font(.caption).foregroundStyle(.secondary)
                if reminder.movement {
                    Button(text("movement.start")) { model.act { $0.beginBreak(.movement) } }.buttonStyle(FlowButtonStyle(prominent: true))
                }
                if reminder.eye {
                    Button(text("eye.start")) { model.act { $0.beginBreak(.eye) } }.buttonStyle(FlowButtonStyle(prominent: !reminder.movement))
                }
                HStack {
                    if model.settings.showSnooze3 { Button(text("snooze.3")) { model.act { $0.snooze(seconds: 180, kind: reminder.eye && reminder.movement ? nil : (reminder.eye ? .eye : .movement)) } } }
                    if model.settings.showSnooze5 { Button(text("snooze.5")) { model.act { $0.snooze(seconds: 300, kind: reminder.eye && reminder.movement ? nil : (reminder.eye ? .eye : .movement)) } } }
                }.buttonStyle(FlowButtonStyle())
                if reminder.movement && !reminder.strong {
                    Button(text("movement.wait")) { model.act { $0.waitUntilStrong() } }.buttonStyle(FlowButtonStyle(quiet: true, fullWidth: false))
                }
                DisclosureGroup(text("reminder.skip.options"), isExpanded: $expanded) {
                    VStack(alignment: .leading, spacing: 10) {
                        if reminder.eye { Button(text("eye.skip")) { model.act { $0.skip(.eye) } } }
                        if reminder.movement { Button(text("movement.skip")) { model.act { $0.skip(.movement) } } }
                        if reminder.eye && reminder.movement {
                            Button(text("reminder.skip.both")) { model.act { $0.skipBoth() } }
                        }
                        Text(text("reminder.skip.help")).font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                    }.padding(.top, 8).buttonStyle(FlowButtonStyle(quiet: true, fullWidth: false))
                }.font(.caption).onChange(of: expanded) { _, value in model.setReminderExpanded(value) }
                Button(text(reminder.movement ? "movement.done" : "eye.done")) {
                    model.act { $0.markRest(reminder.movement ? .movement : .eye) }
                }.buttonStyle(FlowButtonStyle(quiet: true, fullWidth: false)).font(.caption)
            }.fixedSize(horizontal: false, vertical: true).padding(20)
        }.frame(width: 370).frame(maxHeight: .infinity)
            .background(FlowStyle.canvas, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(reminder.strong ? .orange.opacity(0.6) : FlowStyle.border))
    }
}
