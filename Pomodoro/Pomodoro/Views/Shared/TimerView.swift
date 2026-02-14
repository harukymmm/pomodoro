import SwiftUI

struct TimerView: View {
    let remainingSeconds: Int
    let totalSeconds: Int
    let progress: Double
    let phase: TimerPhase
    let state: TimerState

    private var ringColor: Color {
        switch phase {
        case .work: .red
        case .shortBreak: .green
        case .longBreak: .blue
        }
    }

    private var displayTime: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%d:%02d", m, s)
    }

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(ringColor.opacity(0.2), lineWidth: 12)

            // Progress ring
            Circle()
                .trim(from: 0, to: CGFloat(1.0 - progress))
                .stroke(ringColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.5), value: progress)

            // Time display
            VStack(spacing: 4) {
                Text(displayTime)
                    .font(.system(size: 48, weight: .light, design: .monospaced))
                    .contentTransition(.numericText())

                Text(phase.displayName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(8)
    }
}
