import SwiftUI

struct SessionTitleInput: View {
    @Binding var title: String
    let isEditable: Bool
    var phase: TimerPhase = .work

    private var accent: Color { FuturisticTheme.accentColor(for: phase) }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField("作業タイトル", text: $title, prompt: Text("作業タイトル").foregroundStyle(.secondary))
                .textFieldStyle(.plain)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.primary)
                .disabled(!isEditable)
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .background(.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 6))
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(isEditable ? accent : Color.secondary.opacity(0.3))
                        .frame(height: 1.5)
                }
                #if os(iOS)
                .textInputAutocapitalization(.never)
                #endif

            if !isEditable {
                Text("一時停止すると編集できます")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .padding(.leading, 8)
            }
        }
    }
}
