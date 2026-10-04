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
    private var timestamps: [Date] { records.map(\.timestamp) }

    var body: some View {
        List {
            if records.isEmpty {
                Section {
                    ContentUnavailableView(
                        "まだ記録がありません",
                        systemImage: "hand.tap",
                        description: Text("記録タブの丸いボタンを押すと、ここに表示されます。")
                    )
                }
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
                }
            }
        }
        .listStyle(.insetGrouped)
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

/// 「今日 3回」のような小さな数値表示。
struct StatTile: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.weight(.semibold))
                .monospacedDigit()
        }
        .accessibilityElement(children: .combine)
    }
}
