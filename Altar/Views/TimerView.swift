//
//  TimerView.swift
//  Altar
//
//  Pomodoro timer display and controls.
//

import SwiftUI

struct TimerView: View {
    private static let noTaskSentinel = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!

    @EnvironmentObject var timerViewModel: TimerViewModel
    @EnvironmentObject var taskStore: TaskStore
    @EnvironmentObject var historyStore: HistoryStore

    var body: some View {
        VStack(spacing: 16) {
            Text(timerViewModel.sessionLabel)
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(timerViewModel.displayText)
                .font(.system(size: 48, weight: .light, design: .monospaced))

            HStack(spacing: 12) {
                if timerViewModel.isRunning {
                    Button("Pause") { timerViewModel.pause() }
                } else {
                    Button("Start") { timerViewModel.start() }
                }
                if timerViewModel.currentSessionType != nil {
                    Button("Skip") { timerViewModel.skip() }
                    Button("Reset") { timerViewModel.reset() }
                }
            }

            if !taskStore.tasks.isEmpty {
                Picker("Task", selection: Binding(
                    get: { timerViewModel.activeTask?.id ?? TimerView.noTaskSentinel },
                    set: { id in
                        if id == TimerView.noTaskSentinel {
                            timerViewModel.activeTask = nil
                        } else {
                            timerViewModel.activeTask = taskStore.task(byId: id)
                        }
                    }
                )) {
                    Text("No task").tag(TimerView.noTaskSentinel)
                    ForEach(taskStore.tasks.filter { !$0.isCompleted }) { task in
                        Text(task.title).tag(task.id)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
            }

            let todayCount = historyStore.focusSessionsCount(for: Date())
            if todayCount > 0 {
                Text("Today: \(todayCount) focus session\(todayCount == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}
