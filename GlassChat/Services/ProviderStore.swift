import Foundation
import Observation
import SwiftUI

/// API Provider 的单一数据源。所有页面都从这里读取，任何修改立即广播并持久化。
/// 档案存 UserDefaults（JSON）；API Key 按 provider.id 存 Keychain，绝不入 UserDefaults。
@Observable
@MainActor
final class ProviderStore {
    private static let storageKey = "providerStore.v1"

    @ObservationIgnored private let defaults: UserDefaults

    private(set) var providers: [APIProvider] = []
    private(set) var activeProviderID: String = ""

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
        migrateLegacyIfNeeded()
    }

    // MARK: - 查询

    var activeProvider: APIProvider? {
        providers.first { $0.id == activeProviderID }
    }

    var activeAPIKey: String? {
        guard let active = activeProvider else { return nil }
        let key = KeychainService.loadKey(for: active.id)
        return (key?.isEmpty == false) ? key : nil
    }

    func provider(withID id: String) -> APIProvider? {
        providers.first { $0.id == id }
    }

    func apiKey(for id: String) -> String? {
        KeychainService.loadKey(for: id)
    }

    func keyMasked(for id: String) -> String {
        KeychainService.maskedKey(KeychainService.loadKey(for: id))
    }

    // MARK: - 修改（全部立即持久化）

    func add(_ provider: APIProvider) {
        providers.append(provider)
        persist()
    }

    func update(_ provider: APIProvider) {
        guard let index = providers.firstIndex(where: { $0.id == provider.id }) else { return }
        providers[index] = provider
        persist()
    }

    func remove(id: String) {
        providers.removeAll { $0.id == id }
        KeychainService.deleteKey(for: id)
        if activeProviderID == id {
            activeProviderID = providers.first?.id ?? ""
        }
        persist()
    }

    func setActive(id: String) {
        activeProviderID = id
        persist()
    }

    func updateName(id: String, name: String) {
        mutate(id: id) { $0.name = name }
    }

    func updateBaseURL(id: String, baseURL: String) {
        mutate(id: id) { $0.baseURL = APIProvider.normalizedBaseURL(baseURL) }
    }

    func setDefaultModel(id: String, model: String) {
        mutate(id: id) {
            $0.defaultModel = model
            if !$0.models.contains(model) { $0.models.append(model) }
        }
    }

    func setModels(id: String, models: [String]) {
        mutate(id: id) {
            $0.models = models
            if !$0.models.contains($0.defaultModel) { $0.defaultModel = models.first ?? "" }
        }
    }

    func clearModels(id: String) {
        mutate(id: id) { $0.models = []; $0.defaultModel = "" }
    }

    func setKey(_ key: String, for id: String) {
        KeychainService.saveKey(key, for: id)
    }

    // MARK: - 私有

    /// 通用字段修改入口（供编辑页 Binding 使用）
    func update(id: String, _ change: (inout APIProvider) -> Void) {
        mutate(id: id, change)
    }

    private func mutate(id: String, _ change: (inout APIProvider) -> Void) {
        guard let index = providers.firstIndex(where: { $0.id == id }) else { return }
        change(&providers[index])
        persist()
    }

    private func persist() {
        let dto = ProviderStoreDTO(providers: providers, activeProviderID: activeProviderID)
        if let data = try? JSONEncoder().encode(dto) {
            defaults.set(data, forKey: Self.storageKey)
        }
    }

    private func load() {
        guard let data = defaults.data(forKey: Self.storageKey),
              let dto = try? JSONDecoder().decode(ProviderStoreDTO.self, from: data) else { return }
        providers = dto.providers
        activeProviderID = dto.activeProviderID
    }

    /// 旧版（全局 providerID/endpoint/model 三键）一次性迁移为多 Provider 档案
    private func migrateLegacyIfNeeded() {
        guard providers.isEmpty,
              let endpoint = defaults.string(forKey: "endpoint"), !endpoint.isEmpty else { return }
        let legacyID = defaults.string(forKey: "providerID") ?? "deepseek"
        let preset = ProviderPreset.find(legacyID)
        let model = defaults.string(forKey: "model") ?? preset.defaultModel
        let provider = APIProvider(
            name: preset.displayName,
            protocolKind: .openAICompatible,
            baseURL: endpoint,
            models: ([model] + preset.suggestedModels).deduplicated(),
            defaultModel: model
        )
        providers = [provider]
        activeProviderID = provider.id
        if let key = KeychainService.loadKey(for: legacyID), !key.isEmpty {
            KeychainService.saveKey(key, for: provider.id)
        }
        defaults.removeObject(forKey: "providerID")
        defaults.removeObject(forKey: "endpoint")
        defaults.removeObject(forKey: "model")
        persist()
    }
}

/// 持久化 DTO
private struct ProviderStoreDTO: Codable {
    var providers: [APIProvider]
    var activeProviderID: String
}

extension Array where Element == String {
    func deduplicated() -> [String] {
        var seen = Set<String>()
        return filter { seen.insert($0).inserted }
    }
}
