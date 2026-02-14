import SwiftUI

struct TimerControlsView: View {
    let state: TimerState
    let currentSetDisplay: String
    let onStart: () -> Void
    let onPause: () -> Void
    let onResume: () -> Void
    let onReset: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text(currentSetDisplay)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                switch state {
                case .idle, .completed:
                    Button(action: onStart) {
                        Label("開始", systemImage: "play.fill")
                            .frame(minWidth: 80)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)

                case .running:
                    Button(action: onPause) {
                        Label("一時停止", systemImage: "pause.fill")
                            .frame(minWidth: 80)
                    }
                    .buttonStyle(.bordered)

                    Button(action: onSkip) {
                        Label("スキップ", systemImage: "forward.fill")
                    }
                    .buttonStyle(.bordered)

                case .paused:
                    Button(action: onResume) {
                        Label("再開", systemImage: "play.fill")
                            .frame(minWidth: 80)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)

                    Button(action: onReset) {
                        Label("リセット", systemImage: "arrow.counterclockwise")
                    }
                    .buttonStyle(.bordered)

                    Button(action: onSkip) {
                        Label("スキップ", systemImage: "forward.fill")
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }
}
