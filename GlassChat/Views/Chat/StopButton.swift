import SwiftUI

/// 「停止生成」玻璃胶囊（生成中出现在输入栏上方右侧）。TODO(Phase 5)。
struct StopButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Label("停止生成", systemImage: "stop.fill")
                .font(.system(size: 12.5, weight: .semibold))
        }
        .tint(.red)
        .glassEffect()
    }
}
