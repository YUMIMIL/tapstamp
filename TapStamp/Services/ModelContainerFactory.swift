import Foundation
import SwiftData

/// ModelContainer の生成と保存先の決定を一箇所に集める。
/// フェーズ2 で Widget と共有するために App Group へ移すときは、`storeURL()` を差し替え、
/// 旧ストアからのコピー処理をここに足す。
enum ModelContainerFactory {
    static let storeFileName = "TapStamp.store"

    static func storeURL() throws -> URL {
        let directory = URL.applicationSupportDirectory
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appending(path: storeFileName)
    }

    static func makeContainer() throws -> ModelContainer {
        let schema = Schema(versionedSchema: TapStampSchemaV1.self)
        let configuration = ModelConfiguration("TapStamp", schema: schema, url: try storeURL())
        return try ModelContainer(
            for: schema,
            migrationPlan: TapStampMigrationPlan.self,
            configurations: [configuration]
        )
    }

    /// テストやプレビュー用。
    static func makeInMemoryContainer() throws -> ModelContainer {
        let schema = Schema(versionedSchema: TapStampSchemaV1.self)
        let configuration = ModelConfiguration("TapStamp", schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: schema,
            migrationPlan: TapStampMigrationPlan.self,
            configurations: [configuration]
        )
    }
}
