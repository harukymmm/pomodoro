import SwiftUI

#if os(iOS)
struct iOSContentView: View {
    var timerService: TimerService
    var appSettings: AppSettings

    var body: some View {
        TabView {
            NavigationStack {
                iOSTimerTab(timerService: timerService, appSettings: appSettings)
            }
            .tabItem {
                Label("タイマー", systemImage: "timer")
            }

            NavigationStack {
                HistoryListView(appSettings: appSettings)
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

            NavigationStack {
                SettingsView(appSettings: appSettings)
            }
            .tabItem {
                Label("設定", systemImage: "gearshape")
            }
        }
    }
}
#endif
