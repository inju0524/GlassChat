import SwiftUI

/// 根骨架：对话 / 设置 两个 Tab。方案 A 使用悬浮玻璃 Tab Bar（Phase 7 落地）。
struct RootTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                ConversationListView()
            }
            .tabItem { Label("对话", systemImage: "bubble.left.and.bubble.right") }

            NavigationStack {
                SettingsView()
            }
            .tabItem { Label("设置", systemImage: "gearshape") }
        }
        .tint(AppTheme.accent)
        .background(AppTheme.bg)
    }
}

#Preview {
    RootTabView().environment(SettingsStore())
}
