//
//  ReportsView.swift
//  Altar
//
//  Basic focus time reports.
//

import SwiftUI

struct ReportsView: View {
    @EnvironmentObject var historyStore: HistoryStore
    @EnvironmentObject var taskStore: TaskStore
    @State private var selectedRange: ReportRange = .today

    enum ReportRange: String, CaseIterable {
        case today = "Today"
        case week = "This Week"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Range", selection: $selectedRange) {
                ForEach(ReportRange.allCases, id: \.self) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(.segmented)

            let (seconds, count) = stats
            VStack(alignment: .leading, spacing: 8) {
                Text("Total focus time: \(formattedDuration(seconds))")
                    .font(.headline)
                Text("\(count) focus session\(count == 1 ? "" : "s") completed")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if !taskBreakdown.isEmpty {
                Divider()
                Text("By task")
                    .font(.headline)
                ForEach(taskBreakdown, id: \.task.id) { item in
                    HStack {
                        Text(item.task.title)
                        Spacer()
                        Text(formattedDuration(item.seconds))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
    }

    private var dateRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let now = Date()
        switch selectedRange {
        case .today:
            let start = calendar.startOfDay(for: now)
            return start...now
        case .week:
            let start = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            return start...now
        }
    }

    private var stats: (seconds: Int, count: Int) {
        let sec = historyStore.totalFocusSeconds(in: dateRange)
        let cnt = historyStore.focusSessionsCount(in: dateRange)
        return (sec, cnt)
    }

    private var taskBreakdown: [(task: FocusTask, seconds: Int)] {
        let byTask = historyStore.focusSecondsByTask(in: dateRange)
        return byTask.compactMap { taskId, seconds in
            taskStore.task(byId: taskId).map { (task: $0, seconds: seconds) }
        }.sorted { $0.seconds > $1.seconds }
    }

    private func formattedDuration(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        if h > 0 {
            return "\(h)h \(m)m"
        }
        return "\(m)m"
    }
}
