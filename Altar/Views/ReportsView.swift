//
//  ReportsView.swift
//  Altar
//
//  Basic focus time reports with bar chart.
//

import SwiftUI

struct ReportsView: View {
    @EnvironmentObject var historyStore: HistoryStore
    @EnvironmentObject var taskStore: TaskStore
    @State private var selectedRange: ReportRange = .week

    enum ReportRange: String, CaseIterable {
        case today = "Today"
        case week = "This Week"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Picker("Range", selection: $selectedRange) {
                    ForEach(ReportRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)

                let (seconds, count) = stats
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total: \(formattedDuration(seconds))")
                        .font(.headline)
                    Text("\(count) session\(count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                DailyBarChart(data: chartData)
                    .frame(height: 100)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }

    private var chartData: [(label: String, minutes: Int)] {
        let days = selectedRange == .today ? 1 : 7
        let formatter = DateFormatter()
        formatter.dateFormat = days == 1 ? "EEE" : "E"
        return historyStore.focusMinutesByDay(days: days).map { item in
            (label: formatter.string(from: item.date), minutes: item.minutes)
        }
    }

    private var dateRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let now = Date()
        switch selectedRange {
        case .today:
            return calendar.startOfDay(for: now)...now
        case .week:
            let start = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            return start...now
        }
    }

    private var stats: (seconds: Int, count: Int) {
        (historyStore.totalFocusSeconds(in: dateRange),
         historyStore.focusSessionsCount(in: dateRange))
    }

    private func formattedDuration(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        if h > 0 { return "\(h)h \(m)m" }
        return "\(m)m"
    }
}

struct DailyBarChart: View {
    let data: [(label: String, minutes: Int)]

    private var maxMinutes: Int {
        max(data.map(\.minutes).max() ?? 1, 1)
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            ForEach(Array(data.enumerated()), id: \.offset) { _, item in
                VStack(spacing: 2) {
                    if item.minutes > 0 {
                        Text("\(item.minutes)m")
                            .font(.system(size: 8))
                            .foregroundStyle(.secondary)
                    }
                    RoundedRectangle(cornerRadius: 3)
                        .fill(item.minutes > 0 ? Color.accentColor : Color.secondary.opacity(0.15))
                        .frame(height: barHeight(for: item.minutes))
                    Text(item.label)
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func barHeight(for minutes: Int) -> CGFloat {
        let maxH: CGFloat = 70
        let minH: CGFloat = 4
        guard minutes > 0 else { return minH }
        return max(minH, CGFloat(minutes) / CGFloat(maxMinutes) * maxH)
    }
}
