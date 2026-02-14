import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    @Query(
        filter: #Predicate<PomodoroSession> { $0.phaseRawValue == "work" },
        sort: \PomodoroSession.startedAt,
        order: .reverse
    )
    private var sessions: [PomodoroSession]

    private var dailyStats: [DailyStat] {
        StatisticsService.dailyStats(sessions: sessions)
    }

    private var todayMinutes: Int {
        StatisticsService.todayTotal(sessions: sessions)
    }

    private var weekMinutes: Int {
        StatisticsService.weeklyTotal(sessions: sessions)
    }

    private var completedCount: Int {
        StatisticsService.completedSessionCount(sessions: sessions)
    }

    var body: some View {
        Group {
            if sessions.isEmpty {
                ContentUnavailableView(
                    "統計データがありません",
                    systemImage: "chart.bar",
                    description: Text("作業セッションを完了すると、統計が表示されます。")
                )
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        summaryCards
                        weeklyChart
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("統計")
    }

    private var summaryCards: some View {
        HStack(spacing: 12) {
            StatCard(title: "今日", value: "\(todayMinutes)", unit: "分")
            StatCard(title: "今週", value: "\(weekMinutes)", unit: "分")
            StatCard(title: "完了", value: "\(completedCount)", unit: "回")
        }
    }

    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("過去7日間")
                .font(.headline)

            Chart(dailyStats) { stat in
                BarMark(
                    x: .value("日付", stat.date, unit: .day),
                    y: .value("分", stat.totalMinutes)
                )
                .foregroundStyle(.red.gradient)
                .cornerRadius(4)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated), centered: true)
                }
            }
            .chartYAxis {
                AxisMarks { mark in
                    AxisGridLine()
                    AxisValueLabel {
                        if let val = mark.as(Int.self) {
                            Text("\(val)分")
                        }
                    }
                }
            }
            .frame(height: 200)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let unit: String

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2.bold())
            Text(unit)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
