import SwiftUI
import SwiftData

@main
struct TapStampApp: App {
    private let container: ModelContainer

    init() {
        do {
            if DemoMode.scene != nil {
                // スクリーンショット撮影用。実データには触れず、メモリ上のサンプルデータを使う。
                container = try ModelContainerFactory.makeInMemoryContainer()
                DemoData.seed(into: container.mainContext)
            } else {
                container = try ModelContainerFactory.makeContainer()
            }
        } catch {
            // 端末内ストアが開けない状態ではアプリとして成立しないため、ここで止める。
            fatalError("ModelContainer の作成に失敗しました: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(container)
    }
}
