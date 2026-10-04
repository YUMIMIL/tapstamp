import SwiftUI

/// 間隔向け（interval）のセクション群。
struct IntervalSections: View {
    let timestamps: [Date]
    let color: Color

    private var summary: IntervalSummary {
        Statistics.intervalSummary(timestamps)
    }

    var body: some View {
        Section {
            TimelineView(.periodic(from: .now, by: 60)) { timeline in
                let now = timeline.date
                HStack(spacing: 12) {
                    StatCard(
                        title: "前回から",
                        value: Statistics.latest(timestamps).map { latest in
                            let days = Statistics.daysSince(latest, now: now)
                            return days <= 0 ? "今日" : "\(days)日"
                        } ?? "—",
                        color: color
                    )
                    StatCard(
                        title: summary.average == nil ? "平均間隔" : "平均間隔（直近\(summary.sampleCount)回）",
                        value: summary.average.map { RelativeTimeFormatter.duration($0) } ?? "—",
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
                CardTitle(title: "間隔のようす")
                if let shortest = summary.shortest, let longest = summary.longest {
                    LabeledContent("最短", value: RelativeTimeFormatter.duration(shortest))
                    LabeledContent("最長", value: RelativeTimeFormatter.duration(longest))
                } else {
                    Text("2回以上記録すると、間隔が表示されます。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                if let latest = Statistics.latest(timestamps) {
                    LabeledContent("前回", value: RelativeTimeFormatter.full(latest))
                }
            }
            .padding(.vertical, 6)
        }
        .listRowBackground(AppTheme.card)
    }
}
