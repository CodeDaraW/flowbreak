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
    private var resting = false
    private var outsideMonitor: Any?
    var isVisible: Bool { panel?.isVisible == true }

    init(model: AppModel) { self.model = model }

    @discardableResult
    func show(_ reminder: Reminder) -> Bool {
        guard let model else { return false }
        let result = present(AnyView(ReminderView(model: model, reminder: reminder)), height: 450)
        resting = false
        hideAt = model.engine.time + (reminder.strong ? 12 : 7)
        lastTick = model.engine.time
        return result
    }

    func showRest() {
        guard let model else { return }
        _ = present(AnyView(RestContent(model: model).padding(12).background(FlowStyle.canvas, in: RoundedRectangle(cornerRadius: 16))), height: 310)
        resting = true
    }

    private func present(_ content: AnyView, height: Double) -> Bool {
        guard let model, let screen = destinationScreen(model.settings.reminderScreen) else { return false }
        hide()
        let window = ReminderPanel(contentRect: NSRect(x: 0, y: 0, width: 370, height: height),
                                   styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
        window.isReleasedWhenClosed = false
        window.hidesOnDeactivate = false
        window.isMovable = false
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.contentView = NSHostingView(rootView: content)
        let frame = screen.visibleFrame
        window.setFrameOrigin(NSPoint(x: frame.maxX - 390, y: frame.maxY - height - 20))
        panel = window
        window.orderFrontRegardless()
        outsideMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            Task { @MainActor in if self?.resting != true { self?.hide() } }
        }
        return true
    }

    func setExpanded(_ value: Bool) { expanded = value }

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
        expanded = false
        if let outsideMonitor { NSEvent.removeMonitor(outsideMonitor) }
        outsideMonitor = nil
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
                        .buttonStyle(.plain).accessibilityLabel(text("close"))
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
                    Button(text("snooze.3")) { model.act { $0.snooze(seconds: 180) } }
                    Button(text("snooze.5")) { model.act { $0.snooze(seconds: 300) } }
                }.buttonStyle(FlowButtonStyle())
                if reminder.movement && !reminder.strong {
                    Button(text("movement.wait")) { model.act { $0.waitUntilStrong() } }.buttonStyle(.borderless)
                }
                DisclosureGroup(text("reminder.skip.options"), isExpanded: $expanded) {
                    VStack(alignment: .leading, spacing: 10) {
                        if reminder.eye { Button(text("eye.skip")) { model.act { $0.skip(.eye) } } }
                        if reminder.movement { Button(text("movement.skip")) { model.act { $0.skip(.movement) } } }
                        if reminder.eye && reminder.movement {
                            Button(text("reminder.skip.both")) { model.act { $0.skip(.eye); $0.skip(.movement) } }
                        }
                        Text(text("reminder.skip.help")).font(.caption).foregroundStyle(.secondary)
                    }.padding(.top, 8).buttonStyle(.borderless)
                }.font(.caption).onChange(of: expanded) { _, value in model.setReminderExpanded(value) }
                Button(text(reminder.movement ? "movement.done" : "eye.done")) {
                    model.act { $0.markRest(reminder.movement ? .movement : .eye) }
                }.buttonStyle(.borderless).font(.caption)
            }.padding(20)
        }.frame(width: 370, height: 450)
            .background(FlowStyle.canvas, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(reminder.strong ? .orange.opacity(0.6) : FlowStyle.border))
    }
}
