import SwiftUI

/// 曜日（7 行、月曜始まり）× 時間帯（24 列）のヒートマップ。
/// 行とラベルを確実に揃えるため、Swift Charts を使わずマス目を直接描く。
struct WeekdayHourHeatmap: View {
    let cells: [HeatmapCell]
    let color: Color

    /// 表示順（月〜日）と `Calendar.weekday`（1 = 日曜）の対応
    private static let rows: [(name: String, weekday: Int)] = [
        ("月", 2), ("火", 3), ("水", 4), ("木", 5), ("金", 6), ("土", 7), ("日", 1),
    ]
    private static let labelWidth: CGFloat = 22
    private static let spacing: CGFloat = 2
    private static let cellHeight: CGFloat = 18

    var body: some View {
        let counts = Dictionary(uniqueKeysWithValues: cells.map { ($0.id, $0.count) })
        let maxCount = cells.map(\.count).max() ?? 0

        VStack(alignment: .leading, spacing: Self.spacing) {
            // 時刻の見出し（0・6・12・18 時）
            HStack(spacing: Self.spacing) {
                Color.clear.frame(width: Self.labelWidth, height: 1)
                ForEach(0..<24, id: \.self) { hour in
                    ZStack(alignment: .leading) {
                        Color.clear
                        if hour % 6 == 0 {
                            Text("\(hour)時")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .fixedSize()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 16)
                }
            }
            .padding(.bottom, 2)

            ForEach(Self.rows, id: \.weekday) { row in
                HStack(spacing: Self.spacing) {
                    Text(row.name)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(width: Self.labelWidth, alignment: .leading)
                    ForEach(0..<24, id: \.self) { hour in
                        let count = counts[row.weekday * 100 + hour] ?? 0
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(fill(for: count, maxCount: maxCount))
                            .frame(maxWidth: .infinity)
                            .frame(height: Self.cellHeight)
                    }
                }
            }
        }
        .accessibilityElement(children: .ignore)
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
        color: Color(LabelColor.teal)
    )
    .padding()
}
