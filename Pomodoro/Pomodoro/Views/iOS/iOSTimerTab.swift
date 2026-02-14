import SwiftUI

#if os(iOS)
struct iOSTimerTab: View {
    @Bindable var timerService: TimerService

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            SessionTitleInput(
                title: $timerService.sessionTitle,
                isEditable: timerService.state == .idle || timerService.state == .completed
            )
            .padding(.horizontal, 32)

            TimerView(
                remainingSeconds: timerService.remainingSeconds,
                totalSeconds: timerService.totalSeconds,
                progress: timerService.progress,
                phase: timerService.currentPhase,
                state: timerService.state
            )
            .frame(width: 250, height: 250)

            TimerControlsView(
                state: timerService.state,
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
    }
}
#endif
