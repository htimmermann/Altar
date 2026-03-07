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
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Group {
                    settingRow("Focus", value: $settings.focusDurationMinutes, range: 1...120, suffix: "min")
                    settingRow("Short break", value: $settings.shortBreakMinutes, range: 1...30, suffix: "min")
                    settingRow("Long break", value: $settings.longBreakMinutes, range: 1...60, suffix: "min")
                    settingRow("Long break every", value: $settings.sessionsBeforeLongBreak, range: 2...10, suffix: "sessions")
                }

                Divider()

                Toggle("Auto-start next session", isOn: $settings.autoStartNextSession)
                    .onChange(of: settings.autoStartNextSession) { _ in applySettings() }

                Toggle("Show Tasks tab", isOn: $settings.showTasksTab)
                    .onChange(of: settings.showTasksTab) { _ in applySettings() }

                Divider()

                Button("Reset to defaults") {
                    settings = .default
                    applySettings()
                }
                .font(.caption)
            }
            .padding(12)
        }
    }

    private func settingRow(_ label: String, value: Binding<Int>, range: ClosedRange<Int>, suffix: String) -> some View {
        Stepper("\(label): \(value.wrappedValue) \(suffix)", value: value, in: range)
            .onChange(of: value.wrappedValue) { _ in applySettings() }
    }

    private func applySettings() {
        SettingsManager.save(settings)
        timerViewModel.configure(settings: settings)
    }
}
