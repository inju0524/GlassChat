import SwiftUI

/// API 配置：提供商选择 / Endpoint / API Key（Keychain）/ 连接测试（Phase 4 接入）。
struct APIConfigView: View {
    @Environment(SettingsStore.self) private var store

    @State private var apiKeyInput = ""
    @State private var savedHint = false

    private var hasConfiguredKey: Bool {
        guard let key = KeychainService.loadKey(for: store.providerID) else { return false }
        return !key.isEmpty
    }

    var body: some View {
        @Bindable var store = store
        Form {
            Section("API 服务") {
                Picker("提供商", selection: $store.providerID) {
                    ForEach(ProviderPreset.all) { preset in
                        Text(preset.displayName).tag(preset.id)
                    }
                }
                TextField("API Endpoint", text: $store.endpoint)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .onChange(of: store.providerID) { _, newValue in
                        let preset = ProviderPreset.find(newValue)
                        store.endpoint = preset.endpoint
                        store.model = preset.defaultModel
                    }
            }

            Section {
                SecureField("粘贴 API Key（sk-...）", text: $apiKeyInput)
                Button("保存到钥匙串") {
                    let key = apiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !key.isEmpty else { return }
                    KeychainService.saveKey(key, for: store.providerID)
                    apiKeyInput = ""
                    savedHint = true
                }
                if savedHint || hasConfiguredKey {
                    Text("当前：\(KeychainService.maskedKey(KeychainService.loadKey(for: store.providerID)))")
                        .font(.themeSecondary())
                        .foregroundStyle(AppTheme.textSecondary)
                }
            } header: {
                Text("API Key")
            } footer: {
                Text("仅存于本机钥匙串，永不明文上传")
            }

            Section("连接测试") {
                Button("运行一次对话验证") { }
                    .disabled(true)
                Text("Phase 4 接入真实 API 后可用")
                    .font(.themeSecondary())
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .navigationTitle("API 配置")
    }
}
