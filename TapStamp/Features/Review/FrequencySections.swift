import SwiftUI

/// 回数向け（frequency）のセクション群。
struct FrequencySections: View {
    let timestamps: [Date]
    let color: Color

    var body: some View {
        Section {
            TimelineView(.periodic(from: .now, by: 60)) { timeline in
                let now = timeline.date
                VStack(alignment: .leading, spacing: 14) {
                    if let latest = Statistics.latest(timestamps) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("前回から")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(RelativeTimeFormatter.elapsed(from: latest, to: now))
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundStyle(color)
                                .monospacedDigit()
                            Text("前回: \(RelativeTimeFormatter.full(latest))")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }

                    HStack(spacing: 28) {
                        StatTile(title: "今日", value: "\(Statistics.todayCount(timestamps, now: now))回")
                        StatTile(title: "直近7日", value: "\(Statistics.recentDaysCount(timestamps, days: 7, now: now))回")
                        StatTile(title: "合計", value: "\(timestamps.count)回")
                    }
                }
                .padding(.vertical, 4)
            }
        }

        Section("直近7日の回数") {
            DailyCountChart(counts: Statistics.dailyCounts(timestamps, days: 7), color: color)
                .frame(height: 170)
                .padding(.vertical, 8)
        }

        Section("曜日 × 時間帯（直近4週間）") {
            WeekdayHourHeatmap(cells: Statistics.weekdayHourCounts(timestamps, weeks: 4), color: color)
                .frame(height: 200)
                .padding(.vertical, 8)
        }
    }
}
