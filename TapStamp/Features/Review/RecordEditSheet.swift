import SwiftUI
import SwiftData

/// 記録の日時を修正するシート。
struct RecordEditSheet: View {
    let record: TapRecord

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var timestamp: Date
    @State private var errorMessage: String?

    init(record: TapRecord) {
        self.record = record
        _timestamp = State(initialValue: record.timestamp)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("日時") {
                    DatePicker(
                        "日時",
                        selection: $timestamp,
                        in: ...Date.now,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }

                Section {
                    LabeledContent("ラベル", value: record.label?.name ?? "とりあえず記録")
                    LabeledContent("ボタンを押した日時", value: RelativeTimeFormatter.full(record.createdAt))
                } footer: {
                    Text("修正しても、ボタンを押した日時はそのまま残ります。")
                }
            }
            .themedScreenBackground()
            .navigationTitle("記録を修正")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                        .disabled(timestamp == record.timestamp)
                }
            }
            .alert("保存できませんでした", isPresented: Binding(isPresent: $errorMessage)) {
                Button("OK") {}
            } message: {
                Text(errorMessage ?? "")
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func save() {
        do {
            try RecordStore(context: context).update(record, timestamp: timestamp)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
