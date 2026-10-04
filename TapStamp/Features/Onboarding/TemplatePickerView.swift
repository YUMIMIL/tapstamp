import SwiftUI
import SwiftData

/// テンプレートからラベルをまとめて追加する。初回起動時は全画面、ラベル一覧からはシートで使う。
struct TemplatePickerView: View {
    let isOnboarding: Bool
    var onFinish: () -> Void = {}

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var existingLabels: [TapLabel]
    @State private var selectedIDs: Set<String> = []
    @State private var errorMessage: String?

    private var existingNames: Set<String> {
        Set(existingLabels.map(\.name))
    }

    private var selectedTemplates: [LabelTemplate] {
        TemplateCatalog.all.filter { selectedIDs.contains($0.id) }
    }

    var body: some View {
        NavigationStack {
            List {
                if isOnboarding {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("タップするだけで、今の日時を記録します。")
                                .font(.headline)
                            Text("よく使うものを選んでおくと、記録画面を左右にスワイプして切り替えられます。あとからいつでも変更できます。")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section {
                    ForEach(TemplateCatalog.all) { template in
                        let alreadyExists = existingNames.contains(template.name)
                        let isSelected = selectedIDs.contains(template.id)
                        Button {
                            toggle(template.id)
                        } label: {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color(template.color))
                                    .frame(width: 14, height: 14)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(template.name)
                                        .foregroundStyle(.primary)
                                    Text(template.displayMode.title)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if alreadyExists {
                                    Text("追加済み")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                } else {
                                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                        .font(.title3)
                                        .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                                }
                            }
                        }
                        .disabled(alreadyExists)
                    }
                } header: {
                    Text(isOnboarding ? "テンプレート" : "追加するものを選んでください")
                }
            }
            .navigationTitle(isOnboarding ? "はじめに" : "テンプレート")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(isOnboarding ? "あとで設定" : "キャンセル") {
                        finish()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isOnboarding ? "この内容ではじめる" : "追加") {
                        add()
                    }
                    .fontWeight(.semibold)
                    .disabled(selectedIDs.isEmpty)
                }
            }
            .alert("追加できませんでした", isPresented: Binding(isPresent: $errorMessage)) {
                Button("OK") {}
            } message: {
                Text(errorMessage ?? "")
            }
        }
        .interactiveDismissDisabled(isOnboarding)
    }

    // MARK: - Actions

    private func toggle(_ id: String) {
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
    }

    private func add() {
        do {
            try LabelStore(context: context).add(templates: selectedTemplates)
            finish()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func finish() {
        if isOnboarding {
            onFinish()
        } else {
            dismiss()
        }
    }
}

#Preview {
    TemplatePickerView(isOnboarding: true)
        .modelContainer(try! ModelContainerFactory.makeInMemoryContainer())
}
