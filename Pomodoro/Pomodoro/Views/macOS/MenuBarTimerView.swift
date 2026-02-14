import SwiftUI

#if os(macOS)
struct MenuBarTimerView: View {
    @Bindable var timerService: TimerService

    var body: some View {
        VStack(spacing: 16) {
            SessionTitleInput(
                title: $timerService.sessionTitle,
                isEditable: timerService.state == .idle || timerService.state == .completed
            )

            TimerView(
                remainingSeconds: timerService.remainingSeconds,
                totalSeconds: timerService.totalSeconds,
                progress: timerService.progress,
                phase: timerService.currentPhase,
                state: timerService.state
            )
            .frame(width: 180, height: 180)

            TimerControlsView(
                state: timerService.state,
                currentSetDisplay: timerService.currentSetDisplay,
                onStart: { timerService.start() },
                onPause: { timerService.pause() },
                onResume: { timerService.resume() },
                onReset: { timerService.reset() },
                onSkip: { timerService.skip() }
            )
        }
        .padding()
        .frame(width: 280)
    }
}
#endif
