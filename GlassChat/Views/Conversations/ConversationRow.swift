import SwiftUI

/// 列表单行：图标瓦片 + 标题 + 预览 + 时间/未读点。半透明材质（surfaceCard），非玻璃。
/// TODO(Phase 2)：按预览稿 ① 完整实现。
struct ConversationRow: View {
    let conversation: Conversation

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.text")
                .frame(width: 40, height: 40)
                .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 13))
            VStack(alignment: .leading, spacing: 3) {
                Text(conversation.title).font(.themeBody()).fontWeight(.semibold)
                Text("…").font(.themeSecondary()).foregroundStyle(AppTheme.textSecondary)
            }
            Spacer()
        }
        .padding(13)
        .background(AppTheme.cardBackground())
    }
}
