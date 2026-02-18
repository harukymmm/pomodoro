import SwiftUI

struct SessionRowView: View {
    let session: PomodoroSession

    private var durationText: String {
        if let actual = session.actualDurationSeconds {
            let m = actual / 60
            return "\(m)分"
        }
        return "--分"
    }

    private var dateText: String {
        session.startedAt.formatted(date: .abbreviated, time: .shortened)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(session.title)
                    .font(.body)
                    .lineLimit(1)

                Text(dateText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(durationText)
                    .font(.body.monospacedDigit())

                Image(systemName: session.isCompleted ? "checkmark.circle.fill" : "xmark.circle")
                    .foregroundStyle(session.isCompleted ? FuturisticTheme.successColor : .secondary)
                    .font(.caption)
            }
        }
        .padding(.vertical, 2)
    }
}
