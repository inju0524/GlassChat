import SwiftUI
import Observation

/// 用户偏好（外观/玻璃效果）。Provider 配置已迁移至 ProviderStore（单一数据源）。
/// 存储属性 + didSet 持久化：@Observable 能正确追踪，UI 修改立即广播。
@Observable
@MainActor
final class SettingsStore {
    @ObservationIgnored private let defaults: UserDefaults

    var appearanceRaw: String {
        didSet { defaults.set(appearanceRaw, forKey: "appearance") }
    }

    var liquidGlassEnabled: Bool {
        didSet { defaults.set(liquidGlassEnabled, forKey: "liquidGlassEnabled") }
    }

    var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: "hasCompletedOnboarding") }
        set { defaults.set(newValue, forKey: "hasCompletedOnboarding") }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        appearanceRaw = defaults.string(forKey: "appearance") ?? "system"
        liquidGlassEnabled = defaults.object(forKey: "liquidGlassEnabled") == nil
            ? true
            : defaults.bool(forKey: "liquidGlassEnabled")
    }

    var preferredColorScheme: ColorScheme? {
        switch appearanceRaw {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
}
