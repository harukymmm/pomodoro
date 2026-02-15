import SwiftUI

struct TimerControlsView: View {
    let state: TimerState
    let phase: TimerPhase
    let currentSetDisplay: String
    let dailySetDisplay: String
    let onStart: () -> Void
    let onPause: () -> Void
    let onResume: () -> Void
    let onReset: () -> Void
    let onSkip: () -> Void
    var isInOvertime: Bool = false
    var onFinishOvertime: () -> Void = {}

    private var accent: Color {
        isInOvertime ? .orange : FuturisticTheme.accentColor(for: phase)
    }

    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 4) {
                Text(currentSetDisplay)
                    .font(.caption)
                    .foregroundStyle(FuturisticTheme.textSecondary)
                Text(dailySetDisplay)
                    .font(.caption2)
                    .foregroundStyle(FuturisticTheme.textSecondary.opacity(0.7))
            }

            HStack(spacing: 20) {
                switch state {
                case .idle, .completed:
                    Button(action: onStart) {
                        Label("開始", systemImage: "play.fill")
                    }
                    .buttonStyle(FuturisticPrimaryButtonStyle(accent: accent))

                case .running:
                    if isInOvertime {
                        Button(action: onFinishOvertime) {
                            Label("終了", systemImage: "stop.fill")
                        }
                        .buttonStyle(FuturisticPrimaryButtonStyle(accent: .orange))

                        Button(action: onPause) {
                            Image(systemName: "pause.fill")
                        }
                        .buttonStyle(FuturisticIconButtonStyle(accent: .orange))
                        .help("一時停止")
                    } else {
                        Button(action: onPause) {
                            Label("一時停止", systemImage: "pause.fill")
                        }
                        .buttonStyle(FuturisticPrimaryButtonStyle(accent: accent))

                        Button(action: onSkip) {
                            Image(systemName: "forward.fill")
                        }
                        .buttonStyle(FuturisticIconButtonStyle(accent: accent))
                        .help("スキップ")
                    }

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

                    if isInOvertime {
                        Button(action: onFinishOvertime) {
                            Image(systemName: "stop.fill")
                        }
                        .buttonStyle(FuturisticIconButtonStyle(accent: .orange))
                        .help("終了")
                    } else {
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
}
