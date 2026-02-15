import SwiftUI

#if os(macOS)
struct MenuBarTimerView: View {
    @Bindable var timerService: TimerService
    var appSettings: AppSettings
    @State private var selectedTab: Tab = .timer

    private enum Tab: String, CaseIterable {
        case timer = "タイマー"
        case history = "履歴"
        case settings = "設定"
    }

    var body: some View {
        VStack(spacing: 16) {
            Picker("", selection: $selectedTab) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            switch selectedTab {
            case .timer:
                SessionTitleInput(
                    title: $timerService.sessionTitle,
                    isEditable: timerService.state == .idle || timerService.state == .completed,
                    phase: timerService.currentPhase
                )

                TimerView(
                    remainingSeconds: timerService.remainingSeconds,
                    totalSeconds: timerService.totalSeconds,
                    progress: timerService.progress,
                    phase: timerService.currentPhase,
                    state: timerService.state,
                    completedWorkSets: timerService.completedWorkSets,
                    timerFont: appSettings.timerFont
                )
                .frame(width: 180, height: 180)

                TimerControlsView(
                    state: timerService.state,
                    phase: timerService.currentPhase,
                    currentSetDisplay: timerService.currentSetDisplay,
                    onStart: { timerService.start() },
                    onPause: { timerService.pause() },
                    onResume: { timerService.resume() },
                    onReset: { timerService.reset() },
                    onSkip: { timerService.skip() }
                )

            case .history:
                MenuBarHistoryView()

            case .settings:
                NavigationStack {
                    SettingsView(appSettings: appSettings)
                }
            }
        }
        .padding()
        .frame(width: 280)
        .background(FuturisticTheme.background)
    }
}
#endif
