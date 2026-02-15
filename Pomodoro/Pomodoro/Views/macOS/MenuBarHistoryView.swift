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

    var body: some View {
        if sessions.isEmpty {
            Text("履歴がありません")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, minHeight: 100)
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(sessions) { session in
                        SessionRowView(session: session)
                            .padding(.horizontal)
                        Divider()
                    }
                }
            }
            .frame(maxHeight: 400)
        }
    }
}
#endif
