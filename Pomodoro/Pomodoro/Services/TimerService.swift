import Foundation
import Combine
import SwiftData

@MainActor
@Observable
final class TimerService {
    // MARK: - State

    private(set) var state: TimerState = .idle
    private(set) var currentPhase: TimerPhase = .work
    private(set) var remainingSeconds: Int = TimerPhase.work.defaultDurationSeconds
    private(set) var completedWorkSets: Int = 0
    private(set) var todayCompletedSets: Int = 0
    var sessionTitle: String = ""

    // MARK: - Overtime State

    private(set) var isInOvertime: Bool = false
    private(set) var overtimeSeconds: Int = 0
    var showOvertimeChoice: Bool = false
    var overtimeMinutes: Int { overtimeSeconds / 60 }

    // MARK: - Computed

    var totalSeconds: Int {
        appSettings?.durationSeconds(for: currentPhase) ?? currentPhase.defaultDurationSeconds
    }

    var progress: Double {
        if isInOvertime { return 1.0 }
        guard totalSeconds > 0 else { return 0 }
        return 1.0 - Double(remainingSeconds) / Double(totalSeconds)
    }

    var displayTime: String {
        if isInOvertime {
            let m = overtimeSeconds / 60
            let s = overtimeSeconds % 60
            return String(format: "+%d:%02d", m, s)
        }
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%d:%02d", m, s)
    }

    var menuBarTimerText: String? {
        switch state {
        case .idle, .completed: return nil
        case .running, .paused:
            if isInOvertime {
                let m = overtimeSeconds / 60
                let s = overtimeSeconds % 60
                return String(format: "+%02d:%02d", m, s)
            }
            let m = remainingSeconds / 60
            let s = remainingSeconds % 60
            return String(format: "%02d:%02d", m, s)
        }
    }

    var currentSetDisplay: String {
        let sets = appSettings?.setsPerCycle ?? 4
        let current = min(completedWorkSets + (currentPhase == .work ? 1 : 0), sets)
        return "セット \(current)/\(sets)"
    }

    var dailySetDisplay: String {
        let target = appSettings?.dailyTargetSets ?? 8
        return "本日 \(todayCompletedSets)/\(target) セット"
    }

    var canStart: Bool { state == .idle || state == .completed }
    var canPause: Bool { state == .running }
    var canResume: Bool { state == .paused }

    // MARK: - Private

    private var phaseStartDate: Date?
    private var accumulatedPauseSeconds: TimeInterval = 0
    private var pauseStartDate: Date?
    private var timerCancellable: AnyCancellable?
    private var modelContext: ModelContext?
    private var currentSession: PomodoroSession?
    private var notificationService: NotificationService?
    private var appSettings: AppSettings?

    // MARK: - Setup

    private var isConfigured = false

    func configure(modelContext: ModelContext, notificationService: NotificationService, appSettings: AppSettings) {
        guard !isConfigured else { return }
        isConfigured = true
        self.modelContext = modelContext
        self.notificationService = notificationService
        self.appSettings = appSettings
    }

    // MARK: - Actions

    func start() {
        guard canStart else { return }
        let duration = totalSeconds
        state = .running
        remainingSeconds = duration
        phaseStartDate = Date()
        accumulatedPauseSeconds = 0
        pauseStartDate = nil
        resetOvertimeState()

        if currentPhase == .work {
            let session = PomodoroSession(
                title: sessionTitle.isEmpty ? "無題の作業" : sessionTitle,
                phase: currentPhase,
                durationSeconds: duration
            )
            modelContext?.insert(session)
            try? modelContext?.save()
            currentSession = session
        }

        scheduleNotification()
        startTicking()
    }

    func pause() {
        guard canPause else { return }
        state = .paused
        pauseStartDate = Date()
        timerCancellable?.cancel()
        cancelScheduledNotification()
    }

    func resume() {
        guard canResume else { return }
        if let pauseStart = pauseStartDate {
            accumulatedPauseSeconds += Date().timeIntervalSince(pauseStart)
        }
        pauseStartDate = nil
        state = .running
        scheduleNotification()
        startTicking()
    }

    func reset() {
        let elapsed = elapsedSeconds()
        if let session = currentSession {
            if elapsed < 60 && !isInOvertime {
                modelContext?.delete(session)
            } else {
                session.cancel(elapsedSeconds: elapsed)
            }
            try? modelContext?.save()
        }

        timerCancellable?.cancel()
        cancelScheduledNotification()
        resetOvertimeState()
        state = .idle
        currentPhase = .work
        remainingSeconds = appSettings?.durationSeconds(for: .work) ?? TimerPhase.work.defaultDurationSeconds
        completedWorkSets = 0
        phaseStartDate = nil
        accumulatedPauseSeconds = 0
        pauseStartDate = nil
        currentSession = nil
    }

