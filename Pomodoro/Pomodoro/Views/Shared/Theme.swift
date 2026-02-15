import SwiftUI

// MARK: - Futuristic Theme (Light)

enum FuturisticTheme {
    static let background = Color.clear

    static func accentColor(for phase: TimerPhase) -> Color {
        switch phase {
        case .work: Color(red: 0.83, green: 0.36, blue: 0.33)
        case .shortBreak: Color(red: 0.33, green: 0.72, blue: 0.52)
        case .longBreak: Color(red: 0.40, green: 0.56, blue: 0.85)
        }
    }

    static let overtimeColor = Color(red: 0.88, green: 0.62, blue: 0.30)
    static let successColor = Color(red: 0.33, green: 0.72, blue: 0.52)

    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let surfaceDim = Color.primary.opacity(0.04)
}

// MARK: - Primary Button Style (capsule with soft shadow)

struct FuturisticPrimaryButtonStyle: ButtonStyle {
    let accent: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, minHeight: 36)
            .background(accent.opacity(configuration.isPressed ? 0.8 : 1.0))
            .clipShape(Capsule())
            .shadow(color: accent.opacity(0.3), radius: configuration.isPressed ? 2 : 6, y: 2)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Icon Button Style (circle with subtle border)

struct FuturisticIconButtonStyle: ButtonStyle {
    let accent: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(accent)
            .frame(width: 36, height: 36)
            .background(accent.opacity(configuration.isPressed ? 0.15 : 0.08))
            .clipShape(Circle())
            .overlay(Circle().stroke(accent.opacity(0.3), lineWidth: 1))
            .shadow(color: accent.opacity(0.15), radius: configuration.isPressed ? 1 : 4, y: 1)
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
