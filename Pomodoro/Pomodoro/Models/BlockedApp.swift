import Foundation

struct BlockedApp: Codable, Identifiable, Hashable {
    var id: String { bundleIdentifier }
    let bundleIdentifier: String
    let appName: String
}
