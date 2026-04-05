//
//  AltarApp.swift
//  Altar
//
//  Menu bar Pomodoro focus timer.
//

import SwiftUI
import AppKit

@main
struct AltarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings { EmptyView() }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItemController: StatusItemController?
    private let taskStore = TaskStore()
    private let historyStore = HistoryStore()
    private var timerViewModel: TimerViewModel?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let vm = TimerViewModel(historyStore: historyStore, taskStore: taskStore)
        timerViewModel = vm
        vm.configure(settings: SettingsManager.load())

        statusItemController = StatusItemController(
            timerViewModel: vm,
            taskStore: taskStore,
            historyStore: historyStore
        )
        statusItemController?.setup()

        NSApp.setActivationPolicy(.accessory)
    }

    func applicationWillTerminate(_ notification: Notification) {
        timerViewModel?.flushInFlightFocusForTermination()
        historyStore.persistImmediately()
    }
}
