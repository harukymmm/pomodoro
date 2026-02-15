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
    var sessionTitle: String = ""

    // MARK: - Computed

    var totalSeconds: Int {
        appSettings?.durationSeconds(for: currentPhase) ?? currentPhase.defaultDurationSeconds
    }

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return 1.0 - Double(remainingSeconds) / Double(totalSeconds)
    }

    var displayTime: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%d:%02d", m, s)
    }

    var menuBarText: String {
        switch state {
        case .idle: return "🍅"
        case .running, .paused:
            let m = remainingSeconds / 60
            let s = remainingSeconds % 60
            return String(format: "%02d:%02d", m, s)
        case .completed: return "🍅✓"
        }
    }

    var currentSetDisplay: String {
        let sets = appSettings?.setsPerCycle ?? 4
        let current = min(completedWorkSets + (currentPhase == .work ? 1 : 0), sets)
        return "セット \(current)/\(sets)"
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

    func configure(modelContext: ModelContext, notificationService: NotificationService, appSettings: AppSettings) {
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
        if let session = currentSession, elapsed > 0 {
            session.cancel(elapsedSeconds: elapsed)
            try? modelContext?.save()
        }

        timerCancellable?.cancel()
        cancelScheduledNotification()
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
            session.cancel(elapsedSeconds: elapsed)
            try? modelContext?.save()
            currentSession = nil
        }

        timerCancellable?.cancel()
        cancelScheduledNotification()
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
            completePhase()
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

        notificationService?.sendPhaseCompleteNotification(phase: currentPhase)
        #if os(iOS)
        HapticHelper.phaseComplete()
        #endif

        if currentPhase == .work {
            completedWorkSets += 1
            if let session = currentSession {
                session.complete(actualSeconds: totalSeconds)
                try? modelContext?.save()
                currentSession = nil
            }
        }

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

    // MARK: - Notifications

    private func scheduleNotification() {
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
