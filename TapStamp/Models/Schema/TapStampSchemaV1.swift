import Foundation
import SwiftData

/// スキーマ バージョン 1。
/// 項目を足すときはこの enum を直接書き換えず、`TapStampSchemaV2` を追加して
/// `TapStampMigrationPlan` に移行ステージを登録する。
enum TapStampSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(1, 0, 0) }

    static var models: [any PersistentModel.Type] {
        [TapLabel.self, TapRecord.self]
    }

    /// 記録の分類（例: 薬、トイレ、シーツ交換）。
    @Model
    final class TapLabel {
        @Attribute(.unique) var id: UUID
        var name: String
        /// 例 "#3E63DD"
        var colorHex: String
        /// 0 始まり。並べ替えのたびに振り直す。
        var sortOrder: Int
        /// `DisplayMode.rawValue`。enum を直接保存しないのは、将来の値の追加・改名に備えるため。
        var displayModeRaw: String
        var createdAt: Date

        @Relationship(deleteRule: .nullify, inverse: \TapRecord.label)
        var records: [TapRecord] = []

        init(
            id: UUID = UUID(),
            name: String,
            colorHex: String,
            sortOrder: Int,
            displayMode: DisplayMode,
            createdAt: Date = .now
        ) {
            self.id = id
            self.name = name
            self.colorHex = colorHex
            self.sortOrder = sortOrder
            self.displayModeRaw = displayMode.rawValue
            self.createdAt = createdAt
        }
    }

    /// 1 回分の記録。
    @Model
    final class TapRecord {
        @Attribute(.unique) var id: UUID
        /// 記録として扱う日時。あとから修正できる。
        var timestamp: Date
        /// 実際にボタンを押した日時。修正しても変わらない。
        var createdAt: Date
        /// nil は「とりあえず記録」（ラベルなし）。
        var label: TapLabel?

        // フェーズ2 以降で追加予定（V2 で足す）:
        //   var note: String?
        //   var intensity: Int?      // 1〜5
        //   var sourceRaw: String?   // app / widget / controlCenter / actionButton

        init(
            id: UUID = UUID(),
            timestamp: Date = .now,
            label: TapLabel? = nil,
            createdAt: Date = .now
        ) {
            self.id = id
            self.timestamp = timestamp
            self.label = label
            self.createdAt = createdAt
        }
    }
}
