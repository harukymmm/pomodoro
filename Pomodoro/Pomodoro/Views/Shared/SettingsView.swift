import SwiftUI

struct SettingsView: View {
    @Bindable var appSettings: AppSettings
    #if os(iOS)
    @State private var showingFontSelection = false
    #endif

    var body: some View {
        Form {
            // MARK: - Display
            Section("表示") {
                #if os(iOS)
                Button {
                    showingFontSelection = true
                } label: {
                    HStack {
                        Text("フォント")
                            .foregroundStyle(.primary)
                        Spacer()
                        Text(appSettings.timerFont.displayName)
                            .foregroundStyle(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .sheet(isPresented: $showingFontSelection) {
                    NavigationStack {
                        FontSelectionView(appSettings: appSettings)
                            .toolbar {
                                ToolbarItem(placement: .confirmationAction) {
                                    Button("完了") {
                                        showingFontSelection = false
                                    }
                                }
                            }
                    }
                }
                #else
                NavigationLink {
                    FontSelectionView(appSettings: appSettings)
                } label: {
                    HStack {
                        Text("フォント")
                        Spacer()
                        Text(appSettings.timerFont.displayName)
                            .foregroundStyle(.secondary)
                    }
                }
                #endif

                HStack {
                    Spacer()
                    Text("25:00")
                        .font(appSettings.timerFont.font(size: 28, weight: .medium))
                        .monospacedDigit()
                    Spacer()
                }
                .padding(.vertical, 4)
            }

            // MARK: - Timer Duration
            Section("タイマー時間") {
                Stepper("作業: \(appSettings.workDurationMinutes)分",
                        value: $appSettings.workDurationMinutes,
                        in: 1...60)

                Stepper("小休憩: \(appSettings.shortBreakMinutes)分",
                        value: $appSettings.shortBreakMinutes,
                        in: 1...30)

                Stepper("大休憩: \(appSettings.longBreakMinutes)分",
                        value: $appSettings.longBreakMinutes,
                        in: 1...60)
            }

            // MARK: - Cycle
            Section("サイクル") {
                Stepper("セット数: \(appSettings.setsPerCycle)",
                        value: $appSettings.setsPerCycle,
                        in: 1...8)
            }

            // MARK: - Auto Start
            Section("自動開始") {
                Toggle("休憩を自動開始", isOn: $appSettings.autoStartBreaks)
                Toggle("作業を自動開始", isOn: $appSettings.autoStartWork)
            }
        }
        .navigationTitle("設定")
        #if os(macOS)
        .formStyle(.grouped)
        #endif
    }
}
