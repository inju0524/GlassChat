import SwiftUI

/// 空状态/新建对话页：时间问候 + 中央玻璃面板 + 建议问题胶囊 + 输入栏。
/// 视觉基准：预览稿 ④。TODO(Phase 2)：完整实现。
struct EmptyStateView: View {
    @State private var greeting: String = ""

    var body: some View {
        VStack(spacing: 18) {
            Text(greeting.isEmpty ? "你好" : greeting)
                .font(.themeLargeTitle())
            Text("想聊点什么？")
                .font(.themeSecondary())
                .foregroundStyle(AppTheme.textSecondary)
            // TODO(Phase 2)：玻璃面板 + 建议胶囊（点击填入输入框）
        }
        .onAppear { greeting = Self.greetingForNow() }
    }

    static func greetingForNow() -> String {
        switch Calendar.current.component(.hour, from: Date()) {
        case 5..<11: return "早上好"
        case 11..<13: return "中午好"
        case 13..<18: return "下午好"
        default: return "晚上好"
        }
    }
}
