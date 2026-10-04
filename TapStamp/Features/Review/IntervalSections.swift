import SwiftUI

/// 間隔向け（interval）のセクション群。
struct IntervalSections: View {
    let timestamps: [Date]
    let color: Color

    var body: some View {
        Section {
            TimelineView(.periodic(from: .now, by: 60)) { timeline in
                let now = timeline.date
                let summary = Statistics.intervalSummary(timestamps)

                VStack(alignment: .leading, spacing: 14) {
                    if let latest = Statistics.latest(timestamps) {
                        let days = Statistics.daysSince(latest, now: now)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("前回から")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(days <= 0 ? "今日" : "\(days)日")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundStyle(color)
                                .monospacedDigit()
                            Text("前回: \(RelativeTimeFormatter.full(latest))")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if let average = summary.average {
                        HStack(alignment: .top, spacing: 28) {
                            StatTile(
                                title: "平均間隔（直近\(summary.sampleCount)回）",
                                value: RelativeTimeFormatter.duration(average)
                            )
                            if let shortest = summary.shortest, let longest = summary.longest {
                                StatTile(
                                    title: "最短 / 最長",
                                    value: "\(RelativeTimeFormatter.duration(shortest)) / \(RelativeTimeFormatter.duration(longest))"
                                )
                            }
                        }
                    } else {
                        Text("2回以上記録すると、間隔が表示されます。")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
}
