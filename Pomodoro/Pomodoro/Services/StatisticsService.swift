import Foundation
import SwiftData

struct DailyStat: Identifiable {
    var id: Date { date }
    let date: Date
    let totalMinutes: Int
    let sessionCount: Int
}

@MainActor
struct StatisticsService {

    static func todayTotal(sessions: [PomodoroSession]) -> Int {
        let today = Calendar.current.startOfDay(for: .now)
        return sessions
            .filter { $0.phaseRawValue == TimerPhase.work.rawValue && Calendar.current.startOfDay(for: $0.startedAt) == today }
            .compactMap(\.actualDurationSeconds)
            .reduce(0, +) / 60
    }

    static func weeklyTotal(sessions: [PomodoroSession]) -> Int {
        guard let weekStart = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: .now)) else {
            return 0
        }
        return sessions
            .filter { $0.phaseRawValue == TimerPhase.work.rawValue && $0.startedAt >= weekStart }
            .compactMap(\.actualDurationSeconds)
            .reduce(0, +) / 60
    }

    static func completedSessionCount(sessions: [PomodoroSession]) -> Int {
        sessions.filter { $0.phaseRawValue == TimerPhase.work.rawValue && $0.isCompleted }.count
    }

    static func dailyStats(sessions: [PomodoroSession], days: Int = 7) -> [DailyStat] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        let workSessions = sessions.filter { $0.phaseRawValue == TimerPhase.work.rawValue }

        return (0..<days).compactMap { offset -> DailyStat? in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let nextDate = calendar.date(byAdding: .day, value: 1, to: date)!
            let daySessions = workSessions.filter { $0.startedAt >= date && $0.startedAt < nextDate }
            let totalMinutes = daySessions.compactMap(\.actualDurationSeconds).reduce(0, +) / 60
            return DailyStat(date: date, totalMinutes: totalMinutes, sessionCount: daySessions.count)
        }.reversed()
    }
}
