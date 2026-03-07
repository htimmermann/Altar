//
//  StatusItemController.swift
//  Altar
//
//  Menu bar status item and popover.
//

import AppKit
import Combine
import SwiftUI

final class StatusItemController: ObservableObject {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private let timerViewModel: TimerViewModel
    private let taskStore: TaskStore
    private let historyStore: HistoryStore

    @Published var displayText: String = "25:00"

    init(timerViewModel: TimerViewModel, taskStore: TaskStore, historyStore: HistoryStore) {
        self.timerViewModel = timerViewModel
        self.taskStore = taskStore
        self.historyStore = historyStore
    }

    func setup() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        guard let button = statusItem?.button else { return }

        button.title = "25:00"
        button.action = #selector(togglePopover)
        button.target = self

        popover = NSPopover()
        popover?.behavior = .transient
        popover?.contentSize = NSSize(width: 280, height: 340)
        popover?.contentViewController = NSHostingController(
            rootView: MenuBarContentView()
                .environmentObject(timerViewModel)
                .environmentObject(taskStore)
                .environmentObject(historyStore)
        )

        timerViewModel.$remainingSeconds
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self, let btn = self.statusItem?.button else { return }
                let text = self.timerViewModel.displayText
                self.displayText = text
                btn.title = text
            }
            .store(in: &cancellables)
    }

    private var cancellables = Set<AnyCancellable>()

    @objc private func togglePopover() {
        guard let button = statusItem?.button, let popover = popover else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
}
