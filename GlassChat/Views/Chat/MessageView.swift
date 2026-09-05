import SwiftUI

/// 消息渲染：用户 = 玻璃胶囊气泡右对齐；AI = 无气泡直排 + Markdown。
/// TODO(Phase 3)：完整实现（含长按菜单：复制/重新生成）。
struct MessageView: View {
    let message: Message

    var body: some View {
        Group {
            if message.role == .user {
                HStack { Spacer()
                    Text(message.content)
                        .font(.themeBody())
                        .padding(.horizontal, 15).padding(.vertical, 11)
                        .background(.blue.opacity(0.25), in: RoundedRectangle(cornerRadius: 20))
                }
            } else {
                MarkdownView(content: message.content)
            }
        }
    }
}
