import SwiftUI

/// A horizontal stacked bar showing relative time per zone.
struct ZoneBarChartView: View {
    let records: [ZoneTimeRecord]

    private var totalSeconds: TimeInterval {
        records.reduce(0) { $0 + $1.totalSeconds }
    }

    var body: some View {
        if totalSeconds > 0 {
            VStack(alignment: .leading, spacing: 8) {
                Text("Zone Distribution")
                    .font(.caption)
                    .foregroundColor(.secondary)

                GeometryReader { geo in
                    HStack(spacing: 2) {
                        ForEach(records) { record in
                            let fraction = record.totalSeconds / totalSeconds
                            if fraction > 0 {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(colorFor(record.zoneID))
                                    .frame(width: max(geo.size.width * fraction - 2, 2))
                            }
                        }
                    }
                }
                .frame(height: 28)
                .clipShape(RoundedRectangle(cornerRadius: 6))

                // Legend
                HStack(spacing: 12) {
                    ForEach(records) { record in
                        if record.totalSeconds > 0 {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(colorFor(record.zoneID))
                                    .frame(width: 8, height: 8)
                                Text("Z\(record.zoneID)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }

    private func colorFor(_ zoneID: Int) -> Color {
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
