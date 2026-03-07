//
//  TimerSettings.swift
//  Altar
//
//  Pomodoro timer configuration.
//

import Foundation

enum SessionType: String, Codable, CaseIterable {
    case focus
    case shortBreak
    case longBreak

    var displayName: String {
        switch self {
        case .focus: return "Focus"
        case .shortBreak: return "Short Break"
        case .longBreak: return "Long Break"
        }
    }
}

struct TimerSettings: Codable {
    var focusDurationMinutes: Int
    var shortBreakMinutes: Int
    var longBreakMinutes: Int
    var sessionsBeforeLongBreak: Int
    var autoStartNextSession: Bool
    var showTasksTab: Bool

    static let `default` = TimerSettings(
        focusDurationMinutes: 25,
        shortBreakMinutes: 5,
        longBreakMinutes: 15,
        sessionsBeforeLongBreak: 4,
        autoStartNextSession: false,
        showTasksTab: false
    )
}
