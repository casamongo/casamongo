import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Period picker
                Picker("Period", selection: $viewModel.selectedPeriod) {
                    ForEach(TimePeriod.allCases) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Loading heart rate data...")
                    Spacer()
                } else if viewModel.zoneRecords.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No heart rate data found")
                            .font(.headline)
                        Text("Wear your Apple Watch during workouts to see zone data here.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Summary card
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Total Active Time")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(viewModel.totalTimeFormatted)
                                        .font(.title2.bold())
                                }
                                Spacer()
                                Text(viewModel.selectedPeriod.rawValue)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)

                            // Stacked bar
                            ZoneBarChartView(records: viewModel.zoneRecords)

                            // Zone breakdown
                            ForEach(viewModel.zoneRecords) { record in
                                ZoneRow(
                                    record: record,
                                    goalProgress: viewModel.goalProgress(forZone: record.zoneID),
                                    goalTarget: viewModel.goalTargetFormatted(forZone: record.zoneID),
                                    color: zoneColor(for: record.zoneID)
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("JayZone")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.refresh()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .onAppear { viewModel.refresh() }
        }
    }

    private func zoneColor(for zoneID: Int) -> Color {
        switch zoneID {
        case 1: return .blue
        case 2: return .green
        case 3: return .yellow
        case 4: return .orange
        case 5: return .red
        default: return .gray
        }
    }
}

// MARK: - Zone Row

struct ZoneRow: View {
    let record: ZoneTimeRecord
    let goalProgress: Double?
    let goalTarget: String?
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(color)
                    .frame(width: 12, height: 12)
                Text(record.zoneName)
                    .font(.subheadline.bold())
                Spacer()
                Text(record.formattedTime)
                    .font(.subheadline.monospacedDigit())
            }

            if let progress = goalProgress, let target = goalTarget {
                VStack(alignment: .leading, spacing: 4) {
                    ProgressView(value: progress)
                        .tint(color)
                    HStack {
                        Text("\(Int(progress * 100))% of goal")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("Goal: \(target)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
