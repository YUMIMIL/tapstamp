import SwiftUI
import SwiftData

/// ふりかえりの本体。ラベルの表示モードで「回数向け」「間隔向け」を切り替える。
struct ReviewContent: View {
    let label: TapLabel?
    /// 新しい順
    let records: [TapRecord]

    @Environment(\.modelContext) private var context
    @State private var editingRecord: TapRecord?
    @State private var visibleCount = 100
    @State private var errorMessage: String?

    private var mode: DisplayMode { label?.displayMode ?? .frequency }
    private var color: Color { label?.color ?? .unlabeled }
    private var title: String { label?.name ?? "とりあえず記録" }
    private var timestamps: [Date] { records.map(\.timestamp) }

    var body: some View {
        List {
            Section {
                ReviewHeader(title: title, color: color)
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)

            if records.isEmpty {
                Section {
                    ContentUnavailableView(
                        "まだ記録がありません",
                        systemImage: "hand.tap",
                        description: Text("記録タブの丸いボタンを押すと、ここに表示されます。")
                    )
                    .padding(.vertical, 8)
                }
                .listRowBackground(AppTheme.card)
            } else {
                switch mode {
                case .frequency:
                    FrequencySections(timestamps: timestamps, color: color)
                case .interval:
                    IntervalSections(timestamps: timestamps, color: color)
                }

                RecordListSection(
                    records: Array(records.prefix(visibleCount)),
                    totalCount: records.count,
                    showsInterval: mode == .interval,
                    onEdit: { editingRecord = $0 },
                    onDelete: delete
                )

                if records.count > visibleCount {
                    Section {
                        Button("もっと見る（残り \(records.count - visibleCount) 件）") {
                            visibleCount += 100
                        }
                    }
                    .listRowBackground(AppTheme.card)
                }
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(14)
        .themedScreenBackground()
        .sheet(item: $editingRecord) { record in
            RecordEditSheet(record: record)
        }
        .alert("削除できませんでした", isPresented: Binding(isPresent: $errorMessage)) {
            Button("OK") {}
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private func delete(_ targets: [TapRecord]) {
        let store = RecordStore(context: context)
        do {
            for record in targets {
                try store.delete(record)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

/// ラベルの丸いアイコンと「最近どう？」の見出し。
private struct ReviewHeader: View {
    let title: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.22))
                    .frame(width: 60, height: 60)
                Text(String(title.prefix(1)))
                    .font(.title2.weight(.bold))
                    .foregroundStyle(color)
            }
            VStack(spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("最近どう？")
                    .font(.title2.weight(.bold))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }
}

/// 「前回から 42分」のような数値カード。
struct StatCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            AppTheme.card,
            in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
        )
        .accessibilityElement(children: .combine)
    }
}

/// カードの見出し行。
struct CardTitle: View {
    let title: String
    var detail: String? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.headline)
            Spacer()
            if let detail {
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
