import SwiftUI

/// 编辑单个 Provider：名称 / 协议 / Base URL / API Key / 连接测试 / 模型管理 / 删除。
struct ProviderEditView: View {
    let providerID: String

    @Environment(ProviderStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    enum Field: Hashable { case name, baseURL, apiKey, modelInput }
    @FocusState private var focusedField: Field?

    enum FetchState: Equatable { case idle, loading, done, empty, failed(String) }
    enum TestState: Equatable { case idle, loading, success, failed(String) }

    @State private var apiKeyDraft = ""
    @State private var keySavedHint = false
    @State private var modelInput = ""
    @State private var fetchState: FetchState = .idle
    @State private var testState: TestState = .idle
    @State private var showClearConfirm = false
    @State private var showDeleteConfirm = false

    private var provider: APIProvider? { store.provider(withID: providerID) }

    var body: some View {
        Group {
            if let provider {
                form(provider)
            } else {
                ContentUnavailableView("该 Provider 已删除", systemImage: "trash")
                    .onAppear { dismiss() }
            }
        }
        .background(AppTheme.bg.ignoresSafeArea())
        .navigationTitle("编辑 Provider")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .simultaneousGesture(TapGesture().onEnded { focusedField = nil })
        .confirmationDialog("清空模型列表", isPresented: $showClearConfirm, titleVisibility: .visible) {
            Button("清空", role: .destructive) { store.clearModels(id: providerID) }
            Button("取消", role: .cancel) { }
        } message: {
            Text("将移除全部模型并清空默认模型设置。")
        }
        .confirmationDialog("删除 Provider", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("删除", role: .destructive) {
                store.remove(id: providerID)
                dismiss()
            }
            Button("取消", role: .cancel) { }
        } message: {
            Text("将删除「\(provider?.name ?? "")」及其保存的 API Key，此操作不可撤销。")
        }
    }

    @ViewBuilder
    private func form(_ provider: APIProvider) -> some View {
        Form {
            Section("基本信息") {
                TextField("名称", text: bind(\.name))
                    .font(.themeBody())
                    .focused($focusedField, equals: .name)
                    .submitLabel(.done)
                    .onSubmit { focusedField = nil }
                Picker("协议", selection: bind(\.protocolKind)) {
                    ForEach(APIProtocolKind.allCases.filter(\.isImplemented)) { kind in
                        Text(kind.displayName).tag(kind)
                    }
                }
                TextField("Base URL（如 https://api.xkiro.com/v1）", text: bind(\.baseURL))
                    .font(.themeBody())
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .baseURL)
                    .submitLabel(.done)
                    .onSubmit { focusedField = nil }
            }

            Section {
                SecureField("粘贴 API Key", text: $apiKeyDraft)
                    .font(.themeBody())
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .apiKey)
                    .submitLabel(.done)
                    .onSubmit { focusedField = nil }
                Button("保存到钥匙串") {
                    let key = apiKeyDraft.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !key.isEmpty else { return }
                    store.setKey(key, for: providerID)
                    apiKeyDraft = ""
                    keySavedHint = true
                }
                .disabled(apiKeyDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                if keySavedHint || store.apiKey(for: providerID) != nil {
                    Text("当前：\(store.keyMasked(for: providerID))")
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
                    testConnection(provider)
                } label: {
                    if testState == .loading {
                        HStack(spacing: 8) { ProgressView(); Text("测试中…") }
                    } else {
                        Text("运行一次对话验证")
                    }
                }
                .disabled(testState == .loading)
                switch testState {
                case .success:
                    Text("✓ 连接成功").font(.themeSecondary()).foregroundStyle(AppTheme.success)
                case .failed(let message):
                    Text(message).font(.themeSecondary()).foregroundStyle(AppTheme.dangerText)
                default: EmptyView()
                }
            }

            Section {
                Button {
                    fetchModels(provider)
                } label: {
                    if fetchState == .loading {
                        HStack(spacing: 8) { ProgressView(); Text("获取中…") }
                    } else {
                        Text("获取模型")
                    }
                }
                .disabled(fetchState == .loading)

                switch fetchState {
                case .empty:
                    Text("模型列表为空，请手动添加").font(.themeSecondary()).foregroundStyle(AppTheme.dangerText)
                case .failed(let message):
                    Text(message).font(.themeSecondary()).foregroundStyle(AppTheme.dangerText)
                default: EmptyView()
                }

                ForEach(provider.models, id: \.self) { model in
                    Button {
                        store.setDefaultModel(id: providerID, model: model)
                    } label: {
                        HStack {
                            Text(model).font(.themeBody()).foregroundStyle(AppTheme.textPrimary)
                            Spacer()
                            if model == provider.defaultModel {
                                Image(systemName: "checkmark").font(.themeBody()).foregroundStyle(AppTheme.accent)
                            }
                        }
                    }
                }

                HStack {
                    TextField("手动添加模型 ID（如 openai/gpt-5.6-sol）", text: $modelInput)
                        .font(.themeBody())
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .modelInput)
                        .submitLabel(.done)
                        .onSubmit { addModel(provider) }
                    Button("添加") { addModel(provider) }
                        .disabled(modelInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                Button("清空模型列表", role: .destructive) { showClearConfirm = true }
                    .disabled(provider.models.isEmpty)
            } header: {
                Text("模型管理")
            } footer: {
                Text("点击模型行设为默认模型。模型 ID 需为服务商要求的完整格式。")
            }

            Section {
                Button("删除该 Provider", role: .destructive) { showDeleteConfirm = true }
            }
        }
        .onChange(of: focusedField) { oldField, newField in
            if oldField == .baseURL && newField != .baseURL {
                if let current = provider?.baseURL {
                    store.updateBaseURL(id: providerID, baseURL: current)
                }
            }
        }
    }

    // MARK: - 绑定与逻辑

    /// 经 ProviderStore 的字段绑定（单一数据源，修改即广播+持久化）
    private func bind<T>(_ keyPath: WritableKeyPath<APIProvider, T>) -> Binding<T> {
        Binding(
            get: { provider?[keyPath: keyPath] ?? (APIProvider(name: "")[keyPath: keyPath]) },
            set: { store.update(id: providerID) { $0[keyPath: keyPath] = $1 } }
        )
    }

    private func addModel(_ provider: APIProvider) {
        let model = modelInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !model.isEmpty else { return }
        store.setDefaultModel(id: providerID, model: model)
        modelInput = ""
        focusedField = nil
    }

    private func fetchModels(_ provider: APIProvider) {
        guard provider.protocolKind.isImplemented else {
            fetchState = .failed("该协议即将支持")
            return
        }
        guard let key = store.apiKey(for: providerID), !key.isEmpty else {
            fetchState = .failed("请先保存 API Key")
            return
        }
        guard let url = URL(string: provider.baseURL + "/" + provider.protocolKind.modelsPath) else {
            fetchState = .failed("Base URL 无效")
            return
        }
        fetchState = .loading
        Task {
            do {
                var request = URLRequest(url: url)
                request.timeoutInterval = 30
                provider.protocolKind.authorize(&request, apiKey: key)
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                    let status = (response as? HTTPURLResponse)?.statusCode ?? -1
                    throw ChatError.api(status == 401 ? "API Key 无效" : "获取失败（HTTP \(status)）")
                }
                let models = try provider.protocolKind.parseModels(data: data)
                await MainActor.run {
                    if models.isEmpty {
                        fetchState = .empty
                    } else {
                        store.setModels(id: providerID, models: models)
                        fetchState = .done
                    }
                }
            } catch {
                await MainActor.run {
                    fetchState = .failed(ChatErrorMapper.map(error).errorDescription ?? "获取失败")
                }
            }
        }
    }

    private func testConnection(_ provider: APIProvider) {
        guard provider.protocolKind.isImplemented else {
            testState = .failed("该协议即将支持")
            return
        }
        guard let key = store.apiKey(for: providerID), !key.isEmpty else {
            testState = .failed("请先保存 API Key")
            return
        }
        guard let url = URL(string: provider.baseURL), url.scheme != nil else {
            testState = .failed("Base URL 无效")
            return
        }
        let config = ProviderConfig(
            providerID: providerID,
            endpoint: url,
            apiKey: key,
            model: provider.defaultModel
        )
        let request = ChatRequest(model: config.model, messages: [.init(role: .user, content: "ping")])
        testState = .loading
        Task {
            do {
                let providerInstance = AIProviderFactory.make(provider: provider, apiKey: key)
                for try await event in providerInstance.stream(request) {
                    if case .delta = event {
                        testState = .success
                        return
                    }
                }
                testState = .failed("连接成功但未收到内容")
            } catch {
                testState = .failed(ChatErrorMapper.map(error).errorDescription ?? "测试失败")
            }
        }
    }
}
