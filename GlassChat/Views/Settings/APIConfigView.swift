import SwiftUI

/// API 配置：提供商选择 / Endpoint / API Key（Keychain）/ 连接测试（Phase 4 接入）。
struct APIConfigView: View {
    @Environment(SettingsStore.self) private var store

    @State private var apiKeyInput = ""
    @State private var savedHint = false
    @State private var isTesting = false
    @State private var testResult: String?
    @State private var testOK = false

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
                Button {
                    runConnectionTest()
                } label: {
                    if isTesting {
                        HStack(spacing: 8) {
                            ProgressView()
                            Text("测试中…")
                        }
                    } else {
                        Text("运行一次对话验证")
                    }
                }
                .disabled(isTesting)
                if let testResult {
                    Text(testOK ? "✓ 连接成功" : testResult)
                        .font(.themeSecondary())
                        .foregroundStyle(testOK ? AppTheme.success : AppTheme.dangerText)
                }
            }
        }
        .navigationTitle("API 配置")
    }

    /// 连接测试：用当前配置发一条最小对话请求，收到首个增量即判定成功。
    private func runConnectionTest() {
        guard let url = URL(string: store.endpoint), url.scheme != nil else {
            testOK = false
            testResult = "Endpoint 无效"
            return
        }
        guard let key = KeychainService.loadKey(for: store.providerID), !key.isEmpty else {
            testOK = false
            testResult = "请先在上方保存 API Key"
            return
        }
        let config = ProviderConfig(presetID: store.providerID, endpoint: url, apiKey: key, model: store.model)
        let request = ChatRequest(
            model: config.model,
            messages: [.init(role: .user, content: "ping")]
        )
        isTesting = true
        testResult = nil
        Task {
            defer { isTesting = false }
            do {
                let provider = AIProviderFactory.make(config: config)
                for try await event in provider.stream(request) {
                    if case .delta = event {
                        testOK = true
                        testResult = nil
                        return
                    }
                }
                testOK = false
                testResult = "连接成功但未收到内容"
            } catch {
                testOK = false
                testResult = ChatErrorMapper.map(error).errorDescription
            }
        }
    }
}
