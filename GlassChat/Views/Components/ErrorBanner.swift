import SwiftUI

/// 错误横幅/错误卡：图标 + 用户可读文案 + 动作（重试）。
struct ErrorBanner: View {
    let text: String
    var retryable: Bool = false
    var onRetry: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle")
                .foregroundStyle(AppTheme.dangerText)
            Text(text)
                .font(.themeSecondary())
                .foregroundStyle(AppTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            if retryable, let onRetry {
                Spacer()
                Button("重试", action: onRetry)
                    .font(.themeSecondary().weight(.semibold))
                    .tint(AppTheme.accent)
            }
        }
        .padding(12)
        .background(AppTheme.danger.opacity(0.10), in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppTheme.danger.opacity(0.32), lineWidth: 1)
        )
    }
}
