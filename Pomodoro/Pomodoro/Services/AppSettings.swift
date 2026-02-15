import Foundation

@MainActor
@Observable
final class AppSettings {
    var timerFontId: String {
        didSet { UserDefaults.standard.set(timerFontId, forKey: "timerFontId") }
    }

    var workDurationMinutes: Int {
        didSet {
            let clamped = min(max(workDurationMinutes, 1), 60)
            if workDurationMinutes != clamped { workDurationMinutes = clamped }
            UserDefaults.standard.set(workDurationMinutes, forKey: "workDurationMinutes")
        }
    }

    var shortBreakMinutes: Int {
        didSet {
            let clamped = min(max(shortBreakMinutes, 1), 30)
            if shortBreakMinutes != clamped { shortBreakMinutes = clamped }
            UserDefaults.standard.set(shortBreakMinutes, forKey: "shortBreakMinutes")
        }
    }

    var longBreakMinutes: Int {
        didSet {
            let clamped = min(max(longBreakMinutes, 1), 60)
            if longBreakMinutes != clamped { longBreakMinutes = clamped }
            UserDefaults.standard.set(longBreakMinutes, forKey: "longBreakMinutes")
        }
    }

    var setsPerCycle: Int {
        didSet {
            let clamped = min(max(setsPerCycle, 1), 8)
            if setsPerCycle != clamped { setsPerCycle = clamped }
            UserDefaults.standard.set(setsPerCycle, forKey: "setsPerCycle")
        }
    }

    var dailyTargetSets: Int {
        didSet {
            let clamped = min(max(dailyTargetSets, 1), 20)
            if dailyTargetSets != clamped { dailyTargetSets = clamped }
            UserDefaults.standard.set(dailyTargetSets, forKey: "dailyTargetSets")
        }
    }

    var autoStartBreaks: Bool {
        didSet { UserDefaults.standard.set(autoStartBreaks, forKey: "autoStartBreaks") }
    }

    var autoStartWork: Bool {
        didSet { UserDefaults.standard.set(autoStartWork, forKey: "autoStartWork") }
    }

    var timerFont: TimerFont {
        TimerFont(rawValue: timerFontId) ?? .systemRounded
    }

    func durationSeconds(for phase: TimerPhase) -> Int {
        switch phase {
        case .work: workDurationMinutes * 60
        case .shortBreak: shortBreakMinutes * 60
        case .longBreak: longBreakMinutes * 60
        }
    }

    init() {
        let defaults = UserDefaults.standard

        if let fontId = defaults.string(forKey: "timerFontId") {
            self.timerFontId = fontId
        } else {
            self.timerFontId = TimerFont.systemRounded.rawValue
        }

        if defaults.object(forKey: "workDurationMinutes") != nil {
            self.workDurationMinutes = defaults.integer(forKey: "workDurationMinutes")
        } else {
            self.workDurationMinutes = 25
        }

        if defaults.object(forKey: "shortBreakMinutes") != nil {
            self.shortBreakMinutes = defaults.integer(forKey: "shortBreakMinutes")
        } else {
            self.shortBreakMinutes = 5
        }

        if defaults.object(forKey: "longBreakMinutes") != nil {
            self.longBreakMinutes = defaults.integer(forKey: "longBreakMinutes")
        } else {
            self.longBreakMinutes = 15
        }

        if defaults.object(forKey: "setsPerCycle") != nil {
            self.setsPerCycle = defaults.integer(forKey: "setsPerCycle")
        } else {
            self.setsPerCycle = 4
        }

        if defaults.object(forKey: "dailyTargetSets") != nil {
            self.dailyTargetSets = defaults.integer(forKey: "dailyTargetSets")
        } else {
            self.dailyTargetSets = 8
        }

        self.autoStartBreaks = defaults.bool(forKey: "autoStartBreaks")
        self.autoStartWork = defaults.bool(forKey: "autoStartWork")
    }
}
