import SwiftUI
import UIKit

/// 代码块：深色实色卡 + 语言标签 + 复制按钮。TODO(Phase 3)：实现。
struct CodeBlockView: View {
    let code: String
    var language: String = "SwiftUI"

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(language).font(.themeCaption()).foregroundStyle(AppTheme.textSecondary)
                Spacer()
                Button { UIPasteboard.general.string = code } label: {
                    Label("复制", systemImage: "doc.on.doc")
                        .font(.themeCaption())
                }
                .foregroundStyle(Color(red: 0.624, green: 0.706, blue: 0.847))
            }
            .padding(.horizontal, 12).padding(.vertical, 7)
            Text(code)
                .font(.themeCode())
                .foregroundStyle(Color(red: 0.894, green: 0.910, blue: 0.957))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
        }
        .background(Color(red: 0.071, green: 0.078, blue: 0.114), in: RoundedRectangle(cornerRadius: 14))
    }
}
