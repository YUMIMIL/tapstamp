import Foundation
import SwiftData
import Testing
@testable import TapStamp

@Suite("RecordStore / LabelStore")
@MainActor
struct StoreTests {
    @Test("記録して取り消せる")
    func recordAndUndo() throws {
        let container = try ModelContainerFactory.makeInMemoryContainer()
        let store = RecordStore(context: container.mainContext)

        let record = try store.record(label: nil)
        #expect(try store.records(for: nil).count == 1)

        try store.delete(record)
        #expect(try store.records(for: nil).isEmpty)
    }

    @Test("ラベル付きの記録はそのラベルからだけ見える")
    func recordsPerLabel() throws {
        let container = try ModelContainerFactory.makeInMemoryContainer()
        let labels = LabelStore(context: container.mainContext)
        let records = RecordStore(context: container.mainContext)

        let medicine = try labels.add(name: "薬", color: .blue, displayMode: .frequency)
        try records.record(label: medicine)
        try records.record(label: medicine)
        try records.record(label: nil)

        #expect(try records.records(for: medicine).count == 2)
        #expect(try records.records(for: nil).count == 1)
        #expect(try records.records(for: medicine).first?.label?.id == medicine.id)
    }

    @Test("ラベル ID でも記録できる")
    func recordByLabelID() throws {
        let container = try ModelContainerFactory.makeInMemoryContainer()
        let labels = LabelStore(context: container.mainContext)
        let records = RecordStore(context: container.mainContext)

        let toilet = try labels.add(name: "トイレ", color: .teal, displayMode: .frequency)
        let record = try records.record(labelID: toilet.id)
        #expect(record.label?.id == toilet.id)
    }

    @Test("ラベルを削除しても記録を残せる")
    func deleteLabelKeepingRecords() throws {
        let container = try ModelContainerFactory.makeInMemoryContainer()
        let labels = LabelStore(context: container.mainContext)
        let records = RecordStore(context: container.mainContext)

        let label = try labels.add(name: "一時", color: .coral, displayMode: .frequency)
        try records.record(label: label)
        try labels.delete(label, deletingRecords: false)

        #expect(try labels.allLabels().isEmpty)
        #expect(try records.records(for: nil).count == 1)
    }

    @Test("ラベルを記録ごと削除できる")
    func deleteLabelWithRecords() throws {
        let container = try ModelContainerFactory.makeInMemoryContainer()
        let labels = LabelStore(context: container.mainContext)
        let records = RecordStore(context: container.mainContext)

        let label = try labels.add(name: "一時", color: .coral, displayMode: .frequency)
        try records.record(label: label)
        try labels.delete(label, deletingRecords: true)

        #expect(try labels.allLabels().isEmpty)
        #expect(try records.records(for: nil).isEmpty)
    }

    @Test("並べ替えで sortOrder が振り直される")
    func reorder() throws {
        let container = try ModelContainerFactory.makeInMemoryContainer()
        let labels = LabelStore(context: container.mainContext)

        try labels.add(name: "A", color: .coral, displayMode: .frequency)
        try labels.add(name: "B", color: .coral, displayMode: .frequency)
        try labels.add(name: "C", color: .coral, displayMode: .frequency)

        try labels.move(fromOffsets: IndexSet(integer: 2), toOffset: 0)

        let names = try labels.allLabels().map(\.name)
        #expect(names == ["C", "A", "B"])
        #expect(try labels.allLabels().map(\.sortOrder) == [0, 1, 2])
    }

    @Test("テンプレートをまとめて追加できる")
    func addTemplates() throws {
        let container = try ModelContainerFactory.makeInMemoryContainer()
        let labels = LabelStore(context: container.mainContext)

        try labels.add(templates: Array(TemplateCatalog.all.prefix(3)))
        let all = try labels.allLabels()
        #expect(all.count == 3)
        #expect(all.map(\.sortOrder) == [0, 1, 2])
        #expect(all.map(\.name) == TemplateCatalog.all.prefix(3).map(\.name))
    }
}
