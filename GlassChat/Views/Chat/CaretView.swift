import SwiftUI

/// 流式输出中的闪烁光标（accent 竖线）。
struct CaretView: View {
    @State private var on = true

    var body: some View {
        RoundedRectangle(cornerRadius: 1.5)
            .fill(AppTheme.accent)
            .frame(width: 3, height: 16)
            .opacity(on ? 1 : 0.15)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    on = false
                }
            }
    }
}
