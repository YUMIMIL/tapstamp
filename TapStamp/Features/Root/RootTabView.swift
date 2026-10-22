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
        .onAppear {
            if let scene = DemoMode.scene {
                isOnboardingPresented = scene == .onboarding
            } else if !hasCompletedOnboarding {
                isOnboardingPresented = true
            }
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
