#if os(macOS)
import SwiftUI
import AppKit

struct BlockedAppsSettingsView: View {
    @Bindable var appSettings: AppSettings
    @State private var installedApps: [AppInfo] = []
    @State private var searchText = ""

    private var filteredApps: [AppInfo] {
        if searchText.isEmpty {
            return installedApps
        }
        return installedApps.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("アプリを検索", text: $searchText)
                    .textFieldStyle(.plain)
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(FuturisticTheme.surfaceDim)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal)
            .padding(.top, 8)

            // App list
            List {
                if !appSettings.blockedApps.isEmpty {
                    Section("ブロック中") {
                        ForEach(blockedAppInfos) { app in
                            AppRow(app: app, isBlocked: true) {
                                removeFromBlockedList(bundleId: app.bundleIdentifier)
                            }
                        }
                    }
                }

                Section("インストール済みアプリ") {
                    ForEach(filteredApps) { app in
                        let isBlocked = appSettings.blockedApps.contains { $0.bundleIdentifier == app.bundleIdentifier }
                        if !isBlocked {
                            AppRow(app: app, isBlocked: false) {
                                addToBlockedList(app: app)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            loadInstalledApps()
        }
    }

    private var blockedAppInfos: [AppInfo] {
        appSettings.blockedApps.compactMap { blocked in
            installedApps.first { $0.bundleIdentifier == blocked.bundleIdentifier }
            ?? AppInfo(name: blocked.appName, bundleIdentifier: blocked.bundleIdentifier, icon: NSWorkspace.shared.icon(forFile: "/Applications"))
        }
    }

    private func addToBlockedList(app: AppInfo) {
        let blockedApp = BlockedApp(bundleIdentifier: app.bundleIdentifier, appName: app.name)
        appSettings.blockedApps.append(blockedApp)
    }

    private func removeFromBlockedList(bundleId: String) {
        appSettings.blockedApps.removeAll { $0.bundleIdentifier == bundleId }
    }

    private func loadInstalledApps() {
        var apps: [AppInfo] = []
        let fileManager = FileManager.default
        let appDirs = ["/Applications", "/System/Applications"]

        for dir in appDirs {
            guard let contents = try? fileManager.contentsOfDirectory(atPath: dir) else { continue }
            for item in contents where item.hasSuffix(".app") {
                let path = "\(dir)/\(item)"
                guard let bundle = Bundle(path: path),
                      let bundleId = bundle.bundleIdentifier else { continue }

                // Skip self
                if bundleId == Bundle.main.bundleIdentifier { continue }

                let name = fileManager.displayName(atPath: path).replacingOccurrences(of: ".app", with: "")
                let icon = NSWorkspace.shared.icon(forFile: path)
                apps.append(AppInfo(name: name, bundleIdentifier: bundleId, icon: icon))
            }
        }

        installedApps = apps.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}

// MARK: - AppInfo

private struct AppInfo: Identifiable {
    var id: String { bundleIdentifier }
    let name: String
    let bundleIdentifier: String
    let icon: NSImage
}

// MARK: - AppRow

private struct AppRow: View {
    let app: AppInfo
    let isBlocked: Bool
    let action: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(nsImage: app.icon)
                .resizable()
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 1) {
                Text(app.name)
                    .font(.system(size: 13))
                Text(app.bundleIdentifier)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                action()
            } label: {
                Image(systemName: isBlocked ? "minus.circle.fill" : "plus.circle")
                    .foregroundStyle(isBlocked ? .red : .accentColor)
                    .font(.system(size: 18))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 2)
    }
}
#endif
