import Foundation
import Observation

/// 设置页状态机：API 配置、连接测试。Phase 4 实现。
@Observable
@MainActor
final class SettingsViewModel {
    private(set) var isTestingConnection: Bool = false
    private(set) var connectionResult: String?

    // TODO(Phase 4)：saveAPIKey(_ key: String, providerID: String) → KeychainService
    // TODO(Phase 4)：testConnection() 发一次最小对话请求，展示成功/失败
    // TODO(Phase 8)：401 时引导用户到 API 配置页
}
