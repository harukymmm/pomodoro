import SwiftUI

struct FontSelectionView: View {
    @Bindable var appSettings: AppSettings

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(TimerFont.allCases) { font in
                    FontCard(
                        font: font,
                        isSelected: appSettings.timerFont == font
                    ) {
                        appSettings.timerFontId = font.rawValue
                    }
                }
            }
            .padding()
        }
        .navigationTitle("フォント選択")
    }
}

private struct FontCard: View {
    let font: TimerFont
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text("25:00")
                    .font(font.font(size: 28, weight: .medium))
                    .monospacedDigit()

                Text("作業")
                    .font(font.font(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)

                Text(font.displayName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .contentShape(Rectangle())
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.primary.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}
