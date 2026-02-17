import SwiftUI
import SwiftData

@main
struct PomodoroApp: App {
    @State private var timerService = TimerService()
    @State private var appSettings = AppSettings()
    private let notificationService = NotificationService()
    #if os(macOS)
    private let appBlockerService = AppBlockerService()
    #endif

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([PomodoroSession.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        let context = sharedModelContainer.mainContext
        timerService.configure(modelContext: context, notificationService: notificationService, appSettings: appSettings)
        notificationService.requestPermission()
        #if os(macOS)
        appBlockerService.configure(timerService: timerService, appSettings: appSettings, notificationService: notificationService)
        #endif
        cleanupOrphanedSessions(context: context)
    }

    private func cleanupOrphanedSessions(context: ModelContext) {
        let orphaned = try? context.fetch(
            FetchDescriptor<PomodoroSession>(
                predicate: #Predicate { $0.completedAt == nil }
            )
        )
        guard let orphaned, !orphaned.isEmpty else { return }
        for session in orphaned {
            context.delete(session)
        }
        try? context.save()
    }

    var body: some Scene {
        #if os(macOS)
        WindowGroup {
            MacContentView(timerService: timerService, appSettings: appSettings)
                .modelContainer(sharedModelContainer)
        }
        .windowResizability(.contentSize)

        MenuBarExtra {
            MenuBarTimerView(timerService: timerService, appSettings: appSettings)
                .modelContainer(sharedModelContainer)
                .onAppear {
                    for window in NSApplication.shared.windows where window.canBecomeMain {
                        window.close()
                    }
                }
        } label: {
            if let text = timerService.menuBarTimerText {
                Text(text)
            } else {
                Image("MenuBarIcon")
            }
        }
        .menuBarExtraStyle(.window)
        #endif

        #if os(iOS)
        WindowGroup {
            iOSContentView(timerService: timerService, appSettings: appSettings)
                .modelContainer(sharedModelContainer)
        }
        #endif
    }

}
