import SwiftUI

/// 回数向け（frequency）のセクション群。
struct FrequencySections: View {
    let timestamps: [Date]
    let color: Color

    var body: some View {
        Section {
            TimelineView(.periodic(from: .now, by: 60)) { timeline in
                let now = timeline.date
                HStack(spacing: 12) {
                    StatCard(
                        title: "前回から",
                        value: Statistics.latest(timestamps).map { RelativeTimeFormatter.elapsed(from: $0, to: now) } ?? "—",
                        color: color
                    )
                    StatCard(
                        title: "今日",
                        value: "\(Statistics.todayCount(timestamps, now: now))回",
                        color: AppTheme.accent
                    )
                }
            }
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)

        Section {
            VStack(alignment: .leading, spacing: 12) {
                CardTitle(
                    title: "直近7日",
                    detail: "合計 \(Statistics.recentDaysCount(timestamps, days: 7))回"
                )
                DailyCountChart(counts: Statistics.dailyCounts(timestamps, days: 7), color: color)
                    .frame(height: 150)
            }
            .padding(.vertical, 6)
        }
        .listRowBackground(AppTheme.card)

        Section {
            VStack(alignment: .leading, spacing: 12) {
                CardTitle(title: "曜日 × 時間帯", detail: "直近4週間")
                WeekdayHourHeatmap(cells: Statistics.weekdayHourCounts(timestamps, weeks: 4), color: color)
                    .frame(height: 190)
            }
            .padding(.vertical, 6)
        }
        .listRowBackground(AppTheme.card)
    }
}
