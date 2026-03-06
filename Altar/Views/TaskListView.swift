//
//  TaskListView.swift
//  Altar
//
//  Task list with add, complete, delete.
//

import SwiftUI

struct TaskListView: View {
    @EnvironmentObject var taskStore: TaskStore
    @State private var newTaskTitle = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                TextField("New task", text: $newTaskTitle)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { addTask() }
                Button("Add") { addTask() }
            }
            .padding()

            List {
                ForEach(taskStore.tasks) { task in
                    HStack {
                        Button(action: { taskStore.toggleCompleted(task) }) {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        }
                        .buttonStyle(.plain)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(task.title)
                                .strikethrough(task.isCompleted)
                                .foregroundStyle(task.isCompleted ? .secondary : .primary)
                            if task.completedPomodoros > 0 {
                                Text("\(task.completedPomodoros) pomodoro\(task.completedPomodoros == 1 ? "" : "s")")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Spacer()

                        Button(role: .destructive) { taskStore.deleteTask(task) } label: {
                            Image(systemName: "trash")
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    private func addTask() {
        taskStore.addTask(title: newTaskTitle)
        newTaskTitle = ""
    }
}
