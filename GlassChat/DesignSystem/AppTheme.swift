import SwiftUI

/// 方案 A「曜黑 Glass」色板。来源：docs/DESIGN_SPEC_A.md §2/§7。
/// Phase 7 会把这里升级为随系统深浅色自适应的 Dynamic Color。
enum AppTheme {
    // 页面
    static let bg = Color(red: 0.04, green: 0.043, blue: 0.063)            // #0A0B10
    static let textPrimary = Color(red: 0.925, green: 0.933, blue: 0.957)  // #ECEEF4
    static let textSecondary = Color(red: 0.604, green: 0.627, blue: 0.690)
    static let textTertiary = Color(red: 0.384, green: 0.408, blue: 0.478)

    // 材质
    static let surfaceCard = Color.white.opacity(0.055)
    static let surfaceBorder = Color.white.opacity(0.08)
    static let surfaceHighlight = Color.white.opacity(0.13)

    // 语义色
    static let accent = Color(red: 0.431, green: 0.639, blue: 1.0)         // #6EA3FF
    static let success = Color(red: 0.498, green: 0.847, blue: 0.671)
    static let danger = Color(red: 0.898, green: 0.282, blue: 0.302)
    static let dangerText = Color(red: 1.0, green: 0.541, blue: 0.557)

    // 发送键渐变（唯一实心彩色元素）
    static let sendGradient = LinearGradient(
        colors: [Color(red: 0.310, green: 0.525, blue: 1.0),
                 Color(red: 0.231, green: 0.373, blue: 0.851)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    // 通用玻璃卡片修饰（列表卡片为半透明材质，非 glassEffect）
    static func cardBackground() -> some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(surfaceCard)
            .stroke(surfaceBorder, lineWidth: 1)
    }
}
