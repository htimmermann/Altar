//
//  ReportsView.swift
//  Altar
//
//  Focus time reports with bar chart and goal line.
//

import SwiftUI

struct ReportsView: View {
    @EnvironmentObject var historyStore: HistoryStore
    @EnvironmentObject var taskStore: TaskStore
    @EnvironmentObject var timerViewModel: TimerViewModel
    @State private var selectedRange: ReportRange = .week

    enum ReportRange: String, CaseIterable {
        case week = "7 days"
        case month = "30 days"
        case all = "All"
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

                DailyBarChart(
                    data: chartData,
                    goalMinutes: goalMinutesPerBar,
                    barColor: Color(hex: timerViewModel.barColorHex)
                )
                .frame(height: 120)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }

    private var dayCount: Int {
        switch selectedRange {
        case .week: return 7
        case .month: return 30
        case .all:
            guard let earliest = historyStore.sessions.map(\.startDate).min() else { return 7 }
            let days = Calendar.current.dateComponents([.day], from: earliest, to: Date()).day ?? 7
            return max(days + 1, 1)
        }
    }

    private var chartData: [(label: String, minutes: Int)] {
        let days = dayCount
        let formatter = DateFormatter()
        formatter.dateFormat = days <= 7 ? "E" : "M/d"
        return historyStore.focusMinutesByDay(days: days).map { item in
            (label: formatter.string(from: item.date), minutes: item.minutes)
        }
    }

    private var goalMinutesPerBar: Int {
        timerViewModel.dailyGoalMinutes
    }

    private var dateRange: ClosedRange<Date> {
        let now = Date()
        let start = Calendar.current.date(byAdding: .day, value: -(dayCount - 1), to: Calendar.current.startOfDay(for: now)) ?? now
        return start...now
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

// MARK: - Bar chart with goal line

struct DailyBarChart: View {
    let data: [(label: String, minutes: Int)]
    let goalMinutes: Int
    let barColor: Color

    private var maxMinutes: Int {
        let dataMax = data.map(\.minutes).max() ?? 0
        return max(dataMax, goalMinutes, 1)
    }

    var body: some View {
        GeometryReader { geo in
            let chartHeight = geo.size.height - 20
            let goalY = chartHeight - (CGFloat(goalMinutes) / CGFloat(maxMinutes) * chartHeight)

            ZStack(alignment: .topLeading) {
                HStack(alignment: .bottom, spacing: data.count > 14 ? 1 : 4) {
                    ForEach(Array(data.enumerated()), id: \.offset) { _, item in
                        VStack(spacing: 2) {
                            if item.minutes > 0 && data.count <= 14 {
                                Text("\(item.minutes)m")
                                    .font(.system(size: 7))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            RoundedRectangle(cornerRadius: 2)
                                .fill(item.minutes > 0 ? barColor : Color.secondary.opacity(0.12))
                                .frame(height: barHeight(item.minutes, chartHeight: chartHeight))
                            if data.count <= 14 {
                                Text(item.label)
                                    .font(.system(size: 8))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)

                if goalMinutes > 0 {
                    GoalLine()
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                        .foregroundStyle(.secondary)
                        .frame(height: 1)
                        .offset(y: goalY)
                }
            }
        }
    }

    private func barHeight(_ minutes: Int, chartHeight: CGFloat) -> CGFloat {
        let minH: CGFloat = 3
        guard minutes > 0 else { return minH }
        return max(minH, CGFloat(minutes) / CGFloat(maxMinutes) * (chartHeight - 20))
    }
}

struct GoalLine: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return p
    }
}
