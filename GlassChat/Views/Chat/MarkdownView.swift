import SwiftUI

/// AI 回复的轻量 Markdown 渲染：段落/粗体/行内代码/列表/代码块。
/// 用系统 AttributedString(markdown:) 为主，代码块拆出 CodeBlockView。
/// TODO(Phase 3)：实现块级切分（不引入第三方库）。
struct MarkdownView: View {
    let content: String

    var body: some View {
        Text(attributed)
            .font(.themeAI())
            .lineSpacing(6)
            .foregroundStyle(Color(red: 0.867, green: 0.882, blue: 0.933))
    }

    private var attributed: AttributedString {
        (try? AttributedString(
            markdown: content,
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )) ?? AttributedString(content)
    }
}
