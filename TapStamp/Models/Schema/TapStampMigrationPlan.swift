import Foundation
import SwiftData

enum TapStampMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [TapStampSchemaV1.self]
    }

    static var stages: [MigrationStage] {
        // V2 を追加したら、ここに
        //   MigrationStage.lightweight(fromVersion: TapStampSchemaV1.self, toVersion: TapStampSchemaV2.self)
        // を足す（Optional の項目追加だけなら lightweight で済む）。
        []
    }
}
