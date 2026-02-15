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
                timerFont: appSettings.timerFont
            )
            .frame(width: 250, height: 250)

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

            Spacer()
        }
        .navigationTitle("タイマー")
        .background(FuturisticTheme.background)
    }
}
#endif
