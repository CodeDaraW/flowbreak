import Foundation
import Combine
import SwiftUI
import FlowBreakCore

@MainActor
final class SettingsStore: ObservableObject {
    @Published var followFocus: Bool { didSet { defaults.set(followFocus, forKey: "followFocus") } }
    @Published var policy: BreakPolicy { didSet { save() } }
    @Published var appearance: String { didSet { defaults.set(appearance, forKey: "appearance") } }
    @Published var language: String { didSet { defaults.set(language, forKey: "language") } }
    @Published var preventSystemSleep: Bool {
        didSet {
            defaults.set(preventSystemSleep, forKey: "preventSystemSleep")
            if !preventSystemSleep && keepDisplayOn { keepDisplayOn = false }
        }
    }
    @Published var keepDisplayOn: Bool {
        didSet {
            defaults.set(keepDisplayOn, forKey: "keepDisplayOn")
            if keepDisplayOn && !preventSystemSleep { preventSystemSleep = true }
        }
    }
    @Published var reminderScreen: String { didSet { defaults.set(reminderScreen, forKey: "reminderScreen") } }
    @Published var reminderCorner: String { didSet { defaults.set(reminderCorner, forKey: "reminderCorner") } }
    @Published var reminderSound: Bool { didSet { defaults.set(reminderSound, forKey: "reminderSound") } }
    @Published var completionSound: Bool { didSet { defaults.set(completionSound, forKey: "completionSound") } }
    @Published var fullscreenRest: Bool { didSet { defaults.set(fullscreenRest, forKey: "fullscreenRest") } }
    @Published var showSnooze3: Bool { didSet { defaults.set(showSnooze3, forKey: "showSnooze3") } }
    @Published var showSnooze5: Bool { didSet { defaults.set(showSnooze5, forKey: "showSnooze5") } }
    @Published var weakDuration: Double { didSet { defaults.set(weakDuration, forKey: "weakDuration") } }
    @Published var strongDuration: Double { didSet { defaults.set(strongDuration, forKey: "strongDuration") } }
    @Published var strongRepeat: Double { didSet { defaults.set(strongRepeat, forKey: "strongRepeat") } }
    @Published private(set) var loadFailed = false
    private let defaults: UserDefaults
    private let key = "breakPolicy.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        followFocus = defaults.object(forKey: "followFocus") as? Bool ?? true
        let data = defaults.data(forKey: "breakPolicy.v1")
        if let data, let saved = try? JSONDecoder().decode(BreakPolicy.self, from: data), saved.isValid {
            policy = saved
        } else {
            policy = BreakPolicy()
            loadFailed = data != nil
        }
        appearance = defaults.string(forKey: "appearance") ?? "system"
        language = defaults.string(forKey: "language") ?? "system"
        let savedDisplayOn = defaults.object(forKey: "keepDisplayOn") as? Bool ?? true
        keepDisplayOn = savedDisplayOn
        preventSystemSleep = savedDisplayOn || (defaults.object(forKey: "preventSystemSleep") as? Bool ?? true)
        reminderScreen = defaults.string(forKey: "reminderScreen") ?? "current"
        reminderCorner = defaults.object(forKey: "reminderCorner") as? String ?? "topRight"
        reminderSound = defaults.object(forKey: "reminderSound") as? Bool ?? false
        completionSound = defaults.object(forKey: "completionSound") as? Bool ?? true
        fullscreenRest = defaults.object(forKey: "fullscreenRest") as? Bool ?? false
        showSnooze3 = defaults.object(forKey: "showSnooze3") as? Bool ?? true
        showSnooze5 = defaults.object(forKey: "showSnooze5") as? Bool ?? true
        weakDuration = defaults.object(forKey: "weakDuration") as? Double ?? 8
        strongDuration = defaults.object(forKey: "strongDuration") as? Double ?? 15
        strongRepeat = defaults.object(forKey: "strongRepeat") as? Double ?? 600

    }

    var colorScheme: ColorScheme? { appearance == "dark" ? .dark : (appearance == "light" ? .light : nil) }

    var languageCode: String {
        if language != "system" { return language }
        return Locale.preferredLanguages.first?.hasPrefix("zh") == true ? "zh-Hans" : "en"
    }

    func text(_ key: String) -> String {
        guard let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
              let bundle = Bundle(path: path) else { return key }
        return bundle.localizedString(forKey: key, value: key, table: nil)
    }

    private func save() {
        guard policy.isValid, let data = try? JSONEncoder().encode(policy) else { return }
        defaults.set(data, forKey: key)
    }

    func reset() {
        policy = BreakPolicy()
        reminderCorner = "topRight"
        reminderSound = false
        completionSound = true
        fullscreenRest = false
        showSnooze3 = true
        showSnooze5 = true
        weakDuration = 8
        strongDuration = 15
        strongRepeat = 600
        loadFailed = false
    }
}
