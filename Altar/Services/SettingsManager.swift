//
//  SettingsManager.swift
//  Altar
//
//  UserDefaults-backed timer settings.
//

import Foundation

enum SettingsManager {
    private static let key = "timerSettings"

    static func load() -> TimerSettings {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode(TimerSettings.self, from: data) else {
            return .default
        }
        return decoded
    }

    static func save(_ settings: TimerSettings) {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
