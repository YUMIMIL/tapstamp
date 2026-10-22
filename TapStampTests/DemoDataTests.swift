import Foundation
import SwiftData
import Testing
@testable import TapStamp

@Suite("DemoData")
@MainActor
struct DemoDataTests {
    @Test("サンプルデータが 4 ラベルと各ラベルの記録を作り、未来の記録を含まない")
    func seed() throws {
        let container = try ModelContainerFactory.makeInMemoryContainer()
        let now = Date.now
        DemoData.seed(into: container.mainContext, now: now)

        let labels = try LabelStore(context: container.mainContext).allLabels()
        #expect(labels.map(\.name) == [DemoData.medicineName, DemoData.toiletName, DemoData.coffeeName, DemoData.sheetsName])

        let store = RecordStore(context: container.mainContext)
        for label in labels {
            #expect(try !store.records(for: label).isEmpty)
        }
        #expect(try store.records(for: nil).count >= 3)

        let all = try container.mainContext.fetch(FetchDescriptor<TapRecord>())
        #expect(all.allSatisfy { $0.timestamp < now })
    }
}
