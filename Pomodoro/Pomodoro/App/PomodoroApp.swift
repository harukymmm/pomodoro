import SwiftUI
import SwiftData

@main
struct PomodoroApp: App {
    @State private var timerService = TimerService()
    private let notificationService = NotificationService()

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
        MenuBarExtra {
            MenuBarTimerView(timerService: timerService)
                .modelContainer(sharedModelContainer)
                .onAppear {
                    setupServices()
                }
        } label: {
            Text(timerService.menuBarText)
        }
        .menuBarExtraStyle(.window)
        #endif

        #if os(iOS)
        WindowGroup {
            iOSContentView(timerService: timerService)
                .modelContainer(sharedModelContainer)
                .onAppear {
                    setupServices()
                }
        }
        #endif
    }

    private func setupServices() {
        let context = sharedModelContainer.mainContext
        timerService.configure(modelContext: context, notificationService: notificationService)
        notificationService.requestPermission()
    }
}
