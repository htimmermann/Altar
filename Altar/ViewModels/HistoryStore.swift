//
//  HistoryStore.swift
//  Altar
//
//  Session history state and persistence.
//

import Foundation
import Combine

final class HistoryStore: ObservableObject {
    @Published var sessions: [SessionRecord] = []

    private let persistence = PersistenceService.shared

    init() {
        sessions = persistence.loadHistory()
        $sessions
            .dropFirst()
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [weak self] sessions in
                self?.persistence.saveHistory(sessions)
            }
            .store(in: &cancellables)
    }

    private var cancellables = Set<AnyCancellable>()

    func append(record: SessionRecord) {
        sessions.append(record)
    }

    func sessions(for date: Date) -> [SessionRecord] {
        let calendar = Calendar.current
        return sessions.filter { calendar.isDate($0.startDate, inSameDayAs: date) }
    }

    func sessions(in range: ClosedRange<Date>) -> [SessionRecord] {
        sessions.filter { range.contains($0.startDate) }
    }

    func totalFocusSeconds(for date: Date) -> Int {
        sessions(for: date)
            .filter { $0.type == .focus && $0.wasCompleted }
            .reduce(0) { $0 + $1.durationSeconds }
    }

    func totalFocusSeconds(in range: ClosedRange<Date>) -> Int {
        sessions(in: range)
            .filter { $0.type == .focus && $0.wasCompleted }
            .reduce(0) { $0 + $1.durationSeconds }
    }

    func focusSessionsCount(for date: Date) -> Int {
        sessions(for: date).filter { $0.type == .focus && $0.wasCompleted }.count
    }

    func focusSessionsCount(in range: ClosedRange<Date>) -> Int {
        sessions(in: range).filter { $0.type == .focus && $0.wasCompleted }.count
    }

    func focusSecondsByTask(in range: ClosedRange<Date>) -> [UUID: Int] {
        var result: [UUID: Int] = [:]
        for record in sessions(in: range) where record.type == .focus && record.wasCompleted {
            if let taskId = record.taskId {
                result[taskId, default: 0] += record.durationSeconds
            }
        }
        return result
    }

    func focusMinutesByDay(days: Int) -> [(date: Date, minutes: Int)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<days).reversed().map { offset in
            let day = calendar.date(byAdding: .day, value: -offset, to: today)!
            let secs = totalFocusSeconds(for: day)
            return (date: day, minutes: secs / 60)
        }
    }
}
