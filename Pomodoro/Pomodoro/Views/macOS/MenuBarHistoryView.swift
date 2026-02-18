import SwiftUI
import SwiftData

#if os(macOS)
struct MenuBarHistoryView: View {
    var appSettings: AppSettings

    @Query(
        filter: #Predicate<PomodoroSession> { $0.phaseRawValue == "work" },
        sort: \PomodoroSession.startedAt,
        order: .reverse
    )
    private var sessions: [PomodoroSession]

    private var groupedByDay: [(date: Date, totalMinutes: Int, sessions: [PomodoroSession])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: sessions) { session in
            calendar.startOfDay(for: session.startedAt)
        }
        return grouped
            .map { date, sessions in
                let total = sessions.compactMap(\.actualDurationSeconds).reduce(0, +) / 60
                return (date: date, totalMinutes: total, sessions: sessions)
            }
            .sorted { $0.date > $1.date }
    }

    var body: some View {
        if sessions.isEmpty {
            Text("履歴がありません")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, minHeight: 100)
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(groupedByDay, id: \.date) { day in
                        HStack {
                            Text(day.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption.bold())
                            Spacer()
                            let completedSets = day.sessions.filter(\.isCompleted).count
                            if Calendar.current.isDateInToday(day.date) {
                                Text("合計 \(day.totalMinutes)分 (\(completedSets)/\(appSettings.dailyTargetSets)セット)")
                                    .font(.caption)
                            } else {
                                Text("合計 \(day.totalMinutes)分 (\(completedSets)セット)")
                                    .font(.caption)
                            }

                            Button {
                                let text = StatisticsService.formatDailySummary(date: day.date, sessions: day.sessions)
                                StatisticsService.copyToClipboard(text)
                            } label: {
                                Image(systemName: "doc.on.doc")
                                    .font(.caption)
                            }
                            .buttonStyle(.borderless)
                        }
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .padding(.bottom, 4)

                        ForEach(day.sessions) { session in
                            SessionRowView(session: session)
                                .padding(.horizontal)
                            Divider()
                        }
                    }
                }
            }
            .frame(maxHeight: 400)
        }
    }
}
#endif
