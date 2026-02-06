import Foundation
import HealthKit

final class HealthKitManager: ObservableObject {
    let healthStore = HKHealthStore()

    @Published var isAuthorized = false

    // MARK: - Authorization

    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.workoutType(),
        ]

        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            DispatchQueue.main.async {
                self.isAuthorized = success
            }
            if let error = error {
                print("HealthKit authorization error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Fetch heart rate samples within a date range

    /// Returns raw heart rate samples (BPM + timestamp) for the given date range.
    func fetchHeartRateSamples(
        from startDate: Date,
        to endDate: Date,
        completion: @escaping ([HKQuantitySample]) -> Void
    ) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            completion([])
            return
        }

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )

        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: true
        )

        let query = HKSampleQuery(
            sampleType: heartRateType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { _, results, error in
            if let error = error {
                print("Heart rate query error: \(error.localizedDescription)")
                completion([])
                return
            }
            let samples = results as? [HKQuantitySample] ?? []
            completion(samples)
        }

        healthStore.execute(query)
    }

    // MARK: - Aggregate time-in-zone

    /// Given heart rate samples and zone definitions, calculate the total seconds spent
    /// in each zone. Each sample's duration is estimated as the interval to the next sample,
    /// capped at 10 seconds (typical Apple Watch HR interval during workouts).
    func aggregateTimeInZones(
        samples: [HKQuantitySample],
        zones: [HeartRateZone]
    ) -> [ZoneTimeRecord] {
        let bpmUnit = HKUnit.count().unitDivided(by: .minute())
        var zoneTotals: [Int: TimeInterval] = [:]
        for zone in zones {
            zoneTotals[zone.id] = 0
        }

        for i in 0..<samples.count {
            let bpm = samples[i].quantity.doubleValue(for: bpmUnit)
            let bpmInt = Int(bpm)

            // Estimate duration: gap to next sample, capped at 10s
            let duration: TimeInterval
            if i + 1 < samples.count {
                let gap = samples[i + 1].startDate.timeIntervalSince(samples[i].startDate)
                duration = min(gap, 10.0)
            } else {
                duration = 5.0  // last sample, assume 5s
            }

            // Find which zone this BPM falls into
            if let zone = zones.first(where: { bpmInt >= $0.minBPM && bpmInt <= $0.maxBPM }) {
                zoneTotals[zone.id, default: 0] += duration
            }
        }

        return zones.map { zone in
            ZoneTimeRecord(
                zoneID: zone.id,
                zoneName: zone.name,
                totalSeconds: zoneTotals[zone.id] ?? 0
            )
        }
    }

    // MARK: - Convenience: fetch + aggregate for a date range

    func fetchZoneTimes(
        from startDate: Date,
        to endDate: Date,
        zones: [HeartRateZone],
        completion: @escaping ([ZoneTimeRecord]) -> Void
    ) {
        fetchHeartRateSamples(from: startDate, to: endDate) { [weak self] samples in
            guard let self = self else { return }
            let records = self.aggregateTimeInZones(samples: samples, zones: zones)
            DispatchQueue.main.async {
                completion(records)
            }
        }
    }
}
