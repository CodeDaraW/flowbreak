import AppKit
import Combine
import FlowBreakCore
import FlowBreakMac

@MainActor
final class AppModel: ObservableObject {
    let settings = SettingsStore()
    @Published private(set) var engine = BreakEngine()
    @Published private(set) var history: [ActivityEvent] = []
    @Published private(set) var errorKey: String?
    @Published private(set) var lastEvent: String?
    @Published private(set) var screens: [NSScreen] = NSScreen.screens
    private let power = WakeController()
    private var repository: SessionRepository?
    private var storageWritable = true
    private let clock = ContinuousClock()
    private let origin = ContinuousClock.now
    private var timer: Timer?
    private var observers: [(NotificationCenter, NSObjectProtocol)] = []
    private var unavailableReasons = Set<String>()
    private var checkpoint: Double = 0
    private var panel: ReminderPresenter?
    private var appliedDisplayOn = true
    private var settingsSubscription: AnyCancellable?

    var now: Double {
        let duration = origin.duration(to: clock.now).components
        return Double(duration.seconds) + Double(duration.attoseconds) / 1e18
    }

    var statusKey: String {
        if !engine.available { return "status.unavailable" }
        if engine.session.timingPaused { return "status.paused" }
        if engine.sharing { return "status.sharing" }
        if engine.session.activeBreak != nil { return "status.resting" }
        if engine.idleSeconds >= engine.policy.idlePauseThreshold { return "status.idle" }
        if engine.isWaitingForStrong { return "status.waiting" }
        if engine.time < engine.snoozeUntil { return "status.snoozed" }
        return "status.working"
    }

    var symbol: String {
        if engine.sharing { return "leaf" }
        if engine.session.timingPaused { return "pause.circle" }
        if engine.session.activeBreak != nil { return "leaf.fill" }
        if engine.session.movementElapsed >= engine.policy.movementStrongInterval { return "figure.walk.circle.fill" }
        if engine.session.eyeElapsed >= engine.policy.eyeInterval { return "eye.circle" }
        return "leaf"
    }

