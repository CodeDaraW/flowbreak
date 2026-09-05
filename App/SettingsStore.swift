import Foundation
import Combine
import FlowBreakCore

@MainActor
final class SettingsStore: ObservableObject {
    @Published var policy: BreakPolicy { didSet { save() } }
    @Published var language: String { didSet { defaults.set(language, forKey: "language") } }
    @Published var keepDisplayOn: Bool { didSet { defaults.set(keepDisplayOn, forKey: "keepDisplayOn") } }
    @Published var reminderScreen: String { didSet { defaults.set(reminderScreen, forKey: "reminderScreen") } }
    @Published private(set) var loadFailed = false
    private let defaults: UserDefaults
    private let key = "breakPolicy.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let data = defaults.data(forKey: "breakPolicy.v1")
        if let data, let saved = try? JSONDecoder().decode(BreakPolicy.self, from: data), saved.isValid {
            policy = saved
        } else {
            policy = BreakPolicy()
            loadFailed = data != nil
        }
        language = defaults.string(forKey: "language") ?? "system"
        keepDisplayOn = defaults.object(forKey: "keepDisplayOn") as? Bool ?? true
        reminderScreen = defaults.string(forKey: "reminderScreen") ?? "current"
    }

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
        loadFailed = false
    }
}
