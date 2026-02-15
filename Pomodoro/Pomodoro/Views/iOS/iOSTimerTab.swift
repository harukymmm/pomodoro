import SwiftUI

#if os(iOS)
struct iOSTimerTab: View {
    @Bindable var timerService: TimerService
    var appSettings: AppSettings

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            SessionTitleInput(
                title: $timerService.sessionTitle,
                isEditable: timerService.state == .idle || timerService.state == .completed,
                phase: timerService.currentPhase
            )
            .padding(.horizontal, 32)

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
            .frame(width: 250, height: 250)

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

            Spacer()
        }
        .navigationTitle("タイマー")
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
