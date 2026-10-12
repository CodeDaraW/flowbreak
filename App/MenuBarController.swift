import AppKit
import SwiftUI
import Combine

/// Own the status button and presentation independently of SwiftUI scene reconstruction.
@MainActor
final class MenuBarController: NSObject {
    private let model: AppModel
    private let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let popover = NSPopover()
    private var subscription: AnyCancellable?
    private var restSubscription: AnyCancellable?
    private var appliedAppearance: String?
    private var displayedSymbol: String?
    private var displayedCountdown: String?

    init(model: AppModel) {
        self.model = model
        super.init()
        popover.behavior = .transient
        popover.animates = false
        popover.contentSize = NSSize(width: 390, height: 650)
        let host = NSHostingController(rootView: DashboardView(model: model, nativePopoverBackground: true))
        host.sizingOptions = []
        popover.contentViewController = host
        if let button = item.button {
            button.target = self
            button.action = #selector(clicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.setAccessibilityLabel("FlowBreak")
            button.toolTip = "FlowBreak"
        }
        restSubscription = model.restPanelWillShow.sink { [weak self] in
            self?.popover.performClose(nil)
        }
        updateButton()
        subscription = model.objectWillChange.sink { [weak self] in
            Task { @MainActor in self?.updateButton() }
        }
    }

    private func updateButton() {
        // AppKit may normalize an assigned appearance. Reapply only on a user preference change,
        // never as part of the one-second timer refresh while the popover is open.
        if appliedAppearance != model.settings.appearance {
            appliedAppearance = model.settings.appearance
            popover.appearance = switch model.settings.appearance {
            case "dark": NSAppearance(named: .darkAqua)
            case "light": NSAppearance(named: .aqua)
            default: nil
            }
        }
        guard let button = item.button else { return }
        var title = ""
        if !model.engine.notificationsQuiet {
            if model.engine.session.activeBreak != nil { title = menuBarCountdown(model.engine.breakRemaining, text: model.settings.text) }
            else if let remaining = model.engine.wakeRemaining { title = menuBarCountdown(remaining, text: model.settings.text) }
        }
        let symbol = model.symbol
        guard displayedSymbol != symbol || displayedCountdown != title else { return }
        displayedSymbol = symbol
        displayedCountdown = title
        button.title = ""
        button.imagePosition = .imageOnly
        button.image = menuBarLabel(symbol: symbol, countdown: title)
        button.setAccessibilityLabel(title.isEmpty ? "FlowBreak" : "FlowBreak, " + title)
    }

    @objc private func clicked(_ sender: NSStatusBarButton) {
        if NSApp.currentEvent?.type == .rightMouseUp {
            popover.performClose(nil)
            let menu = NSMenu()
            let open = menu.addItem(withTitle: model.settings.text("menu.open"), action: #selector(openDashboard), keyEquivalent: "")
            open.target = self
            menu.addItem(.separator())
            let quit = menu.addItem(withTitle: model.settings.text("quit"), action: #selector(quitApplication), keyEquivalent: "q")
            quit.target = self
            menu.popUp(positioning: nil, at: NSPoint(x: 0, y: sender.bounds.minY), in: sender)
        } else if popover.isShown {
            popover.performClose(nil)
        } else {
            openDashboard()
        }
    }

    @objc func openDashboard() {
        guard let button = item.button else { return }
        NSApp.activate(ignoringOtherApps: true)
        if !popover.isShown { popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY) }
        popover.contentViewController?.view.window?.makeKey()
    }

    @objc private func quitApplication() { NSApp.terminate(nil) }
}
