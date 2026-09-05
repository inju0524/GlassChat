import SwiftUI

/// 列表空状态/新建对话页：时间问候 + 中央玻璃面板 + 建议问题胶囊。
/// 视觉基准：预览稿 ④。
struct EmptyStateView: View {
    var onStart: (String) -> Void = { _ in }

    @State private var greeting: String = ""

    init(onStart: @escaping (String) -> Void = { _ in }) {
        self.onStart = onStart
    }

    private static let suggestions = [
        "帮我写一封请假邮件",
        "用通俗语言解释 async/await",
        "为京都之旅列一份清单",
    ]

    var body: some View {
        VStack(spacing: 18) {
            Text(greeting.isEmpty ? Self.greetingForNow() : greeting)
                .font(.themeLargeTitle())
                .foregroundStyle(AppTheme.textPrimary)
            Text("想让 AI 帮你做什么？")
                .font(.themeSecondary())
                .foregroundStyle(AppTheme.textSecondary)

            VStack(spacing: 18) {
                Image(systemName: "sparkles")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundStyle(AppTheme.accent)
                    .frame(width: 64, height: 64)
                    .glassEffect(in: Circle())
                Text("开始一段新的对话")
                    .font(.themeTitle())
                    .foregroundStyle(AppTheme.textPrimary)
                Text("记录保存在本机，随时可以继续上次的话题")
                    .font(.themeSecondary())
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                VStack(spacing: 10) {
                    ForEach(Self.suggestions, id: \.self) { suggestion in
                        SuggestionChip(text: suggestion) {
                            onStart(suggestion)
                        }
                    }
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 30)
            .glassEffect(in: RoundedRectangle(cornerRadius: 26))
        }
        .padding(.horizontal, 24)
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
