//
//  TimerViewModel.swift
//  Altar
//
//  Pomodoro timer state machine and session logic.
//

import Foundation
import Combine

final class TimerViewModel: ObservableObject {
    @Published var currentSessionType: SessionType?
    @Published var remainingSeconds: Int = 0
    @Published var isRunning: Bool = false
    @Published var completedFocusSessionsInCycle: Int = 0
    @Published var activeTask: FocusTask?

    private var workTimer: Timer?
    private var sessionStartDate: Date?
    private let historyStore: HistoryStore
    private let taskStore: TaskStore

    var focusDurationMinutes: Int = 25
    var shortBreakMinutes: Int = 5
    var longBreakMinutes: Int = 15
    var sessionsBeforeLongBreak: Int = 4
    var autoStartNextSession: Bool = true

    var displayText: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    var sessionLabel: String {
        currentSessionType?.displayName ?? "Idle"
    }

    init(historyStore: HistoryStore, taskStore: TaskStore) {
        self.historyStore = historyStore
        self.taskStore = taskStore
    }

    func configure(settings: TimerSettings) {
        focusDurationMinutes = settings.focusDurationMinutes
        shortBreakMinutes = settings.shortBreakMinutes
        longBreakMinutes = settings.longBreakMinutes
        sessionsBeforeLongBreak = settings.sessionsBeforeLongBreak
        autoStartNextSession = settings.autoStartNextSession
    }

    func start() {
        if currentSessionType == nil {
            startFocus()
            return
        }
        isRunning = true
        workTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(workTimer!, forMode: .common)
    }

    func pause() {
        isRunning = false
        workTimer?.invalidate()
        workTimer = nil
    }

    func reset() {
        pause()
        if let type = currentSessionType {
            remainingSeconds = durationSeconds(for: type)
        }
    }

    func skip() {
        let type = currentSessionType
        let start = sessionStartDate ?? Date()
        let end = Date()
        if let t = type {
            let record = SessionRecord(
                taskId: activeTask?.id,
                type: t,
                startDate: start,
                endDate: end,
                durationSeconds: durationSeconds(for: t) - remainingSeconds,
                wasCompleted: false
            )
            historyStore.append(record: record)
        }

        advanceToNextSession()
    }

    private func startFocus() {
        currentSessionType = .focus
        remainingSeconds = focusDurationMinutes * 60
        sessionStartDate = Date()
        isRunning = true
        workTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(workTimer!, forMode: .common)
    }

    private func tick() {
        guard isRunning else { return }
        remainingSeconds -= 1
        if remainingSeconds <= 0 {
            completeCurrentSession()
        }
    }

    private func completeCurrentSession() {
        pause()
        guard let type = currentSessionType, let start = sessionStartDate else { return }
        let end = Date()
        let record = SessionRecord(
            taskId: activeTask?.id,
            type: type,
            startDate: start,
            endDate: end,
            durationSeconds: durationSeconds(for: type),
            wasCompleted: true
        )
        historyStore.append(record: record)

        if type == .focus {
            if let taskId = activeTask?.id {
                taskStore.incrementPomodoros(for: taskId)
                if let t = taskStore.task(byId: taskId) {
                    activeTask = t
                }
            }
            completedFocusSessionsInCycle += 1
            NotificationService.shared.notify(
                title: "Focus session complete",
                body: "Time for a break."
            )
        } else {
            NotificationService.shared.notify(
                title: "Break complete",
                body: "Ready for another focus session."
            )
        }

        advanceToNextSession()
    }

    private func advanceToNextSession() {
        if currentSessionType == .focus {
            let isLongBreak = completedFocusSessionsInCycle >= sessionsBeforeLongBreak
            if isLongBreak {
                completedFocusSessionsInCycle = 0
                currentSessionType = .longBreak
                remainingSeconds = longBreakMinutes * 60
            } else {
                currentSessionType = .shortBreak
                remainingSeconds = shortBreakMinutes * 60
            }
        } else {
            currentSessionType = .focus
            remainingSeconds = focusDurationMinutes * 60
        }
        sessionStartDate = Date()

        if autoStartNextSession {
            isRunning = true
            workTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                self?.tick()
            }
            RunLoop.main.add(workTimer!, forMode: .common)
        } else {
            isRunning = false
        }
    }

    private func durationSeconds(for type: SessionType) -> Int {
        switch type {
        case .focus: return focusDurationMinutes * 60
        case .shortBreak: return shortBreakMinutes * 60
        case .longBreak: return longBreakMinutes * 60
        }
    }
}
