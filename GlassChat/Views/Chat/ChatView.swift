import SwiftUI
import SwiftData

/// 对话页。视觉基准：design-previews/scheme-a-dark.html 屏幕②。
/// 玻璃导航栏（消息从其下滑过）+ 消息流 + 玻璃输入栏 + 停止胶囊 + 模型 Chip。
struct ChatView: View {
    @Bindable var conversation: Conversation

    var body: some View {
        ZStack {
            AppTheme.bg.ignoresSafeArea()
            // TODO(Phase 3)：消息流（ScrollView + MessageView）+ 空状态
            // TODO(Phase 5)：流式钉底滚动 / 停止生成胶囊 / 错误卡
            Text("对话页（Phase 3）").foregroundStyle(AppTheme.textSecondary)
        }
        .navigationTitle(conversation.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
