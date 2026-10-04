import SwiftUI
import Charts

/// 曜日（7 行、月曜始まり）× 時間帯（24 列）のヒートマップ。
struct WeekdayHourHeatmap: View {
    let cells: [HeatmapCell]
    let color: Color

    /// 表示順（月〜日）
    private static let weekdayOrder = ["月", "火", "水", "木", "金", "土", "日"]
    /// `Calendar.weekday`（1 = 日曜）→ 表示名
    private static let weekdayNames = ["日", "月", "火", "水", "木", "金", "土"]
    private static let hourTicks: [Double] = [0, 6, 12, 18, 24]

    var body: some View {
        let maxCount = cells.map(\.count).max() ?? 0

        Chart(cells) { cell in
            RectangleMark(
                xStart: .value("時", Double(cell.hour) + 0.08),
                xEnd: .value("時", Double(cell.hour) + 0.92),
                y: .value("曜日", Self.weekdayNames[cell.weekday - 1]),
                height: .ratio(0.8)
            )
            .foregroundStyle(fill(for: cell.count, maxCount: maxCount))
            .cornerRadius(2)
        }
        .chartXScale(domain: 0.0...24.0)
        .chartYScale(domain: Self.weekdayOrder)
        .chartXAxis {
            AxisMarks(position: .top, values: Self.hourTicks) { value in
                AxisValueLabel(anchor: .bottomLeading) {
                    if let hour = value.as(Double.self), hour < 24 {
                        Text("\(Int(hour))時")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisValueLabel()
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityLabel("曜日と時間帯ごとの回数")
    }

    private func fill(for count: Int, maxCount: Int) -> Color {
        guard count > 0, maxCount > 0 else {
            return color.opacity(0.10)
        }
        let ratio = Double(count) / Double(maxCount)
        return color.opacity(0.3 + 0.7 * ratio)
    }
}

#Preview {
    WeekdayHourHeatmap(
        cells: (1...7).flatMap { weekday in
            (0..<24).map { hour in
                HeatmapCell(weekday: weekday, hour: hour, count: (weekday * hour) % 5 == 0 ? (hour % 4) : 0)
            }
        },
        color: Color(LabelColor.green)
    )
    .frame(height: 190)
    .padding()
}
