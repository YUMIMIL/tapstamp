import SwiftUI
import Charts

/// 曜日（7 行）× 時間帯（24 列）のヒートマップ。
struct WeekdayHourHeatmap: View {
    let cells: [HeatmapCell]
    let color: Color

    private static let weekdayNames = ["日", "月", "火", "水", "木", "金", "土"]
    private static let hourTicks: [Double] = [0, 6, 12, 18, 24]

    var body: some View {
        let maxCount = cells.map(\.count).max() ?? 0

        Chart(cells) { cell in
            RectangleMark(
                xStart: .value("時", Double(cell.hour) + 0.06),
                xEnd: .value("時", Double(cell.hour) + 0.94),
                y: .value("曜日", Self.weekdayNames[cell.weekday - 1]),
                height: .ratio(0.86)
            )
            .foregroundStyle(fill(for: cell.count, maxCount: maxCount))
            .cornerRadius(2)
        }
        .chartXScale(domain: 0.0...24.0)
        .chartYScale(domain: Self.weekdayNames)
        .chartXAxis {
            AxisMarks(values: Self.hourTicks) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let hour = value.as(Double.self) {
                        Text("\(Int(hour))時")
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisValueLabel()
            }
        }
        .accessibilityLabel("曜日と時間帯ごとの回数")
    }

    private func fill(for count: Int, maxCount: Int) -> Color {
        guard count > 0, maxCount > 0 else {
            return Color.secondary.opacity(0.08)
        }
        let ratio = Double(count) / Double(maxCount)
        return color.opacity(0.25 + 0.75 * ratio)
    }
}

#Preview {
    WeekdayHourHeatmap(
        cells: (1...7).flatMap { weekday in
            (0..<24).map { hour in
                HeatmapCell(weekday: weekday, hour: hour, count: (weekday * hour) % 5 == 0 ? (hour % 4) : 0)
            }
        },
        color: Color(LabelColor.teal)
    )
    .frame(height: 200)
    .padding()
}
