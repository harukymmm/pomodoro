import Foundation

enum TimerPhase: String, Codable, CaseIterable {
    case work
    case shortBreak
    case longBreak

    var displayName: String {
        switch self {
        case .work: "作業"
        case .shortBreak: "小休憩"
        case .longBreak: "大休憩"
        }
    }

    var defaultDurationSeconds: Int {
        switch self {
        case .work: 1500       // 25分
        case .shortBreak: 300  // 5分
        case .longBreak: 900   // 15分
        }
    }
}
