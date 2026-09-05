import SwiftUI

/// 底部玻璃输入栏：胶囊容器 + 多行输入 + 发送键。
/// 发送键在生成中 morph 为停止键（GlassEffectContainer + glassEffectID，Phase 7）。
/// TODO(Phase 2)：完整实现。
struct GlassInputBar: View {
    @Binding var text: String
    var isGenerating: Bool
    var onSend: () -> Void
    var onStop: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            TextField("给 AI 发送消息", text: $text, axis: .vertical)
                .font(.themeBody())
                .lineLimit(1...5)
            Button(action: isGenerating ? onStop : onSend) {
                Image(systemName: isGenerating ? "stop.fill" : "arrow.up")
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(width: 40, height: 40)
            .background(AppTheme.sendGradient, in: Circle())
            .disabled(!isGenerating && text.isEmpty)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 8)
    }
}
