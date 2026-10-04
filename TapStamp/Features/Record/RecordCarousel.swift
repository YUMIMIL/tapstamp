import SwiftUI
import SwiftData

/// ページの位置関係。
enum PageRelation: Equatable {
    case before, current, after
}

/// 左右に隣のラベルの丸が少し見えるカルーセル。
struct RecordCarousel: View {
    let pages: [RecordPage]
    @Binding var currentPageID: String?
    let onRecord: (TapLabel?) -> Void

    /// 隣のページが見える幅
    private let peek: CGFloat = 60

    private var currentIndex: Int {
        pages.firstIndex { $0.id == currentPageID } ?? 0
    }

    var body: some View {
        GeometryReader { geometry in
            let itemWidth = max(geometry.size.width - peek * 2, 200)

            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        RecordCarouselItem(
                            page: page,
                            relation: relation(of: index),
                            onTap: {
                                if index == currentIndex {
                                    onRecord(page.label)
                                } else {
                                    withAnimation(.snappy) {
                                        currentPageID = page.id
                                    }
                                }
                            }
                        )
                        .frame(width: itemWidth, height: geometry.size.height)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $currentPageID)
            .contentMargins(.horizontal, peek, for: .scrollContent)
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
        }
    }

    private func relation(of index: Int) -> PageRelation {
        if index < currentIndex { return .before }
        if index > currentIndex { return .after }
        return .current
    }
}

/// カルーセルの 1 ページ分。タイトル・今日の回数・前回・丸ボタン。
private struct RecordCarouselItem: View {
    let page: RecordPage
    let relation: PageRelation
    let onTap: () -> Void

    @Query private var records: [TapRecord]

    init(page: RecordPage, relation: PageRelation, onTap: @escaping () -> Void) {
        self.page = page
        self.relation = relation
        self.onTap = onTap

        if let label = page.label {
            let labelID: UUID? = label.id
            _records = Query(
                filter: #Predicate<TapRecord> { $0.label?.id == labelID },
                sort: \TapRecord.timestamp,
                order: .reverse
            )
        } else {
            _records = Query(
                filter: #Predicate<TapRecord> { $0.label == nil },
                sort: \TapRecord.timestamp,
                order: .reverse
            )
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Text(page.title)
                    .font(.system(size: 30, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)

                TimelineView(.periodic(from: .now, by: 60)) { timeline in
                    Text(summary(now: timeline.date))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }
            .padding(.top, 12)
            .padding(.horizontal, 8)
            .opacity(relation == .current ? 1 : 0)

            Spacer()

            RecordCircle(title: page.title, color: page.color, relation: relation, action: onTap)

            Spacer()

            // ページドットとトーストのぶんの余白
            Color.clear.frame(height: 96)
        }
        .animation(.snappy, value: relation)
    }

    private func summary(now: Date) -> String {
        let timestamps = records.map(\.timestamp)
        guard let latest = Statistics.latest(timestamps) else {
            return "まだ記録がありません"
        }
        let today = Statistics.todayCount(timestamps, now: now)
        return "今日 \(today)回 ・ 前回 \(RelativeTimeFormatter.ago(from: latest, to: now))"
    }
}

/// 大きな丸。現在のページでは記録ボタン、隣のページでは薄い丸にラベル名を出す。
struct RecordCircle: View {
    static let diameter: CGFloat = 240

    let title: String
    let color: Color
    let relation: PageRelation
    let action: () -> Void

    @State private var tapCount = 0

    var body: some View {
        Button {
            if relation == .current {
                tapCount += 1
            }
            action()
        } label: {
            ZStack {
                if relation == .current {
                    Circle()
                        .fill(color)
                        .shadow(color: color.opacity(0.35), radius: 22, x: 0, y: 12)

                    VStack(spacing: 14) {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 36, weight: .regular))
                        Text("タップして記録")
                            .font(.system(size: 22, weight: .bold))
                    }
                    .foregroundStyle(.white)
                } else {
                    Circle()
                        .fill(color.opacity(0.28))

                    HStack(spacing: 6) {
                        if relation == .after {
                            Image(systemName: "chevron.right")
                        }
                        Text(title)
                            .lineLimit(1)
                        if relation == .before {
                            Image(systemName: "chevron.left")
                        }
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(color)
                    .frame(maxWidth: .infinity, alignment: relation == .after ? .leading : .trailing)
                    .padding(.horizontal, 22)
                }
            }
            .frame(width: Self.diameter, height: Self.diameter)
            .scaleEffect(relation == .current ? 1 : 0.92)
            .contentShape(Circle())
        }
        .buttonStyle(ShrinkButtonStyle())
        .sensoryFeedback(.impact(weight: .medium), trigger: tapCount)
        .accessibilityLabel(relation == .current ? "\(title)を記録する" : "\(title)に切り替える")
    }
}

/// 押している間だけ少し縮むボタンスタイル。
struct ShrinkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.93 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.6), value: configuration.isPressed)
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
                    .fill(index == current ? color : Color.secondary.opacity(0.25))
                    .frame(width: index == current ? 9 : 7, height: index == current ? 9 : 7)
            }
        }
        .animation(.snappy, value: current)
        .accessibilityHidden(true)
    }
}

#Preview {
    RecordView()
        .modelContainer(try! ModelContainerFactory.makeInMemoryContainer())
}
