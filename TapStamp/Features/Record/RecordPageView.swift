import SwiftUI

/// 記録画面の 1 ページ分。ラベル名・今日の回数・前回からの経過・丸ボタン。
struct RecordPageView: View {
    let title: String
    let color: Color
    /// 新しい順でなくてもよい
    let timestamps: [Date]
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 6) {
                Text(title)
                    .font(.title2.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                TimelineView(.periodic(from: .now, by: 60)) { timeline in
                    Text(summary(now: timeline.date))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }
            .padding(.top, 16)
            .padding(.horizontal, 24)

            Spacer()

            TapButton(color: color, action: onTap)

            Spacer()

            // ページドットとトーストのぶんの余白
            Color.clear.frame(height: 72)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func summary(now: Date) -> String {
        guard let latest = Statistics.latest(timestamps) else {
            return "まだ記録がありません"
        }
        let today = Statistics.todayCount(timestamps, now: now)
        return "今日 \(today)回 ・ 前回 \(RelativeTimeFormatter.ago(from: latest, to: now))"
    }
}

/// ページの位置を示すドット。現在のページはラベル色。
struct PageDots: View {
    let count: Int
    let current: Int
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<max(count, 1), id: \.self) { index in
                Circle()
                    .fill(index == current ? color : Color.secondary.opacity(0.3))
                    .frame(width: index == current ? 9 : 7, height: index == current ? 9 : 7)
            }
        }
        .animation(.snappy, value: current)
        .accessibilityHidden(true)
    }
}

#Preview {
    RecordPageView(title: "薬", color: Color(LabelColor.blue), timestamps: [.now.addingTimeInterval(-600)]) {}
}
