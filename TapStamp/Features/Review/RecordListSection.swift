import SwiftUI

/// 記録一覧。スワイプで削除、タップで時刻修正。
struct RecordListSection: View {
    /// 新しい順
    let records: [TapRecord]
    let totalCount: Int
    /// 各行に「前回から◯日」を出す（間隔モード）
    let showsInterval: Bool
    let onEdit: (TapRecord) -> Void
    let onDelete: ([TapRecord]) -> Void

    var body: some View {
        Section {
            ForEach(Array(records.enumerated()), id: \.element.id) { index, record in
                Button {
                    onEdit(record)
                } label: {
                    HStack {
                        Text(RelativeTimeFormatter.full(record.timestamp))
                            .foregroundStyle(.primary)
                            .monospacedDigit()
                        Spacer()
                        if showsInterval, index + 1 < records.count {
                            Text(intervalText(previous: records[index + 1].timestamp, current: record.timestamp))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                    }
                }
            }
            .onDelete { offsets in
                onDelete(offsets.map { records[$0] })
            }
        } header: {
            Text("記録（\(totalCount)件）")
        } footer: {
            Text("タップで日時を修正、左にスワイプで削除できます。")
        }
    }

    private func intervalText(previous: Date, current: Date) -> String {
        let days = Statistics.daysSince(previous, now: current)
        return days <= 0 ? "同じ日" : "前回から\(days)日"
    }
}
