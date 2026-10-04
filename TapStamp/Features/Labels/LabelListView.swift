import SwiftUI
import SwiftData

/// ラベル一覧。追加・編集・並べ替え・削除・テンプレートからの追加。
struct LabelListView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \TapLabel.sortOrder) private var labels: [TapLabel]

    @State private var editor: LabelEditorMode?
    @State private var pendingDelete: TapLabel?
    @State private var isTemplatePickerPresented = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(labels) { label in
                        Button {
                            editor = .edit(label)
                        } label: {
                            LabelRow(label: label)
                        }
                    }
                    .onMove(perform: move)
                    .onDelete(perform: requestDelete)
                } footer: {
                    if labels.isEmpty {
                        Text("ラベルを追加すると、記録画面を左右にスワイプして切り替えられます。")
                    } else {
                        Text("右上の「編集」で並べ替えができます。左にスワイプで削除。")
                    }
                }

                Section {
                    Button {
                        editor = .add
                    } label: {
                        Label("ラベルを追加", systemImage: "plus")
                    }
                    Button {
                        isTemplatePickerPresented = true
                    } label: {
                        Label("テンプレートから追加", systemImage: "list.bullet")
                    }
                }
            }
            .navigationTitle("ラベル")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("閉じる") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
            .sheet(item: $editor) { mode in
                LabelEditView(mode: mode)
            }
            .sheet(isPresented: $isTemplatePickerPresented) {
                TemplatePickerView(isOnboarding: false)
            }
            .confirmationDialog(
                "「\(pendingDelete?.name ?? "")」を削除しますか？",
                isPresented: Binding(isPresent: $pendingDelete),
                titleVisibility: .visible,
                presenting: pendingDelete
            ) { label in
                Button("ラベルだけ削除（記録は残す）") {
                    delete(label, deletingRecords: false)
                }
                Button("記録 \(label.records.count) 件も削除", role: .destructive) {
                    delete(label, deletingRecords: true)
                }
                Button("キャンセル", role: .cancel) {}
            } message: { label in
                Text("このラベルには \(label.records.count) 件の記録があります。「ラベルだけ削除」を選ぶと、記録は「とりあえず記録」に残ります。")
            }
            .alert("操作できませんでした", isPresented: Binding(isPresent: $errorMessage)) {
                Button("OK") {}
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    // MARK: - Actions

    private func move(from source: IndexSet, to destination: Int) {
        do {
            try LabelStore(context: context).move(fromOffsets: source, toOffset: destination)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func requestDelete(at offsets: IndexSet) {
        guard let index = offsets.first, labels.indices.contains(index) else { return }
        let label = labels[index]
        if label.records.isEmpty {
            delete(label, deletingRecords: false)
        } else {
            pendingDelete = label
        }
    }

    private func delete(_ label: TapLabel, deletingRecords: Bool) {
        do {
            try LabelStore(context: context).delete(label, deletingRecords: deletingRecords)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

/// 一覧の 1 行。
private struct LabelRow: View {
    let label: TapLabel

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(label.color)
                .frame(width: 16, height: 16)
            VStack(alignment: .leading, spacing: 2) {
                Text(label.name)
                    .foregroundStyle(.primary)
                Text("\(label.displayMode.title) ・ \(label.records.count)件")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
    }
}

/// ラベル編集シートのモード。
enum LabelEditorMode: Identifiable {
    case add
    case edit(TapLabel)

    var id: String {
        switch self {
        case .add:
            return "add"
        case .edit(let label):
            return label.id.uuidString
        }
    }
}

#Preview {
    LabelListView()
        .modelContainer(try! ModelContainerFactory.makeInMemoryContainer())
}
