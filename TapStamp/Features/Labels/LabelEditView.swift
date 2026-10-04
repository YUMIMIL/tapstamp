import SwiftUI
import SwiftData

/// ラベルの追加・編集フォーム。
struct LabelEditView: View {
    let mode: LabelEditorMode

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var color: LabelColor
    @State private var displayMode: DisplayMode
    @State private var errorMessage: String?
    @FocusState private var isNameFocused: Bool

    init(mode: LabelEditorMode) {
        self.mode = mode
        switch mode {
        case .add:
            _name = State(initialValue: "")
            _color = State(initialValue: .blue)
            _displayMode = State(initialValue: .frequency)
        case .edit(let label):
            _name = State(initialValue: label.name)
            _color = State(initialValue: label.labelColor)
            _displayMode = State(initialValue: label.displayMode)
        }
    }

    private var isNew: Bool {
        if case .add = mode { return true }
        return false
    }

    private var trimmedName: String {
        LabelStore.normalized(name)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("名前") {
                    TextField("例: 薬、トイレ、シーツ交換", text: $name)
                        .focused($isNameFocused)
                        .submitLabel(.done)
                }

                Section("色") {
                    LabelColorPicker(selection: $color)
                }

                Section {
                    Picker("ふりかえりの表示", selection: $displayMode) {
                        ForEach(DisplayMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    Text(displayMode.caption)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("ふりかえりの表示")
                }

                Section("プレビュー") {
                    HStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(Color(color).gradient)
                                .frame(width: 88, height: 88)
                            Text("記録")
                                .font(.headline)
                                .foregroundStyle(.white)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(isNew ? "ラベルを追加" : "ラベルを編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                        .disabled(trimmedName.isEmpty)
                }
            }
            .alert("保存できませんでした", isPresented: Binding(isPresent: $errorMessage)) {
                Button("OK") {}
            } message: {
                Text(errorMessage ?? "")
            }
            .onAppear {
                if isNew { isNameFocused = true }
            }
        }
    }

    private func save() {
        let store = LabelStore(context: context)
        do {
            switch mode {
            case .add:
                try store.add(name: trimmedName, color: color, displayMode: displayMode)
            case .edit(let label):
                try store.update(label, name: trimmedName, color: color, displayMode: displayMode)
            }
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    LabelEditView(mode: .add)
        .modelContainer(try! ModelContainerFactory.makeInMemoryContainer())
}
