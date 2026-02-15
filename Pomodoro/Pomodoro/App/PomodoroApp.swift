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

    var body: some Scene {
        #if os(macOS)
        WindowGroup {
            MacContentView(timerService: timerService, appSettings: appSettings)
                .modelContainer(sharedModelContainer)
                .onAppear {
                    setupServices()
                }
        }
        .windowResizability(.contentSize)

        MenuBarExtra {
            MenuBarTimerView(timerService: timerService, appSettings: appSettings)
                .modelContainer(sharedModelContainer)
                .onAppear {
                    setupServices()
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
                .onAppear {
                    setupServices()
                }
        }
        #endif
    }

    private func setupServices() {
        let context = sharedModelContainer.mainContext
        timerService.configure(modelContext: context, notificationService: notificationService, appSettings: appSettings)
        notificationService.requestPermission()
        #if os(macOS)
        appBlockerService.configure(timerService: timerService, appSettings: appSettings, notificationService: notificationService)
        #endif
    }
}
