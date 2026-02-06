import SwiftUI

struct GoalsView: View {
    @ObservedObject var goalStore: GoalStore
    @State private var selectedPeriod: GoalPeriod = .daily

    var body: some View {
        NavigationView {
            List {
                Picker("Period", selection: $selectedPeriod) {
                    ForEach(GoalPeriod.allCases) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                .padding(.vertical, 8)

                ForEach(goalStore.zones) { zone in
                    GoalRow(
                        zone: zone,
                        period: selectedPeriod,
                        goalStore: goalStore
                    )
                }
            }
            .navigationTitle("Goals")
        }
    }
}

// MARK: - Goal Row

struct GoalRow: View {
    let zone: HeartRateZone
    let period: GoalPeriod
    @ObservedObject var goalStore: GoalStore

    @State private var minutesText: String = ""
    @State private var isEditing = false

    private var currentGoal: ZoneGoal? {
        goalStore.goal(forZone: zone.id, period: period)
    }

    var body: some View {
        HStack {
            Circle()
                .fill(zone.swiftUIColor)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading) {
                Text(zone.name)
                    .font(.subheadline.bold())
                Text("\(zone.minBPM)–\(zone.maxBPM) BPM")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if isEditing {
                HStack(spacing: 4) {
                    TextField("min", text: $minutesText)
                        .keyboardType(.numberPad)
                        .frame(width: 50)
                        .textFieldStyle(.roundedBorder)
                        .font(.subheadline)
                    Text("min")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Button("Save") {
                        if let mins = Int(minutesText), mins > 0 {
                            goalStore.setGoal(zoneID: zone.id, period: period, targetMinutes: mins)
                        } else {
                            goalStore.removeGoal(zoneID: zone.id, period: period)
                        }
                        isEditing = false
                    }
                    .font(.caption.bold())
                }
            } else {
                Button {
                    minutesText = currentGoal.map { String($0.targetMinutes) } ?? ""
                    isEditing = true
                } label: {
                    if let goal = currentGoal {
                        Text("\(goal.targetMinutes) min")
                            .font(.subheadline.monospacedDigit())
                            .foregroundColor(zone.swiftUIColor)
                    } else {
                        Text("Set Goal")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .onChange(of: period) { _ in
            isEditing = false
        }
    }
}
