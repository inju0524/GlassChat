import SwiftUI

/// 根骨架：对话 / 设置 两个 Tab。
/// iOS 26 的系统 Tab Bar 自带悬浮 Liquid Glass 外观，正是方案 A 需要的效果，不自定义。
struct RootTabView: View {
    var body: some View {
        TabView {
            ConversationListView()
                .tabItem { Label("对话", systemImage: "bubble.left.and.bubble.right") }

            SettingsView()
                .tabItem { Label("设置", systemImage: "gearshape") }
        }
        .tint(AppTheme.accent)
    }
}
