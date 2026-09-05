import SwiftUI

/// 底部玻璃输入栏：胶囊容器 + 多行输入 + 发送键。
/// 发送键在生成中切换为停止键（GlassEffectContainer + glassEffectID morph，Phase 7）。
struct GlassInputBar: View {
    @Binding var text: String
    var isGenerating: Bool
    var onSend: () -> Void
    var onStop: () -> Void

    private var trimmed: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        HStack(spacing: 10) {
            TextField("给 AI 发送消息", text: $text, axis: .vertical)
                .font(.themeBody())
                .foregroundStyle(AppTheme.textPrimary)
                .tint(AppTheme.accent)
                .lineLimit(1...5)
            if isGenerating {
                Button(action: onStop) {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(Color(white: 0.2), in: Circle())
                }
            } else {
                Button(action: onSend) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(AppTheme.sendGradient, in: Circle())
                        .opacity(trimmed.isEmpty ? 0.4 : 1)
                }
                .disabled(trimmed.isEmpty)
            }
        }
        .padding(.leading, 18)
        .padding(.trailing, 8)
        .padding(.vertical, 8)
        .glassEffect()
    }
}
