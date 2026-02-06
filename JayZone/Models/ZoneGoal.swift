import Foundation

enum GoalPeriod: String, Codable, CaseIterable, Identifiable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"

    var id: String { rawValue }
}

struct ZoneGoal: Identifiable, Codable, Equatable {
    var id: String { "\(zoneID)-\(period.rawValue)" }
    var zoneID: Int
    var period: GoalPeriod
    var targetMinutes: Int  // goal in minutes
}
