//
//  MenuBarContentView.swift
//  Altar
//
//  Root popover content with tabbed navigation.
//

import AppKit
import SwiftUI

struct MenuBarContentView: View {
    @EnvironmentObject var timerViewModel: TimerViewModel
    @State private var selectedTab = 0

    private var tabs: [(String, Int)] {
        var result: [(String, Int)] = [("Timer", 0)]
        if timerViewModel.showTasksTab {
            result.append(("Tasks", 1))
        }
        result.append(("Reports", 2))
        result.append(("Settings", 3))
        return result
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                ForEach(tabs, id: \.1) { tab in
                    Text(tab.0).tag(tab.1)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 12)
            .padding(.top, 10)
            .padding(.bottom, 6)

            Group {
                switch selectedTab {
                case 0: TimerView()
                case 1: TaskListView()
                case 2: ReportsView()
                case 3: SettingsView()
                default: TimerView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()

            Button("Quit Altar") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .font(.caption)
            .padding(.vertical, 6)
        }
        .frame(width: 280, height: 340)
    }
}
