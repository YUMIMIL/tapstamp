import SwiftUI
import SwiftData

/// アプリ全体のタブ。初回起動時はテンプレート選択を全画面で出す。
struct RootTabView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var isOnboardingPresented = false

    var body: some View {
        TabView {
            RecordView()
                .tabItem {
                    Label("記録", systemImage: "list.bullet")
                }

            ReviewView()
                .tabItem {
                    Label("ふりかえり", systemImage: "chart.bar.fill")
                }
        }
        .tint(AppTheme.accent)
        .onAppear {
            if !hasCompletedOnboarding {
                isOnboardingPresented = true
            }
        }
        .fullScreenCover(isPresented: $isOnboardingPresented) {
            TemplatePickerView(isOnboarding: true) {
                hasCompletedOnboarding = true
                isOnboardingPresented = false
            }
        }
    }
}

#Preview {
    RootTabView()
        .modelContainer(try! ModelContainerFactory.makeInMemoryContainer())
}
