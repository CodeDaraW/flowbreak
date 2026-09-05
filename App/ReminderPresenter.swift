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
    private var outsideMonitor: Any?
    var isVisible: Bool { panel?.isVisible == true }

    init(model: AppModel) { self.model = model }

    @discardableResult
    func show(_ reminder: Reminder) -> Bool {
        guard let model, let screen = destinationScreen(model.settings.reminderScreen) else { return false }
        hide()
        let window = ReminderPanel(contentRect: NSRect(x: 0, y: 0, width: 360, height: 220),
                                   styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
        window.isReleasedWhenClosed = false
        window.hidesOnDeactivate = false
        window.isMovable = false
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.contentView = NSHostingView(rootView: ReminderView(model: model, reminder: reminder))
        let frame = screen.visibleFrame
        window.setFrameOrigin(NSPoint(x: frame.maxX - 380, y: frame.maxY - 240))
        panel = window
        hideAt = model.engine.time + (reminder.strong ? 12 : 7)
        // Never activate the app, make a key window, or move the current Space.
        window.orderFrontRegardless()
        outsideMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            Task { @MainActor in self?.hide() }
        }
        return true
    }

    func expire(at time: Double) { if isVisible && time >= hideAt { hide() } }

    func hide() {
        panel?.orderOut(nil)
        panel = nil
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
    private func text(_ key: String) -> String { model.settings.text(key) }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label(text(reminder.movement ? "movement.title" : "eye.title"),
                      systemImage: reminder.movement ? "figure.walk" : "eye")
                    .font(.headline)
                Spacer()
                Button { model.dismissReminder() } label: { Image(systemName: "xmark") }
                    .buttonStyle(.plain).accessibilityLabel(text("close"))
            }
            Text(text(reminder.strong ? "reminder.strong" : "reminder.gentle"))
                .font(.callout).foregroundStyle(.secondary)
            HStack {
                if reminder.movement {
                    Button(text("movement.start")) { model.act { $0.beginBreak(.movement) } }
                        .buttonStyle(.borderedProminent).tint(.green)
                }
                Button(text("eye.start")) { model.act { $0.beginBreak(.eye) } }
            }
            HStack {
                Button(text("snooze.3")) { model.act { $0.snooze(seconds: 180) } }
                Button(text("snooze.5")) { model.act { $0.snooze(seconds: 300) } }
                Menu(text("more")) {
                    if reminder.eye {
                        Button(text("eye.skip")) { model.act { $0.skip(.eye) } }
                    }
                    if reminder.movement {
                        if reminder.strong {
                            Button(text("movement.skip")) { model.act { $0.skip(.movement) } }
                        } else {
                            Button(text("movement.wait")) { model.act { $0.waitUntilStrong() } }
                        }
                    }
                }
            }.controlSize(.small)
        }
        .padding(20)
        .frame(width: 360, height: 220)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(reminder.strong ? .orange.opacity(0.7) : .gray.opacity(0.2)))
    }
}
