import Foundation
import UserNotifications

@MainActor
final class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    private let center = UNUserNotificationCenter.current()
    private let pendingIdentifier = "pomodoro.timer.end"

    override init() {
        super.init()
        center.delegate = self
    }

    func requestPermission() {
        Task {
            try? await center.requestAuthorization(options: [.alert, .sound, .badge])
        }
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    func scheduleTimerEnd(phase: TimerPhase, afterSeconds seconds: TimeInterval) {
        guard seconds > 0 else { return }
        let content = UNMutableNotificationContent()
        content.title = "\(phase.displayName)が終了しました"
        content.body = notificationBody(for: phase)
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(identifier: pendingIdentifier, content: content, trigger: trigger)

        center.add(request)
    }

    func sendPhaseCompleteNotification(phase: TimerPhase) {
        let content = UNMutableNotificationContent()
        content.title = "\(phase.displayName)が終了しました"
        content.body = notificationBody(for: phase)
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "pomodoro.phase.complete.\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
        center.add(request)
    }

    func sendAppBlockedNotification(appName: String) {
        let content = UNMutableNotificationContent()
        content.title = "集中時間中です"
        content.body = "\(appName) を終了しました"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "pomodoro.app.blocked.\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
        center.add(request)
    }

    func cancelPending() {
        center.removePendingNotificationRequests(withIdentifiers: [pendingIdentifier])
    }

    private func notificationBody(for phase: TimerPhase) -> String {
        switch phase {
        case .work: return "お疲れ様でした！休憩を取りましょう。"
        case .shortBreak: return "休憩終了！次の作業を始めましょう。"
        case .longBreak: return "長休憩終了！リフレッシュできましたか？"
        }
    }
}
