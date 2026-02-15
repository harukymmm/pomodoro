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
                    timerFont: appSettings.timerFont,
                    isInOvertime: timerService.isInOvertime,
                    overtimeSeconds: timerService.overtimeSeconds
                )
                .frame(width: 180, height: 180)

                TimerControlsView(
                    state: timerService.state,
                    phase: timerService.currentPhase,
                    currentSetDisplay: timerService.currentSetDisplay,
                    dailySetDisplay: timerService.dailySetDisplay,
                    onStart: { timerService.start() },
                    onPause: { timerService.pause() },
                    onResume: { timerService.resume() },
                    onReset: { timerService.reset() },
                    onSkip: { timerService.skip() },
                    isInOvertime: timerService.isInOvertime,
                    onFinishOvertime: { timerService.finishOvertime() }
                )

            case .history:
                MenuBarHistoryView(appSettings: appSettings)

            case .settings:
                SettingsView(appSettings: appSettings)
            }
        }
        .padding()
        .frame(width: 280)
        .background(FuturisticTheme.background)
        .alert("延長時間の記録", isPresented: $timerService.showOvertimeChoice) {
            Button("合計時間を記録") {
                timerService.confirmOvertimeChoice(includeOvertime: true)
            }
            Button("標準時間のみ記録") {
                timerService.confirmOvertimeChoice(includeOvertime: false)
            }
        } message: {
            let total = (timerService.totalSeconds / 60) + timerService.overtimeMinutes
            Text("延長 \(timerService.overtimeMinutes)分を含む合計 \(total)分を記録しますか？")
        }
    }
}
#endif
