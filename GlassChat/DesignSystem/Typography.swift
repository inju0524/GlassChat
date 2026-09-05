import SwiftUI

/// 方案 A 字号体系。来源：docs/DESIGN_SPEC_A.md §3。
extension Font {
    static func themeLargeTitle() -> Font { .system(size: 33, weight: .bold) }
    static func themeTitle() -> Font { .system(size: 17, weight: .semibold) }
    static func themeBody() -> Font { .system(size: 15) }
    static func themeAI() -> Font { .system(size: 14.6) }
    static func themeSecondary() -> Font { .system(size: 12.8) }
    static func themeCaption() -> Font { .system(size: 11.5, weight: .medium) }
    static func themeCode() -> Font { .system(size: 12.3, design: .monospaced) }
}
