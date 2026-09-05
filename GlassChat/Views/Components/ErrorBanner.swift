import SwiftUI

/// 错误横幅/错误卡：图标 + 状态 + 用户动作（重试）。TODO(Phase 8)。
struct ErrorBanner: View {
    let error: ChatError
    var onRetry: (() -> Void)?

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle").foregroundStyle(AppTheme.dangerText)
            Text(error.errorDescription ?? "发生错误").font(.themeSecondary())
            if error.isRetryable, let onRetry {
                Spacer()
                Button("重试", action: onRetry).font(.themeSecondary().weight(.semibold)).tint(AppTheme.accent)
            }
        }
        .padding(12)
        .background(AppTheme.danger.opacity(0.10), in: RoundedRectangle(cornerRadius: 16))
    }
}
