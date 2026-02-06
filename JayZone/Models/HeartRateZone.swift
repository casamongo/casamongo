import Foundation
import SwiftUI

struct HeartRateZone: Identifiable, Codable, Equatable {
    var id: Int          // 1-5 zone number
    var name: String     // e.g. "Zone 1 - Recovery"
    var minBPM: Int
    var maxBPM: Int

    var color: String    // stored as a name, mapped to SwiftUI Color

    var swiftUIColor: Color {
        switch color {
        case "blue": return .blue
        case "green": return .green
        case "yellow": return .yellow
        case "orange": return .orange
        case "red": return .red
        default: return .gray
        }
    }

    static let defaults: [HeartRateZone] = [
        HeartRateZone(id: 1, name: "Zone 1 – Recovery", minBPM: 50, maxBPM: 103, color: "blue"),
        HeartRateZone(id: 2, name: "Zone 2 – Fat Burn", minBPM: 104, maxBPM: 123, color: "green"),
        HeartRateZone(id: 3, name: "Zone 3 – Cardio", minBPM: 124, maxBPM: 143, color: "yellow"),
        HeartRateZone(id: 4, name: "Zone 4 – Hard", minBPM: 144, maxBPM: 162, color: "orange"),
        HeartRateZone(id: 5, name: "Zone 5 – Peak", minBPM: 163, maxBPM: 220, color: "red"),
    ]
}
