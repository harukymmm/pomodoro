import SwiftUI

struct TimerControlsView: View {
    let state: TimerState
    let phase: TimerPhase
    let currentSetDisplay: String
    let onStart: () -> Void
    let onPause: () -> Void
    let onResume: () -> Void
    let onReset: () -> Void
    let onSkip: () -> Void

    private var accent: Color { FuturisticTheme.accentColor(for: phase) }

    var body: some View {
        VStack(spacing: 12) {
            Text(currentSetDisplay)
                .font(.caption)
                .foregroundStyle(FuturisticTheme.textSecondary)

            HStack(spacing: 20) {
                switch state {
                case .idle, .completed:
                    Button(action: onStart) {
                        Label("開始", systemImage: "play.fill")
                    }
                    .buttonStyle(FuturisticPrimaryButtonStyle(accent: accent))

                case .running:
                    Button(action: onPause) {
                        Label("一時停止", systemImage: "pause.fill")
                    }
                    .buttonStyle(FuturisticPrimaryButtonStyle(accent: accent))

                    Button(action: onSkip) {
                        Image(systemName: "forward.fill")
                    }
                    .buttonStyle(FuturisticIconButtonStyle(accent: accent))
                    .help("スキップ")

                case .paused:
                    Button(action: onReset) {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    .buttonStyle(FuturisticIconButtonStyle(accent: accent))
                    .help("リセット")

                    Button(action: onResume) {
                        Label("再開", systemImage: "play.fill")
                    }
                    .buttonStyle(FuturisticPrimaryButtonStyle(accent: .green))

                    Button(action: onSkip) {
                        Image(systemName: "forward.fill")
                    }
                    .buttonStyle(FuturisticIconButtonStyle(accent: accent))
                    .help("スキップ")
                }
            }
        }
    }
}
