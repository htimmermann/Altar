//
//  MenuBarContentView.swift
//  Altar
//
//  Root popover content with tabbed navigation.
//

import AppKit
import SwiftUI

struct MenuBarContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                Text("Timer").tag(0)
                Text("Tasks").tag(1)
                Text("Reports").tag(2)
                Text("Settings").tag(3)
            }
            .pickerStyle(.segmented)
            .padding()

            Group {
                switch selectedTab {
                case 0: TimerView()
                case 1: TaskListView()
                case 2: ReportsView()
                case 3: SettingsView()
                default: TimerView()
                }
            }
            .frame(minWidth: 300, minHeight: 280)

            Divider()

            Button("Quit Altar") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .padding(.bottom, 8)
        }
        .frame(width: 320, height: 400)
    }
}
