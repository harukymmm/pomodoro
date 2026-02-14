import SwiftUI

#if os(iOS)
struct iOSContentView: View {
    var timerService: TimerService

    var body: some View {
        TabView {
            NavigationStack {
                iOSTimerTab(timerService: timerService)
            }
            .tabItem {
                Label("タイマー", systemImage: "timer")
            }

            NavigationStack {
                HistoryListView()
            }
            .tabItem {
                Label("履歴", systemImage: "clock.arrow.circlepath")
            }

            NavigationStack {
                StatisticsView()
            }
            .tabItem {
                Label("統計", systemImage: "chart.bar")
            }
        }
    }
}
#endif
