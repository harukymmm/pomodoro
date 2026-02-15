import SwiftUI

struct TimerView: View {
    let remainingSeconds: Int
    let totalSeconds: Int
    let progress: Double
    let phase: TimerPhase
    let state: TimerState
    let completedWorkSets: Int
    var timerFont: TimerFont = .systemRounded
    var isInOvertime: Bool = false
    var overtimeSeconds: Int = 0

    @State private var pulseScale: CGFloat = 1.0

    private let ringWidth: CGFloat = 10

    private var accent: Color { isInOvertime ? .orange : FuturisticTheme.accentColor(for: phase) }
    private var trimEnd: CGFloat { isInOvertime ? 1.0 : CGFloat(1.0 - progress) }

    private var displayTime: String {
        if isInOvertime {
            let m = overtimeSeconds / 60
            let s = overtimeSeconds % 60
            return String(format: "+%d:%02d", m, s)
        }
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%d:%02d", m, s)
    }

    var body: some View {
        ZStack {
            // 1. 背景トラック（全周を薄く）
            Circle()
                .stroke(accent.opacity(0.12), lineWidth: ringWidth)

            // 2. 残り時間アーク — 一色ベタ、時間経過で削られていく
            Circle()
                .trim(from: 0, to: trimEnd)
                .stroke(accent, style: StrokeStyle(lineWidth: ringWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.5), value: progress)

            // 4. パルスリング（running時のみ）
            if state == .running {
                Circle()
                    .stroke(accent.opacity(0.10), lineWidth: 1.5)
                    .scaleEffect(pulseScale)
                    .opacity(2.0 - Double(pulseScale))
                    .onAppear { startPulse() }
            }

            // 数字表示
            VStack(spacing: 2) {
                Text(displayTime)
                    .font(timerFont.font(size: 44, weight: .medium))
                    .monospacedDigit()
                    .kerning(2)
                    .foregroundStyle(FuturisticTheme.textPrimary)
                    .contentTransition(.numericText())

                Text(phase.displayName)
                    .font(timerFont.font(size: 12, weight: .medium))
                    .foregroundStyle(accent.opacity(0.7))
                    .textCase(.uppercase)
                    .kerning(1.5)

                if isInOvertime {
                    Text("延長中")
                        .font(timerFont.font(size: 11, weight: .semibold))
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding(8)
        .onChange(of: state) { _, newState in
            if newState == .running {
                startPulse()
            }
        }
    }

    // MARK: - Animations

    private func startPulse() {
        pulseScale = 1.0
        withAnimation(
            .easeOut(duration: 1.5)
            .repeatForever(autoreverses: false)
        ) {
            pulseScale = 1.15
        }
    }
}
