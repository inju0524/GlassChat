import SwiftUI

/// 底部玻璃输入栏：胶囊容器 + 多行输入 + 发送键。
/// 发送↔停止使用 GlassEffectContainer 玻璃 morph 动效（iOS 26）。
struct GlassInputBar: View {
    @Binding var text: String
    var isGenerating: Bool
    var onSend: () -> Void
    var onStop: () -> Void

    @Namespace private var actionNamespace

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
            GlassEffectContainer(spacing: 20) {
                if isGenerating {
                    stopButton
                } else {
                    sendButton
                }
            }
        }
        .padding(.leading, 18)
        .padding(.trailing, 8)
        .padding(.vertical, 8)
        .glassEffect()
    }

    private var stopButton: some View {
        Button(action: onStop) {
            Image(systemName: "stop.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
        }
        .glassEffect(.regular.tint(.red.opacity(0.55)), in: Circle())
        .glassEffectID("input-action", in: actionNamespace)
    }

    private var sendButton: some View {
        Button(action: onSend) {
            Image(systemName: "arrow.up")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
        }
        .glassEffect(.regular.tint(.blue.opacity(0.55)), in: Circle())
        .glassEffectID("input-action", in: actionNamespace)
        .disabled(trimmed.isEmpty)
        .opacity(trimmed.isEmpty ? 0.4 : 1)
    }
}
