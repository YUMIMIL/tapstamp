import SwiftUI
import Charts

/// 直近 N 日の日別回数の棒グラフ。今日の棒だけ濃い色。
struct DailyCountChart: View {
    let counts: [DayCount]
    let color: Color

    var body: some View {
        let today = Calendar.current.startOfDay(for: .now)
        let upperBound = max(counts.map(\.count).max() ?? 0, 3)

        Chart(counts) { item in
            BarMark(
                x: .value("日", item.date, unit: .day),
                y: .value("回数", item.count)
            )
            .foregroundStyle(item.date == today ? color : color.opacity(0.45))
            .cornerRadius(4)
            .annotation(position: .top, spacing: 2) {
                if item.count > 0 {
                    Text("\(item.count)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .chartYScale(domain: 0...upperBound)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { _ in
                AxisValueLabel(format: .dateTime.day(), centered: true)
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic(desiredCount: 3)) { _ in
                AxisGridLine()
                AxisValueLabel()
            }
        }
        .accessibilityLabel("直近7日の日別回数")
    }
}

#Preview {
    DailyCountChart(
        counts: (0..<7).map { offset in
            DayCount(
                date: Calendar.current.date(byAdding: .day, value: offset - 6, to: Calendar.current.startOfDay(for: .now))!,
                count: [2, 0, 1, 4, 3, 0, 2][offset]
            )
        },
        color: Color(LabelColor.blue)
    )
    .frame(height: 170)
    .padding()
}
