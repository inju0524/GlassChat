import SwiftUI
import UIKit

/// 消息渲染：用户 = tinted 玻璃气泡右对齐；AI = 无气泡直排 + Markdown + 光标；失败 = 错误卡。
struct MessageView: View {
    let message: Message
    var onRetry: (() -> Void)? = nil

    var body: some View {
        Group {
            switch message.role {
            case .user:
                HStack {
                    Spacer()
                    Text(message.content)
                        .font(.themeBody())
                        .foregroundStyle(AppTheme.textPrimary)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 11)
                        .glassEffect(.regular.tint(.blue.opacity(0.28)), in: RoundedRectangle(cornerRadius: 20))
                }
            case .assistant:
                VStack(alignment: .leading, spacing: 8) {
                    if message.status == .failed {
                        ErrorBanner(text: message.errorText ?? "生成失败", retryable: true, onRetry: onRetry)
                    } else {
                        HStack(alignment: .top, spacing: 2) {
                            MarkdownView(content: message.content)
                            if message.status == .streaming {
                                CaretView()
                            }
                        }
                    }
                }
            case .system:
                EmptyView()
            }
        }
        .contextMenu {
            Button {
                UIPasteboard.general.string = message.content
            } label: {
                Label("复制", systemImage: "doc.on.doc")
            }
        }
    }
}
