import SwiftUI
import SwiftData

struct HistoryListView: View {
    @Query(
        filter: #Predicate<PomodoroSession> { $0.phaseRawValue == "work" },
        sort: \PomodoroSession.startedAt,
        order: .reverse
    )
    private var sessions: [PomodoroSession]

    var body: some View {
        Group {
            if sessions.isEmpty {
                ContentUnavailableView(
                    "履歴がありません",
                    systemImage: "clock",
                    description: Text("作業セッションを完了すると、ここに表示されます。")
                )
            } else {
                List(sessions) { session in
                    SessionRowView(session: session)
                }
            }
        }
        .navigationTitle("履歴")
    }
}
