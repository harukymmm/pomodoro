# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# macOS target
xcodebuild -scheme Pomodoro -project Pomodoro/Pomodoro.xcodeproj -destination 'platform=macOS' build

# iOS target (requires iOS Simulator)
xcodebuild -scheme Pomodoro-iOS -project Pomodoro/Pomodoro.xcodeproj -destination 'platform=iOS Simulator,name=iPhone 16' build
```

No test targets, linting, or CI/CD are configured.

## Architecture

SwiftUI + SwiftData app targeting macOS 14.0 and iOS 17.0. No external dependencies — only system frameworks (SwiftUI, SwiftData, Combine, AppKit, UserNotifications).

Both platforms share Models, Services, and most Views. Platform-specific code uses `#if os(macOS)` / `#if os(iOS)`.

### Service Layer (all `@MainActor @Observable`)

- **TimerService** — Core timer logic: state machine (`idle`→`running`→`paused`→`completed`), phase cycling (`work`→`shortBreak`/`longBreak`→`work`), overtime tracking, session persistence via SwiftData. Ticks every 0.5s via Combine Timer.
- **AppSettings** — User preferences persisted to UserDefaults with `didSet` observers (not `@AppStorage`). All numeric values are clamped in `didSet`.
- **NotificationService** — UNUserNotificationCenter wrapper with `UNUserNotificationCenterDelegate` for foreground notification display.
- **AppBlockerService** (macOS only) — Polls `NSWorkspace.shared.runningApplications` every 1s, terminates blocked apps during work phase. Self-contained polling — no view-driven state updates.
- **StatisticsService** — Pure static functions for aggregating session data.

### Dependency Wiring

Services are created in `PomodoroApp` and configured in `setupServices()` via `onAppear`. `TimerService.configure()` receives `ModelContext`, `NotificationService`, and `AppSettings`. Services reference each other directly (not via protocols).

### Data Persistence

- **SwiftData**: `PomodoroSession` (session history) — single `@Model` in the schema
- **UserDefaults**: All settings in `AppSettings` (timer durations, blocked apps list as JSON, toggles)

### Adding New Files

New `.swift` files must be manually added to `project.pbxproj` — both `PBXFileReference`, the appropriate `PBXGroup`, and `PBXSourcesBuildPhase` for each target (Pomodoro and Pomodoro-iOS).

## Conventions

- UI text is in Japanese (日本語)
- Commit messages are in Japanese, ≤50 chars, focused on "why" not "what", no Co-Authored-By
- Theme colors are defined in `Theme.swift` via `FuturisticTheme` enum