    func skip() {
        guard state == .running || state == .paused else { return }
        let elapsed = elapsedSeconds()

        if currentPhase == .work, let session = currentSession {
            if elapsed < 60 && !isInOvertime {
                modelContext?.delete(session)
            } else {
                session.cancel(elapsedSeconds: elapsed)
            }
            try? modelContext?.save()
            currentSession = nil
        }

        timerCancellable?.cancel()
        cancelScheduledNotification()
        resetOvertimeState()
        advancePhase()
    }

    // MARK: - Timer

    private func startTicking() {
        timerCancellable = Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func tick() {
        guard state == .running, let start = phaseStartDate else { return }
        let elapsed = Date().timeIntervalSince(start) - accumulatedPauseSeconds
        let newRemaining = max(0, totalSeconds - Int(elapsed))
        remainingSeconds = newRemaining

        if newRemaining <= 0 {
            if currentPhase == .work {
                // Work phase: enter overtime instead of completing
                if !isInOvertime {
                    isInOvertime = true
                    notificationService?.sendPhaseCompleteNotification(phase: currentPhase)
                    #if os(iOS)
                    HapticHelper.phaseComplete()
                    #endif
                }
                overtimeSeconds = Int(elapsed) - totalSeconds
            } else {
                // Break phase: complete immediately as before
                completePhase()
            }
        }
    }

    private func elapsedSeconds() -> Int {
        guard let start = phaseStartDate else { return 0 }
        var pauseTotal = accumulatedPauseSeconds
        if let pauseStart = pauseStartDate {
            pauseTotal += Date().timeIntervalSince(pauseStart)
        }
        return Int(Date().timeIntervalSince(start) - pauseTotal)
    }

    // MARK: - Phase management

    private func completePhase() {
        timerCancellable?.cancel()
        remainingSeconds = 0

        if !isInOvertime {
            notificationService?.sendPhaseCompleteNotification(phase: currentPhase)
            #if os(iOS)
            HapticHelper.phaseComplete()
            #endif
        }

        if currentPhase == .work {
            completedWorkSets += 1
            todayCompletedSets += 1
            if let session = currentSession {
                session.complete(actualSeconds: totalSeconds)
                try? modelContext?.save()
                currentSession = nil
            }
        }

        resetOvertimeState()
        advancePhase()
    }

    private func advancePhase() {
        let previousPhase = currentPhase
        let sets = appSettings?.setsPerCycle ?? 4

        switch currentPhase {
        case .work:
            if completedWorkSets >= sets {
                currentPhase = .longBreak
                completedWorkSets = 0
            } else {
                currentPhase = .shortBreak
            }
        case .shortBreak, .longBreak:
            currentPhase = .work
        }

        remainingSeconds = appSettings?.durationSeconds(for: currentPhase) ?? currentPhase.defaultDurationSeconds
        state = .idle
        phaseStartDate = nil
        accumulatedPauseSeconds = 0
        pauseStartDate = nil

        // Auto-start logic
        let shouldAutoStart: Bool
        switch currentPhase {
        case .shortBreak, .longBreak:
            shouldAutoStart = appSettings?.autoStartBreaks ?? false
        case .work:
            shouldAutoStart = (previousPhase == .shortBreak || previousPhase == .longBreak)
                && (appSettings?.autoStartWork ?? false)
        }

        if shouldAutoStart {
            start()
        }
    }

    // MARK: - Overtime

    func finishOvertime() {
        timerCancellable?.cancel()
        if overtimeMinutes < 1 {
            recordSession(includeOvertime: false)
        } else {
            showOvertimeChoice = true
        }
    }

    func confirmOvertimeChoice(includeOvertime: Bool) {
        recordSession(includeOvertime: includeOvertime)
    }

    private func recordSession(includeOvertime: Bool) {
        completedWorkSets += 1
        todayCompletedSets += 1
        if let session = currentSession {
            let actualSeconds = includeOvertime
                ? totalSeconds + (overtimeMinutes * 60)
                : totalSeconds
            session.complete(actualSeconds: actualSeconds)
            try? modelContext?.save()
            currentSession = nil
        }
        resetOvertimeState()
        advancePhase()
    }

    private func resetOvertimeState() {
        isInOvertime = false
        overtimeSeconds = 0
        showOvertimeChoice = false
    }

    // MARK: - Notifications

    private func scheduleNotification() {
        guard !isInOvertime else { return }
        let seconds = TimeInterval(remainingSeconds)
        notificationService?.scheduleTimerEnd(phase: currentPhase, afterSeconds: seconds)
    }

    private func cancelScheduledNotification() {
        notificationService?.cancelPending()
    }
}

// MARK: - Haptic Helper (iOS)

#if os(iOS)
import UIKit

enum HapticHelper {
    static func phaseComplete() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
#endif
