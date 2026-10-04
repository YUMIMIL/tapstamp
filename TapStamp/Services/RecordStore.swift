import Foundation
import SwiftData

/// 記録の追加・取り消し・修正。View からも、将来の App Intents / Widget からも、ここを通す。
@MainActor
struct RecordStore {
    let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - 追加

    @discardableResult
    func record(label: TapLabel?, at timestamp: Date = .now) throws -> TapRecord {
        let record = TapRecord(timestamp: timestamp, label: label)
        context.insert(record)
        try context.save()
        return record
    }

    /// ラベル ID で記録する（App Intents などラベルの実体を持たない呼び出し元向け）。
    @discardableResult
    func record(labelID: UUID?, at timestamp: Date = .now) throws -> TapRecord {
        var label: TapLabel? = nil
        if let labelID {
            label = try fetchLabel(id: labelID)
        }
        return try record(label: label, at: timestamp)
    }

    // MARK: - 変更・削除

    func delete(_ record: TapRecord) throws {
        context.delete(record)
        try context.save()
    }

    func update(_ record: TapRecord, timestamp: Date) throws {
        record.timestamp = timestamp
        try context.save()
    }

    // MARK: - 取得

    /// 指定ラベル（nil なら「とりあえず記録」）の記録を新しい順に返す。
    func records(for label: TapLabel?) throws -> [TapRecord] {
        if let label {
            return label.records.sorted { $0.timestamp > $1.timestamp }
        }
        let descriptor = FetchDescriptor<TapRecord>(
            predicate: #Predicate<TapRecord> { $0.label == nil },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    func timestamps(for label: TapLabel?) throws -> [Date] {
        try records(for: label).map(\.timestamp)
    }

    /// 直近の 1 件。
    func latestRecord(for label: TapLabel?) throws -> TapRecord? {
        try records(for: label).first
    }

    func fetchLabel(id: UUID) throws -> TapLabel? {
        var descriptor = FetchDescriptor<TapLabel>(
            predicate: #Predicate<TapLabel> { $0.id == id }
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }
}
