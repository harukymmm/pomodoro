import SwiftUI
import AppKit

#if os(macOS)

// MARK: - Transparent Window Background

struct VisualEffectBackground: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.state = .active
        view.material = .popover
        view.blendingMode = .behindWindow
        return view
    }
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

struct TransparentWindowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(WindowAccessor())
    }
}

private struct WindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                window.isOpaque = false
                window.backgroundColor = .clear
            }
        }
        return view
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}

// MARK: - Main Content View

struct MacContentView: View {
    @Bindable var timerService: TimerService
    var appSettings: AppSettings
    @State private var selectedTab: Tab = .timer

    private enum Tab: String, CaseIterable {
        case timer = "タイマー"
        case history = "履歴"
        case statistics = "統計"
        case settings = "設定"
    }

    var body: some View {
        VStack(spacing: 16) {
            Picker("", selection: $selectedTab) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            switch selectedTab {
            case .timer:
                SessionTitleInput(
                    title: $timerService.sessionTitle,
                    isEditable: timerService.state == .idle || timerService.state == .completed,
                    phase: timerService.currentPhase
                )

                TimerView(
                    remainingSeconds: timerService.remainingSeconds,
                    totalSeconds: timerService.totalSeconds,
                    progress: timerService.progress,
                    phase: timerService.currentPhase,
                    state: timerService.state,
                    completedWorkSets: timerService.completedWorkSets,
                    timerFont: appSettings.timerFont,
                    isInOvertime: timerService.isInOvertime,
                    overtimeSeconds: timerService.overtimeSeconds
                )
                .frame(width: 220, height: 220)

                TimerControlsView(
                    state: timerService.state,
                    phase: timerService.currentPhase,
                    currentSetDisplay: timerService.currentSetDisplay,
                    dailySetDisplay: timerService.dailySetDisplay,
                    onStart: { timerService.start() },
                    onPause: { timerService.pause() },
                    onResume: { timerService.resume() },
                    onReset: { timerService.reset() },
                    onSkip: { timerService.skip() },
                    isInOvertime: timerService.isInOvertime,
                    onFinishOvertime: { timerService.finishOvertime() }
                )

            case .history:
                HistoryListView(appSettings: appSettings)

            case .statistics:
                StatisticsView()

            case .settings:
                SettingsView(appSettings: appSettings)
            }
        }
        .padding()
        .frame(width: 340)
        .background(VisualEffectBackground())
        .modifier(TransparentWindowModifier())
        .alert("延長時間の記録", isPresented: $timerService.showOvertimeChoice) {
            Button("合計時間を記録") {
                timerService.confirmOvertimeChoice(includeOvertime: true)
            }
            Button("標準時間のみ記録") {
                timerService.confirmOvertimeChoice(includeOvertime: false)
            }
        } message: {
            let total = (timerService.totalSeconds / 60) + timerService.overtimeMinutes
            Text("延長 \(timerService.overtimeMinutes)分を含む合計 \(total)分を記録しますか？")
        }
    }
}
#endif
