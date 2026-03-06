//
//  SettingsView.swift
//  Altar
//
//  Timer settings controls.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var timerViewModel: TimerViewModel
    @State private var settings: TimerSettings = SettingsManager.load()

    var body: some View {
        Form {
            Section("Focus") {
                Stepper("\(settings.focusDurationMinutes) min", value: $settings.focusDurationMinutes, in: 1...120)
                    .onChange(of: settings.focusDurationMinutes) { _ in applySettings() }
            }
            Section("Short break") {
                Stepper("\(settings.shortBreakMinutes) min", value: $settings.shortBreakMinutes, in: 1...30)
                    .onChange(of: settings.shortBreakMinutes) { _ in applySettings() }
            }
            Section("Long break") {
                Stepper("\(settings.longBreakMinutes) min", value: $settings.longBreakMinutes, in: 1...60)
                    .onChange(of: settings.longBreakMinutes) { _ in applySettings() }
            }
            Section("Long break frequency") {
                Stepper("Every \(settings.sessionsBeforeLongBreak) focus sessions", value: $settings.sessionsBeforeLongBreak, in: 2...10)
                    .onChange(of: settings.sessionsBeforeLongBreak) { _ in applySettings() }
            }
            Section {
                Toggle("Auto-start next session", isOn: $settings.autoStartNextSession)
                    .onChange(of: settings.autoStartNextSession) { _ in applySettings() }
            }
            Section {
                Button("Reset to defaults") {
                    settings = .default
                    applySettings()
                }
            }
        }
        .formStyle(.grouped)
    }

    private func applySettings() {
        SettingsManager.save(settings)
        timerViewModel.configure(settings: settings)
    }
}
