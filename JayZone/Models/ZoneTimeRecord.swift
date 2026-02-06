import Foundation

/// Represents aggregated time (in seconds) spent in each heart rate zone
/// for a given date range.
struct ZoneTimeRecord: Identifiable {
    let id = UUID()
    let zoneID: Int
    let zoneName: String
    let totalSeconds: TimeInterval

    var formattedTime: String {
        let hours = Int(totalSeconds) / 3600
        let minutes = (Int(totalSeconds) % 3600) / 60
        let seconds = Int(totalSeconds) % 60
        if hours > 0 {
            return String(format: "%dh %02dm", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%dm %02ds", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }
}
