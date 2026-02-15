#if os(macOS)
import Foundation
import AppKit
import Combine

@MainActor
final class AppBlockerService {
    private var pollTimer: AnyCancellable?
    private var timerService: TimerService?
    private var appSettings: AppSettings?
    private var notificationService: NotificationService?

    func configure(timerService: TimerService, appSettings: AppSettings, notificationService: NotificationService) {
        self.timerService = timerService
        self.appSettings = appSettings
        self.notificationService = notificationService
        startPolling()
    }

    private func startPolling() {
        pollTimer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func tick() {
        guard let timerService, let appSettings else { return }
        guard appSettings.isAppBlockingEnabled else { return }
        guard timerService.currentPhase == .work else { return }
        guard timerService.state == .running || timerService.state == .paused else { return }

        let blockedBundleIds = Set(appSettings.blockedApps.map(\.bundleIdentifier))
        guard !blockedBundleIds.isEmpty else { return }

        for app in NSWorkspace.shared.runningApplications {
            guard let bundleId = app.bundleIdentifier,
                  blockedBundleIds.contains(bundleId) else { continue }

            let appName = app.localizedName ?? bundleId
            app.terminate()
            notificationService?.sendAppBlockedNotification(appName: appName)
        }
    }
}
#endif
