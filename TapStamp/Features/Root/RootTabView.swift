import SwiftUI
import SwiftData

/// アプリ全体のタブ。Step 2 以降で各画面を差し込む。
struct RootTabView: View {
    var body: some View {
        TabView {
            Text("記録")
                .tabItem {
                    Label("記録", systemImage: "hand.tap")
                }

            Text("ふりかえり")
                .tabItem {
                    Label("ふりかえり", systemImage: "chart.bar")
                }
        }
    }
}

#Preview {
    RootTabView()
        .modelContainer(try! ModelContainerFactory.makeInMemoryContainer())
}
