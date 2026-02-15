import SwiftUI

enum TimerFont: String, CaseIterable, Identifiable {
    case systemDefault = "systemDefault"
    case systemRounded = "systemRounded"
    case systemSerif = "systemSerif"
    case systemMonospaced = "systemMonospaced"
    case menlo = "menlo"
    case avenirNext = "avenirNext"
    case courierNew = "courierNew"
    case dinAlternate = "dinAlternate"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .systemDefault: "System Default"
        case .systemRounded: "System Rounded"
        case .systemSerif: "System Serif"
        case .systemMonospaced: "System Monospaced"
        case .menlo: "Menlo"
        case .avenirNext: "Avenir Next"
        case .courierNew: "Courier New"
        case .dinAlternate: "DIN Alternate"
        }
    }

    func font(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch self {
        case .systemDefault:
            return .system(size: size, weight: weight, design: .default)
        case .systemRounded:
            return .system(size: size, weight: weight, design: .rounded)
        case .systemSerif:
            return .system(size: size, weight: weight, design: .serif)
        case .systemMonospaced:
            return .system(size: size, weight: weight, design: .monospaced)
        case .menlo:
            return .custom("Menlo", size: size)
        case .avenirNext:
            return .custom("Avenir Next", size: size)
        case .courierNew:
            return .custom("Courier New", size: size)
        case .dinAlternate:
            return .custom("DIN Alternate", size: size)
        }
    }
}
