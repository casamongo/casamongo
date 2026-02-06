import SwiftUI

struct ZoneSettingsView: View {
    @ObservedObject var goalStore: GoalStore
    @State private var showResetAlert = false

    var body: some View {
        NavigationView {
            List {
                Section {
                    Text("Configure BPM ranges for each heart rate zone. These should match your personal fitness levels.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .listRowBackground(Color.clear)
                }

                ForEach($goalStore.zones) { $zone in
                    ZoneSettingRow(zone: $zone)
                }

                Section {
                    Button("Reset to Defaults") {
                        showResetAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Zone Settings")
            .alert("Reset Zones", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    goalStore.resetZonesToDefaults()
                }
            } message: {
                Text("This will reset all zone BPM ranges to their default values.")
            }
        }
    }
}

// MARK: - Zone Setting Row

struct ZoneSettingRow: View {
    @Binding var zone: HeartRateZone

    @State private var minText: String = ""
    @State private var maxText: String = ""
    @State private var isEditing = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(zone.swiftUIColor)
                    .frame(width: 12, height: 12)
                Text(zone.name)
                    .font(.subheadline.bold())
                Spacer()
                if !isEditing {
                    Button("Edit") {
                        minText = String(zone.minBPM)
                        maxText = String(zone.maxBPM)
                        isEditing = true
                    }
                    .font(.caption)
                }
            }

            if isEditing {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Min BPM")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        TextField("Min", text: $minText)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 70)
                    }
                    VStack(alignment: .leading) {
                        Text("Max BPM")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        TextField("Max", text: $maxText)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 70)
                    }
                    Spacer()
                    VStack(spacing: 4) {
                        Button("Save") {
                            if let min = Int(minText), let max = Int(maxText), min < max, min > 0 {
                                zone.minBPM = min
                                zone.maxBPM = max
                            }
                            isEditing = false
                        }
                        .font(.caption.bold())
                        Button("Cancel") {
                            isEditing = false
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
            } else {
                Text("\(zone.minBPM)–\(zone.maxBPM) BPM")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
