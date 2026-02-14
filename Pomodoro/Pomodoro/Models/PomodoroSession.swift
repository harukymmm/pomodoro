import Foundation
import SwiftData

@Model
final class PomodoroSession {
    var id: UUID
    var title: String
    var startedAt: Date
    var completedAt: Date?
    var durationSeconds: Int
    var actualDurationSeconds: Int?
    var phaseRawValue: String
    var isCompleted: Bool

    var phase: TimerPhase {
        get { TimerPhase(rawValue: phaseRawValue) ?? .work }
        set { phaseRawValue = newValue.rawValue }
    }

    init(
        title: String,
        phase: TimerPhase,
        durationSeconds: Int,
        startedAt: Date = .now
    ) {
        self.id = UUID()
        self.title = title
        self.startedAt = startedAt
        self.durationSeconds = durationSeconds
        self.phaseRawValue = phase.rawValue
        self.isCompleted = false
    }

    func complete(actualSeconds: Int) {
        self.completedAt = .now
        self.actualDurationSeconds = actualSeconds
        self.isCompleted = true
    }

    func cancel(elapsedSeconds: Int) {
        self.completedAt = .now
        self.actualDurationSeconds = elapsedSeconds
        self.isCompleted = false
    }
}
