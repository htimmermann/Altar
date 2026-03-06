//
//  SessionHistory.swift
//  Altar
//
//  Session record for history and reports.
//

import Foundation

struct SessionRecord: Identifiable, Codable {
    let id: UUID
    let taskId: UUID?
    let type: SessionType
    let startDate: Date
    let endDate: Date
    let durationSeconds: Int
    let wasCompleted: Bool

    init(
        id: UUID = UUID(),
        taskId: UUID?,
        type: SessionType,
        startDate: Date,
        endDate: Date,
        durationSeconds: Int,
        wasCompleted: Bool
    ) {
        self.id = id
        self.taskId = taskId
        self.type = type
        self.startDate = startDate
        self.endDate = endDate
        self.durationSeconds = durationSeconds
        self.wasCompleted = wasCompleted
    }
}
