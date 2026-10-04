import SwiftUI
import SwiftData

/// 記録画面。左右スワイプでラベルを切り替え、丸ボタンで記録する。
struct RecordView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \TapLabel.sortOrder) private var labels: [TapLabel]

    @State private var currentPageID: String? = RecordPage.unlabeledID
    @State private var toast: RecordToast?
    @State private var isLabelEditorPresented = false

    private var pages: [RecordPage] {
        [.unlabeled] + labels.map { .label($0) }
    }

    private var currentIndex: Int {
        pages.firstIndex { $0.id == currentPageID } ?? 0
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                AppTheme.background.ignoresSafeArea()

                RecordCarousel(pages: pages, currentPageID: $currentPageID, onRecord: handleRecord)

                VStack(spacing: 16) {
                    if let toast {
                        UndoToast(toast: toast, onUndo: undoLastRecord)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    PageDots(count: pages.count, current: currentIndex, color: pages[currentIndex].color)
                }
                .padding(.bottom, 10)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isLabelEditorPresented = true
                    } label: {
                        Image(systemName: "tag")
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityLabel("ラベルを編集")
                }
            }
            .sheet(isPresented: $isLabelEditorPresented) {
                LabelListView()
            }
            .onChange(of: labels.count) { _, _ in
                // 現在のページが消えたら先頭に戻す
                if !pages.contains(where: { $0.id == currentPageID }) {
                    currentPageID = RecordPage.unlabeledID
                }
            }
            .task(id: toast?.id) {
                await dismissToastAfterDelay()
            }
        }
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

/// 記録画面の 1 ページ。
enum RecordPage: Identifiable, Hashable {
    case unlabeled
    case label(TapLabel)

    static let unlabeledID = "unlabeled"

    var id: String {
        switch self {
        case .unlabeled:
            return Self.unlabeledID
        case .label(let label):
            return label.id.uuidString
        }
    }

    var label: TapLabel? {
        if case .label(let label) = self { return label }
        return nil
    }

    var title: String {
        label?.name ?? "とりあえず記録"
    }

    var color: Color {
        label?.color ?? .unlabeled
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

#Preview {
    RecordView()
        .modelContainer(try! ModelContainerFactory.makeInMemoryContainer())
}