    func start() {
        guard timer == nil else { return }
        engine = BreakEngine(now: now, policy: settings.policy)
        do {
            let store = try SessionRepository()
            repository = store
            if let saved = try store.loadSnapshot() {
                if saved.version == 1 { engine.restore(saved, at: Date()) }
                else { storageWritable = false; errorKey = "error.storage" }
            }
            history = try store.loadEvents()
        } catch {
            errorKey = "error.storage"
            storageWritable = false // Preserve damaged evidence until explicit user repair.
        }
        panel = ReminderPresenter(model: self)
        settingsSubscription = settings.objectWillChange.sink { [weak self] in
            Task { @MainActor in self?.objectWillChange.send() }
        }
        observe(NSWorkspace.shared.notificationCenter, NSWorkspace.willSleepNotification) { $0.setUnavailable("sleep", true) }
        observe(NSWorkspace.shared.notificationCenter, NSWorkspace.didWakeNotification) { $0.setUnavailable("sleep", false) }
        observe(NSWorkspace.shared.notificationCenter, NSWorkspace.sessionDidResignActiveNotification) { $0.setUnavailable("session", true) }
        observe(NSWorkspace.shared.notificationCenter, NSWorkspace.sessionDidBecomeActiveNotification) { $0.setUnavailable("session", false) }
        observe(NSWorkspace.shared.notificationCenter, NSWorkspace.screensDidSleepNotification) { $0.setUnavailable("display", true) }
        observe(NSWorkspace.shared.notificationCenter, NSWorkspace.screensDidWakeNotification) { $0.setUnavailable("display", false) }
        observe(DistributedNotificationCenter.default(), Notification.Name("com.apple.screenIsLocked")) { $0.setUnavailable("lock", true) }
        observe(DistributedNotificationCenter.default(), Notification.Name("com.apple.screenIsUnlocked")) { $0.setUnavailable("lock", false) }
        observe(.default, NSApplication.didChangeScreenParametersNotification) { model in
            model.screens = NSScreen.screens
            model.panel?.hide()
        }
        timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.pulse() }
        }
        timer?.tolerance = 0.2
        if let timer { RunLoop.main.add(timer, forMode: .common) }
        pulse()
    }

    private func observe(_ center: NotificationCenter, _ name: Notification.Name,
                         action: @escaping @MainActor (AppModel) -> Void) {
        let token = center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in if let self { action(self) } }
        }
        observers.append((center, token))
    }

    private func setUnavailable(_ reason: String, _ value: Bool) {
        pulse(present: false)
        if value { unavailableReasons.insert(reason) } else { unavailableReasons.remove(reason) }
        engine.setAvailable(unavailableReasons.isEmpty)
        panel?.hide()
        persist()
    }

    func pulse(present: Bool = true) {
        engine.updatePolicy(settings.policy)
        let idle = SystemActivity.idleSeconds()
        if idle == nil { errorKey = "error.idle" }
        // Unknown idle does not count as natural rest; no private input data is read.
        engine.tick(now: now, idle: idle ?? 0)
        if !engine.session.keepAwakeRequested && power.isActive { power.stop() }
        if engine.session.keepAwakeRequested && appliedDisplayOn != settings.keepDisplayOn {
            do {
                try power.start(seconds: engine.wakeRemaining, keepDisplayOn: settings.keepDisplayOn)
                appliedDisplayOn = settings.keepDisplayOn
            } catch { errorKey = "error.power" }
        }
        collectEvents()
        if engine.automaticallySuppressed { panel?.hide() }
        panel?.expire(at: engine.time)
        if present, idle != nil, let reminder = engine.reminder, panel?.isVisible != true {
            if panel?.show(reminder) == true { engine.markPresented(reminder); collectEvents() }
        }
        if engine.time - checkpoint >= 15 { persist() }
    }

    func act(_ action: (inout BreakEngine) -> Void) {
        pulse(present: false)
        panel?.hide()
        action(&engine)
        if !engine.session.keepAwakeRequested { power.stop() }
        collectEvents()
        persist()
    }

    func startWake(seconds: Double?, agent: Bool) {
        pulse(present: false)
        do {
            try power.startSession(engine: &engine, seconds: seconds, agent: agent,
                                   keepDisplayOn: settings.keepDisplayOn)
            appliedDisplayOn = settings.keepDisplayOn
            panel?.hide()
            collectEvents()
            persist()
            if errorKey == "error.power" { errorKey = nil }
        } catch { errorKey = "error.power" }
    }

    func extendWake(seconds: Double) {
        pulse(present: false)
        do {
            try power.extendSession(engine: &engine, seconds: seconds, keepDisplayOn: settings.keepDisplayOn)
            collectEvents()
            persist()
        } catch { errorKey = "error.power" }
    }

    func dismissReminder() { panel?.hide() }

    func openDataDirectory() {
        if let directory = repository?.directory { NSWorkspace.shared.open(directory) }
    }

    private func collectEvents() {
        let events = engine.drainEvents()
        if let last = events.last { lastEvent = last }
        history.append(contentsOf: events.map { ActivityEvent(date: Date(), kind: $0) })
        if history.count > 1000 { history.removeFirst(history.count - 1000) }
    }

    private func persist() {
        collectEvents()
        checkpoint = engine.time
        guard storageWritable, let repository else { return }
        do {
            try repository.saveSnapshot(engine.snapshot(at: Date()))
            try repository.saveEvents(history)
        } catch { errorKey = "error.storage" }
    }

    func stop() {
        pulse(present: false)
        timer?.invalidate()
        timer = nil
        power.stop()
        panel?.hide()
        persist()
        observers.forEach { $0.0.removeObserver($0.1) }
        observers.removeAll()
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let model = AppModel()
    func applicationDidFinishLaunching(_ notification: Notification) { model.start() }
    func applicationWillTerminate(_ notification: Notification) { model.stop() }
}
