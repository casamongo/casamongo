import Foundation

/// Persists heart rate zone definitions and goals using UserDefaults.
final class GoalStore: ObservableObject {
    private let zonesKey = "jayzone_heartRateZones"
    private let goalsKey = "jayzone_zoneGoals"

    @Published var zones: [HeartRateZone] {
        didSet { save(zones, forKey: zonesKey) }
    }

    @Published var goals: [ZoneGoal] {
        didSet { save(goals, forKey: goalsKey) }
    }

    init() {
        self.zones = Self.load(forKey: "jayzone_heartRateZones") ?? HeartRateZone.defaults
        self.goals = Self.load(forKey: "jayzone_zoneGoals") ?? []
    }

    // MARK: - Zone management

    func updateZone(_ zone: HeartRateZone) {
        if let idx = zones.firstIndex(where: { $0.id == zone.id }) {
            zones[idx] = zone
        }
    }

    func resetZonesToDefaults() {
        zones = HeartRateZone.defaults
    }

    // MARK: - Goal management

    func goal(forZone zoneID: Int, period: GoalPeriod) -> ZoneGoal? {
        goals.first(where: { $0.zoneID == zoneID && $0.period == period })
    }

    func setGoal(zoneID: Int, period: GoalPeriod, targetMinutes: Int) {
        if let idx = goals.firstIndex(where: { $0.zoneID == zoneID && $0.period == period }) {
            goals[idx].targetMinutes = targetMinutes
        } else {
            goals.append(ZoneGoal(zoneID: zoneID, period: period, targetMinutes: targetMinutes))
        }
    }

    func removeGoal(zoneID: Int, period: GoalPeriod) {
        goals.removeAll(where: { $0.zoneID == zoneID && $0.period == period })
    }

    // MARK: - Persistence helpers

    private func save<T: Encodable>(_ value: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private static func load<T: Decodable>(forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
