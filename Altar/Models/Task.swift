//
//  Task.swift
//  Altar
//
//  Task model for Pomodoro tracking.
//

import Foundation

struct FocusTask: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var notes: String?
    var isCompleted: Bool
    var completedPomodoros: Int

    init(
        id: UUID = UUID(),
        title: String,
        notes: String? = nil,
        isCompleted: Bool = false,
        completedPomodoros: Int = 0
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.isCompleted = isCompleted
        self.completedPomodoros = completedPomodoros
    }
}
