//
//  TimerViewModel.swift
//  Altar
//
//  Pomodoro timer state machine and session logic.
//

import AppKit
import Foundation
import Combine

final class TimerViewModel: ObservableObject {
    @Published var currentSessionType: SessionType?
    @Published var remainingSeconds: Int = 0
    @Published var isRunning: Bool = false
    @Published var completedFocusSessionsInCycle: Int = 0
    @Published var activeTask: FocusTask?
    @Published var showTasksTab: Bool = false
    @Published var barColorHex: String = "007AFF"
    @Published var dailyGoalMinutes: Int = 120
    @Published var weeklyGoalMinutes: Int = 600

    private var workTimer: Timer?
    private var sessionStartDate: Date?
    /// Focus time already written to history for the current focus slot (pause/skip/complete chunks).
    private var sessionRecordedFocusSeconds: Int = 0
    private let historyStore: HistoryStore
    private let taskStore: TaskStore
    private var wasRunningBeforeSleep = false

    var focusDurationMinutes: Int = 25
    var shortBreakMinutes: Int = 5
    var longBreakMinutes: Int = 15
    var sessionsBeforeLongBreak: Int = 4
    var autoStartNextSession: Bool = false

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
        observeScreenSleep()
    }

    func configure(settings: TimerSettings) {
        focusDurationMinutes = settings.focusDurationMinutes
        shortBreakMinutes = settings.shortBreakMinutes
        longBreakMinutes = settings.longBreakMinutes
        sessionsBeforeLongBreak = settings.sessionsBeforeLongBreak
        autoStartNextSession = settings.autoStartNextSession
        showTasksTab = settings.showTasksTab
        barColorHex = settings.barColorHex
        dailyGoalMinutes = settings.dailyGoalMinutes
        weeklyGoalMinutes = settings.weeklyGoalMinutes
    }

    // MARK: - Screen lock / sleep detection

    private func observeScreenSleep() {
        // Direct lock/unlock events (fires immediately on Cmd+Ctrl+Q or menu lock)
        DistributedNotificationCenter.default().addObserver(
            self, selector: #selector(handleLock),
            name: NSNotification.Name("com.apple.screenIsLocked"), object: nil
        )

        // System sleep (lid close, sleep menu item)
        let ws = NSWorkspace.shared.notificationCenter
        ws.addObserver(self, selector: #selector(handleLock), name: NSWorkspace.willSleepNotification, object: nil)
        ws.addObserver(self, selector: #selector(handleLock), name: NSWorkspace.screensDidSleepNotification, object: nil)
    }

    @objc private func handleLock() {
        wasRunningBeforeSleep = isRunning
        pause()
        if wasRunningBeforeSleep, currentSessionType == .focus {
            appendFocusChunk(wasCompleted: false)
        }
    }

    // MARK: - Timer controls

    func start() {
        if currentSessionType == nil {
            currentSessionType = .focus
            remainingSeconds = focusDurationMinutes * 60
            sessionStartDate = Date()
            sessionRecordedFocusSeconds = 0
        }
        startTimer()
    }

    /// Stops the timer without recording partial focus time (used before recording completion chunks).
    func pause() {
        isRunning = false
        workTimer?.invalidate()
        workTimer = nil
    }

    /// Pause from the UI or sleep: commits elapsed focus time so far to history and reports.
    func pauseRecordingPartialFocus() {
        pause()
        if currentSessionType == .focus {
            appendFocusChunk(wasCompleted: false)
        }
    }

    func reset() {
        pause()
        if currentSessionType == .focus {
            appendFocusChunk(wasCompleted: false)
        }
        sessionRecordedFocusSeconds = 0
        if let type = currentSessionType {
            remainingSeconds = durationSeconds(for: type)
            sessionStartDate = Date()
        }
    }

    func skip() {
        pause()
        if let t = currentSessionType {
            if t == .focus {
                appendFocusChunk(wasCompleted: false)
            } else {
                let unrecorded = durationSeconds(for: t) - remainingSeconds
                if unrecorded > 0, let start = sessionStartDate {
                    let end = Date()
                    let record = SessionRecord(
                        taskId: activeTask?.id,
                        type: t,
                        startDate: start,
                        endDate: end,
                        durationSeconds: unrecorded,
                        wasCompleted: false
                    )
                    historyStore.append(record: record)
                }
            }
        }
        advanceToNextSession()
    }

    private func startTimer() {
        workTimer?.invalidate()
        isRunning = true
        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(timer, forMode: .common)
        workTimer = timer
    }

    private func tick() {
        guard isRunning else { return }
        remainingSeconds -= 1
        if remainingSeconds <= 0 {
            remainingSeconds = 0
            completeCurrentSession()
        }
    }

    private func completeCurrentSession() {
        pause()
        guard let type = currentSessionType else { return }

        if type == .focus {
            appendFocusChunk(wasCompleted: true)
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
            guard let start = sessionStartDate else { return }
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
            NotificationService.shared.notify(
                title: "Break complete",
                body: "Ready for another focus session."
            )
        }

        advanceToNextSession()
    }

    private func appendFocusChunk(wasCompleted: Bool) {
        guard currentSessionType == .focus, let start = sessionStartDate else { return }
        let slot = durationSeconds(for: .focus)
        let elapsedUnrecorded = slot - remainingSeconds - sessionRecordedFocusSeconds
        guard elapsedUnrecorded > 0 else { return }
        let end = Date()
        let record = SessionRecord(
            taskId: activeTask?.id,
            type: .focus,
            startDate: start,
            endDate: end,
            durationSeconds: elapsedUnrecorded,
            wasCompleted: wasCompleted
        )
        historyStore.append(record: record)
        sessionRecordedFocusSeconds += elapsedUnrecorded
        sessionStartDate = end
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
            sessionRecordedFocusSeconds = 0
        }
        sessionStartDate = Date()

        if autoStartNextSession {
            startTimer()
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
