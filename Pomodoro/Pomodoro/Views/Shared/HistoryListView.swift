import SwiftUI
import SwiftData

struct HistoryListView: View {
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
        Group {
            if sessions.isEmpty {
                ContentUnavailableView(
                    "履歴がありません",
                    systemImage: "clock",
                    description: Text("作業セッションを完了すると、ここに表示されます。")
                )
            } else {
                List {
                    ForEach(groupedByDay, id: \.date) { day in
                        Section {
                            ForEach(day.sessions) { session in
                                SessionRowView(session: session)
                            }
                        } header: {
                            HStack {
                                Text(day.date.formatted(date: .abbreviated, time: .omitted))
                                Spacer()
                                let completedSets = day.sessions.filter(\.isCompleted).count
                                if Calendar.current.isDateInToday(day.date) {
                                    Text("合計 \(day.totalMinutes)分 (\(completedSets)/\(appSettings.dailyTargetSets)セット)")
                                } else {
                                    Text("合計 \(day.totalMinutes)分 (\(completedSets)セット)")
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("履歴")
    }
}
