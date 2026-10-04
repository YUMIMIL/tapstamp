import Foundation
import SwiftData

/// ラベルの追加・変更・並べ替え・削除。
@MainActor
struct LabelStore {
    let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    /// `sortOrder` 順。
    func allLabels() throws -> [TapLabel] {
        let descriptor = FetchDescriptor<TapLabel>(
            sortBy: [SortDescriptor(\.sortOrder), SortDescriptor(\.createdAt)]
        )
        return try context.fetch(descriptor)
    }

    @discardableResult
    func add(name: String, color: LabelColor, displayMode: DisplayMode) throws -> TapLabel {
        let label = TapLabel(
            name: Self.normalized(name),
            colorHex: color.hex,
            sortOrder: try nextSortOrder(),
            displayMode: displayMode
        )
        context.insert(label)
        try context.save()
        return label
    }

    func add(templates: [LabelTemplate]) throws {
        var order = try nextSortOrder()
        for template in templates {
            let label = TapLabel(
                name: template.name,
                colorHex: template.color.hex,
                sortOrder: order,
                displayMode: template.displayMode
            )
            context.insert(label)
            order += 1
        }
        try context.save()
    }

    func update(_ label: TapLabel, name: String, color: LabelColor, displayMode: DisplayMode) throws {
        label.name = Self.normalized(name)
        label.colorHex = color.hex
        label.displayMode = displayMode
        try context.save()
    }

    func move(fromOffsets source: IndexSet, toOffset destination: Int) throws {
        var labels = try allLabels()
        labels.move(fromOffsets: source, toOffset: destination)
        renumber(labels)
        try context.save()
    }

    /// - Parameter deletingRecords: true なら紐づく記録も削除。false なら記録は「とりあえず記録」に残る。
    func delete(_ label: TapLabel, deletingRecords: Bool) throws {
        if deletingRecords {
            for record in label.records {
                context.delete(record)
            }
        }
        let deletedID = label.persistentModelID
        context.delete(label)
        let remaining = try allLabels().filter { $0.persistentModelID != deletedID }
        renumber(remaining)
        try context.save()
    }

    // MARK: - Private

    private func nextSortOrder() throws -> Int {
        (try allLabels().last?.sortOrder ?? -1) + 1
    }

    private func renumber(_ labels: [TapLabel]) {
        for (index, label) in labels.enumerated() where label.sortOrder != index {
            label.sortOrder = index
        }
    }

    static func normalized(_ name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
