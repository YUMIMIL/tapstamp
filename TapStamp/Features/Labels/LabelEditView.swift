import SwiftUI
import SwiftData

/// ラベルの追加・編集。名前・カラー・見たいもの を選び、下の「保存」で確定する。
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
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                fieldBlock("名前") {
                    HStack(spacing: 8) {
                        TextField("例: 薬、トイレ、シーツ交換", text: $name)
                            .font(.title3)
                            .focused($isNameFocused)
                            .submitLabel(.done)
                        if !name.isEmpty {
                            Button {
                                name = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.tertiary)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("名前を消去")
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        AppTheme.card,
                        in: RoundedRectangle(cornerRadius: AppTheme.fieldCornerRadius, style: .continuous)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.fieldCornerRadius, style: .continuous)
                            .stroke(isNameFocused ? AppTheme.accent : AppTheme.border, lineWidth: 1.5)
                    )
                }

                fieldBlock("カラー") {
                    LabelColorPicker(selection: $color)
                }

                fieldBlock("見たいもの") {
                    VStack(spacing: 12) {
                        ForEach(DisplayMode.allCases) { option in
                            DisplayModeOptionCard(mode: option, isSelected: displayMode == option) {
                                displayMode = option
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(AppTheme.background.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            Button {
                save()
            } label: {
                Text("保存")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .tint(AppTheme.accent)
            .disabled(trimmedName.isEmpty)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(AppTheme.background)
        }
        .navigationTitle(isNew ? "ラベルを追加" : "ラベル編集")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppTheme.background, for: .navigationBar)
        .alert("保存できませんでした", isPresented: Binding(isPresent: $errorMessage)) {
            Button("OK") {}
        } message: {
            Text(errorMessage ?? "")
        }
        .onAppear {
            if isNew { isNameFocused = true }
        }
    }

    @ViewBuilder
    private func fieldBlock<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            content()
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

/// 「回数・頻度」「間隔」を選ぶカード型のラジオボタン。
private struct DisplayModeOptionCard: View {
    let mode: DisplayMode
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(isSelected ? AppTheme.accent : AppTheme.border, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    if isSelected {
                        Circle()
                            .fill(AppTheme.accent)
                            .frame(width: 12, height: 12)
                    }
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(mode.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(mode.caption)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }
            .padding(16)
            .background(
                AppTheme.card,
                in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                    .stroke(isSelected ? AppTheme.accent : AppTheme.border, lineWidth: isSelected ? 1.5 : 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    NavigationStack {
        LabelEditView(mode: .add)
    }
    .modelContainer(try! ModelContainerFactory.makeInMemoryContainer())
}
