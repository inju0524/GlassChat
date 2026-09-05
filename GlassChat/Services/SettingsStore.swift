import SwiftUI
import Observation

/// 用户偏好。非敏感小数据，存 UserDefaults（@AppStorage 语义）。
/// API Key 不在这里 —— 见 KeychainService。
@Observable
final class SettingsStore {
    @ObservationIgnored private let defaults: UserDefaults

    var providerID: String {
        get { defaults.string(forKey: "providerID") ?? "deepseek" }
        set { defaults.set(newValue, forKey: "providerID") }
    }
    var endpoint: String {
        get { defaults.string(forKey: "endpoint") ?? ProviderPreset.find(providerID).endpoint }
        set { defaults.set(newValue, forKey: "endpoint") }
    }
    var model: String {
        get { defaults.string(forKey: "model") ?? ProviderPreset.find(providerID).defaultModel }
        set { defaults.set(newValue, forKey: "model") }
    }
    /// 主题原始值："system" / "light" / "dark"
    var appearanceRaw: String {
        get { defaults.string(forKey: "appearance") ?? "system" }
        set { defaults.set(newValue, forKey: "appearance") }
    }
    /// nil = 跟随系统（由 appearanceRaw 映射）
    var preferredColorScheme: ColorScheme? {
        switch appearanceRaw {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
    /// Liquid Glass 视觉开关（Phase 7 真机校准时消费）
    var liquidGlassEnabled: Bool {
        get { defaults.object(forKey: "liquidGlassEnabled") as? Bool ?? true }
        set { defaults.set(newValue, forKey: "liquidGlassEnabled") }
    }
    var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: "hasCompletedOnboarding") }
        set { defaults.set(newValue, forKey: "hasCompletedOnboarding") }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    /// 组装当前 Provider 配置（含 Keychain 里的 Key）
    func makeProviderConfig() -> ProviderConfig? {
        guard let key = KeychainService.loadKey(for: providerID), !key.isEmpty else { return nil }
        guard let url = URL(string: endpoint) else { return nil }
        return ProviderConfig(presetID: providerID, endpoint: url, apiKey: key, model: model)
    }
}
