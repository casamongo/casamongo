import Foundation
import Combine

enum TimePeriod: String, CaseIterable, Identifiable {
    case daily = "Today"
    case weekly = "This Week"
    case monthly = "This Month"

    var id: String { rawValue }
}

final class DashboardViewModel: ObservableObject {
    @Published var selectedPeriod: TimePeriod = .daily
    @Published var zoneRecords: [ZoneTimeRecord] = []
    @Published var isLoading = false

    private let healthKitManager: HealthKitManager
    private let goalStore: GoalStore
    private var cancellables = Set<AnyCancellable>()
    private var currentRequestID = UUID()

    init(healthKitManager: HealthKitManager, goalStore: GoalStore) {
        self.healthKitManager = healthKitManager
        self.goalStore = goalStore

        // Re-fetch when period changes
        $selectedPeriod
            .sink { [weak self] _ in self?.refresh() }
            .store(in: &cancellables)
    }

    // MARK: - Date range for selected period

    var dateRange: (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()

        switch selectedPeriod {
        case .daily:
            let start = calendar.startOfDay(for: now)
            return (start, now)

        case .weekly:
            let weekday = calendar.component(.weekday, from: now)
            let daysToSubtract = (weekday - calendar.firstWeekday + 7) % 7
            let startOfWeek = calendar.startOfDay(
                for: calendar.date(byAdding: .day, value: -daysToSubtract, to: now)!
            )
            return (startOfWeek, now)

        case .monthly:
            let components = calendar.dateComponents([.year, .month], from: now)
            let startOfMonth = calendar.date(from: components)!
            return (startOfMonth, now)
        }
    }

    // MARK: - Goal period mapping

    var goalPeriod: GoalPeriod {
        switch selectedPeriod {
        case .daily: return .daily
        case .weekly: return .weekly
        case .monthly: return .monthly
        }
    }

    // MARK: - Refresh data from HealthKit

    func refresh() {
        isLoading = true
        let requestID = UUID()
        currentRequestID = requestID
        let range = dateRange
        healthKitManager.fetchZoneTimes(
            from: range.start,
            to: range.end,
            zones: goalStore.zones
        ) { [weak self] records in
            guard let self = self, self.currentRequestID == requestID else { return }
            self.zoneRecords = records
            self.isLoading = false
        }
    }

    // MARK: - Goal progress for a zone

    func goalProgress(forZone zoneID: Int) -> Double? {
        guard let goal = goalStore.goal(forZone: zoneID, period: goalPeriod),
              goal.targetMinutes > 0 else {
            return nil
        }
        let actual = zoneRecords.first(where: { $0.zoneID == zoneID })?.totalSeconds ?? 0
        let targetSeconds = Double(goal.targetMinutes) * 60.0
        return min(actual / targetSeconds, 1.0)
    }

    func goalTargetFormatted(forZone zoneID: Int) -> String? {
        guard let goal = goalStore.goal(forZone: zoneID, period: goalPeriod),
              goal.targetMinutes > 0 else {
            return nil
        }
        if goal.targetMinutes >= 60 {
            let h = goal.targetMinutes / 60
            let m = goal.targetMinutes % 60
            return m > 0 ? "\(h)h \(m)m" : "\(h)h"
        }
        return "\(goal.targetMinutes)m"
    }

    // MARK: - Total time across all zones

    var totalTimeFormatted: String {
        let total = zoneRecords.reduce(0) { $0 + $1.totalSeconds }
        let hours = Int(total) / 3600
        let minutes = (Int(total) % 3600) / 60
        if hours > 0 {
            return String(format: "%dh %02dm", hours, minutes)
        }
        return "\(minutes)m"
    }
}
