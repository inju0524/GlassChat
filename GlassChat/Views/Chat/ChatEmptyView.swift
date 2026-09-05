import SwiftUI

/// 对话页空状态：AI 引导 + 建议问题胶囊（点击填入输入框）。
struct ChatEmptyView: View {
    var onSuggestion: (String) -> Void

    private static let suggestions = [
        "帮我写一封请假邮件",
        "用通俗语言解释 async/await",
        "为京都之旅列一份清单",
        "把这段话翻译成英文",
    ]

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "sparkles")
                .font(.system(size: 26, weight: .medium))
                .foregroundStyle(AppTheme.accent)
                .frame(width: 64, height: 64)
                .glassEffect(in: Circle())
            Text("想让 AI 帮你做什么？")
                .font(.themeTitle())
                .foregroundStyle(AppTheme.textPrimary)
            VStack(spacing: 10) {
                ForEach(Self.suggestions, id: \.self) { suggestion in
                    SuggestionChip(text: suggestion) {
                        onSuggestion(suggestion)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
