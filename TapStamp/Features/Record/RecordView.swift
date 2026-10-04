import SwiftUI
import SwiftData

/// 記録画面。左右スワイプでラベルを切り替え、丸ボタンで記録する。
struct RecordView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \TapLabel.sortOrder) private var labels: [TapLabel]

    @State private var selectedPage = 0
    @State private var toast: RecordToast?
    @State private var isLabelEditorPresented = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                TabView(selection: $selectedPage) {
                    UnlabeledRecordPage(onRecord: handleRecord)
                        .tag(0)

                    ForEach(Array(labels.enumerated()), id: \.element.persistentModelID) { index, label in
                        LabeledRecordPage(label: label, onRecord: handleRecord)
                            .tag(index + 1)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                VStack(spacing: 12) {
                    if let toast {
                        UndoToast(toast: toast, onUndo: undoLastRecord)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    PageDots(count: labels.count + 1, current: selectedPage, color: currentColor)
                }
                .padding(.bottom, 8)
            }
            .navigationTitle("記録")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isLabelEditorPresented = true
                    } label: {
                        Image(systemName: "tag")
                    }
                    .accessibilityLabel("ラベルを編集")
                }
            }
            .sheet(isPresented: $isLabelEditorPresented) {
                LabelListView()
            }
            .onChange(of: labels.count) { _, newCount in
                if selectedPage > newCount {
                    selectedPage = newCount
                }
            }
            .task(id: toast?.id) {
                await dismissToastAfterDelay()
            }
        }
    }

    private var currentColor: Color {
        let index = selectedPage - 1
        guard labels.indices.contains(index) else { return .unlabeled }
        return labels[index].color
    }

    // MARK: - Actions

    private func handleRecord(_ label: TapLabel?) {
        do {
            let record = try RecordStore(context: context).record(label: label)
            let prefix = label.map { "\($0.name)を" } ?? ""
            let text = "\(prefix)記録しました \(RelativeTimeFormatter.clock(record.timestamp))"
            withAnimation(.snappy) {
                toast = RecordToast(record: record, text: text, canUndo: true, duration: 4)
            }
        } catch {
            withAnimation(.snappy) {
                toast = RecordToast(record: nil, text: "記録できませんでした", canUndo: false, duration: 3)
            }
        }
    }

    private func undoLastRecord() {
        guard let record = toast?.record else { return }
        do {
            try RecordStore(context: context).delete(record)
            withAnimation(.snappy) {
                toast = RecordToast(record: nil, text: "取り消しました", canUndo: false, duration: 1.5)
            }
        } catch {
            withAnimation(.snappy) {
                toast = RecordToast(record: nil, text: "取り消せませんでした", canUndo: false, duration: 3)
            }
        }
    }

    private func dismissToastAfterDelay() async {
        guard let current = toast else { return }
        try? await Task.sleep(for: .seconds(current.duration))
        guard !Task.isCancelled, toast?.id == current.id else { return }
        withAnimation(.easeOut(duration: 0.25)) {
            toast = nil
        }
    }
}

/// 記録直後に画面下へ出す通知の内容。
struct RecordToast: Identifiable {
    let id = UUID()
    let record: TapRecord?
    let text: String
    let canUndo: Bool
    let duration: TimeInterval
}

// MARK: - Pages

/// 1 ページ目「とりあえず記録」。
private struct UnlabeledRecordPage: View {
    let onRecord: (TapLabel?) -> Void

    @Query(filter: #Predicate<TapRecord> { $0.label == nil }, sort: \TapRecord.timestamp, order: .reverse)
    private var records: [TapRecord]

    var body: some View {
        RecordPageView(
            title: "とりあえず記録",
            color: .unlabeled,
            timestamps: records.map(\.timestamp)
        ) {
            onRecord(nil)
        }
    }
}

/// ラベル付きのページ。
private struct LabeledRecordPage: View {
    let label: TapLabel
    let onRecord: (TapLabel?) -> Void

    @Query private var records: [TapRecord]

    init(label: TapLabel, onRecord: @escaping (TapLabel?) -> Void) {
        self.label = label
        self.onRecord = onRecord
        let labelID: UUID? = label.id
        _records = Query(
            filter: #Predicate<TapRecord> { $0.label?.id == labelID },
            sort: \TapRecord.timestamp,
            order: .reverse
        )
    }

    var body: some View {
        RecordPageView(
            title: label.name,
            color: label.color,
            timestamps: records.map(\.timestamp)
        ) {
            onRecord(label)
        }
    }
}

#Preview {
    RecordView()
        .modelContainer(try! ModelContainerFactory.makeInMemoryContainer())
}
