import SwiftUI

/// 建议问题胶囊（空状态页，点击填入输入框）。TODO(Phase 2)。
struct SuggestionChip: View {
    let text: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text).font(.system(size: 12.8)).padding(.horizontal, 14).padding(.vertical, 9)
        }
        .foregroundStyle(Color(red: 0.804, green: 0.839, blue: 0.918))
        .glassEffect(in: .capsule)
    }
}
