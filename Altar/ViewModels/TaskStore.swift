//
//  TaskStore.swift
//  Altar
//
//  Task list state and persistence.
//

import Foundation
import Combine

final class TaskStore: ObservableObject {
    @Published var tasks: [FocusTask] = []

    private let persistence = PersistenceService.shared

    init() {
        tasks = persistence.loadTasks()
        $tasks
            .dropFirst()
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [weak self] tasks in
                self?.persistence.saveTasks(tasks)
            }
            .store(in: &cancellables)
    }

    private var cancellables = Set<AnyCancellable>()

    func addTask(title: String, notes: String? = nil) {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let task = FocusTask(title: title.trimmingCharacters(in: .whitespacesAndNewlines), notes: notes)
        tasks.insert(task, at: 0)
    }

    func updateTask(_ task: FocusTask) {
        if let idx = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[idx] = task
        }
    }

    func toggleCompleted(_ task: FocusTask) {
        if let idx = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[idx].isCompleted.toggle()
        }
    }

    func deleteTask(_ task: FocusTask) {
        tasks.removeAll { $0.id == task.id }
    }

    func incrementPomodoros(for taskId: UUID) {
        if let idx = tasks.firstIndex(where: { $0.id == taskId }) {
            tasks[idx].completedPomodoros += 1
        }
    }

    func task(byId id: UUID) -> FocusTask? {
        tasks.first { $0.id == id }
    }
}
