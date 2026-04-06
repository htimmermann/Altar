//
//  SettingsView.swift
//  Altar
//
//  Timer settings controls with typeable fields.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var timerViewModel: TimerViewModel
    @State private var settings: TimerSettings = SettingsManager.load()
    @State private var barColor: Color = Color(hex: SettingsManager.load().barColorHex)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Durations").font(.headline)
                durationField("Focus", value: $settings.focusDurationMinutes)
                durationField("Short break", value: $settings.shortBreakMinutes)
                durationField("Long break", value: $settings.longBreakMinutes)
                durationField("Long break every (sessions)", value: $settings.sessionsBeforeLongBreak)

                Divider()

                Text("Goals").font(.headline)
                durationField("Daily goal", value: $settings.dailyGoalMinutes)
                durationField("Weekly goal", value: $settings.weeklyGoalMinutes)

                Divider()

                Toggle("Auto-start next session", isOn: $settings.autoStartNextSession)
                    .onChange(of: settings.autoStartNextSession) { _, _ in applySettings() }
                Toggle("Show Tasks tab", isOn: $settings.showTasksTab)
                    .onChange(of: settings.showTasksTab) { _, _ in applySettings() }

                Divider()

                HStack {
                    Text("Bar color")
                    Spacer()
                    ColorPicker("", selection: $barColor, supportsOpacity: false)
                        .labelsHidden()
                        .onChange(of: barColor) { _, _ in
                            settings.barColorHex = barColor.hexString
                            applySettings()
                        }
                }

                Divider()

                Button("Reset to defaults") {
                    settings = .default
                    barColor = Color(hex: TimerSettings.default.barColorHex)
                    applySettings()
                }
                .font(.caption)
            }
            .padding(12)
        }
    }

    private func durationField(_ label: String, value: Binding<Int>) -> some View {
        HStack {
            Text(label)
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField("", value: value, format: .number)
                .textFieldStyle(.roundedBorder)
                .frame(width: 50)
                .multilineTextAlignment(.trailing)
                .onChange(of: value.wrappedValue) { _, _ in applySettings() }
            Text("min").font(.caption).foregroundStyle(.secondary)
        }
    }

    private func applySettings() {
        SettingsManager.save(settings)
        timerViewModel.configure(settings: settings)
    }
}
