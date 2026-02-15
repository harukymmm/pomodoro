import SwiftUI
import SwiftData

#if os(macOS)
struct MenuBarHistoryView: View {
    @Query(
        filter: #Predicate<PomodoroSession> { $0.phaseRawValue == "work" },
        sort: \PomodoroSession.startedAt,
        order: .reverse
    )
    private var sessions: [PomodoroSession]

    private var filteredSessions: [PomodoroSession] {
        sessions.filter { ($0.actualDurationSeconds ?? 0) >= 60 }
    }

    private var groupedByDay: [(date: Date, totalMinutes: Int, sessions: [PomodoroSession])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredSessions) { session in
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
        if filteredSessions.isEmpty {
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
                            Text("合計 \(day.totalMinutes)分")
                                .font(.caption)
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
