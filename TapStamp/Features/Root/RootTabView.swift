import SwiftUI
import SwiftData

enum AppTab: Hashable {
    case record
    case review
}

/// アプリ全体のタブ。初回起動時はテンプレート選択を全画面で出す。
struct RootTabView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Query(sort: \TapLabel.sortOrder) private var labels: [TapLabel]
    @State private var isOnboardingPresented = false
    @State private var selectedTab: AppTab = DemoMode.scene?.initialTab ?? .record

    var body: some View {
        if let name = DemoMode.scene?.editLabelName,
           let label = labels.first(where: { $0.name == name }) {
            // スクリーンショット用：ラベル編集画面を直接表示
            NavigationStack {
                LabelEditView(mode: .edit(label))
            }
            .tint(AppTheme.accent)
        } else {
            tabs
        }
    }

    private var tabs: some View {
        TabView(selection: $selectedTab) {
            RecordView()
                .tabItem {
                    Label("記録", systemImage: "list.bullet")
                }
                .tag(AppTab.record)

            ReviewView()
                .tabItem {
                    Label("ふりかえり", systemImage: "chart.bar.fill")
                }
                .tag(AppTab.review)
        }
        .tint(AppTheme.accent)
        .task {
            let shouldPresent = DemoMode.scene.map { $0 == .onboarding } ?? !hasCompletedOnboarding
            guard shouldPresent else { return }
            // 起動直後に全画面表示を出すと中身が描画されないことがあるため、
            // 最初の画面が表示されてから少し待って出す。
            try? await Task.sleep(for: .milliseconds(500))
            isOnboardingPresented = true
        }
        .fullScreenCover(isPresented: $isOnboardingPresented) {
            TemplatePickerView(isOnboarding: true) {
                if DemoMode.scene == nil {
                    hasCompletedOnboarding = true
                }
                isOnboardingPresented = false
            }
        }
    }
}

#Preview {
    RootTabView()
        .modelContainer(try! ModelContainerFactory.makeInMemoryContainer())
}
