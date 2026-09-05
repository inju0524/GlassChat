import SwiftUI

/// Provider 管理：列表 + 切换（点击行立即生效）+ 新增/编辑/删除。
struct ProviderListView: View {
    @Environment(ProviderStore.self) private var store

    @State private var path: [String] = []          // provider.id 导航栈
    @State private var deleting: APIProvider?

    var body: some View {
        Group {
            if store.providers.isEmpty {
                ContentUnavailableView(
                    "还没有 Provider",
                    systemImage: "square.stack.3d.up.slash",
                    description: Text("点击右上角 + 添加你的 API 服务商")
                )
            } else {
                providerList
            }
        }
        .background(AppTheme.bg.ignoresSafeArea())
        .navigationTitle("API Provider")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                addMenu
            }
        }
        .confirmationDialog(
            "删除 Provider",
            isPresented: Binding(get: { deleting != nil }, set: { if !$0 { deleting = nil } }),
            titleVisibility: .visible
        ) {
            Button("删除", role: .destructive) {
                if let target = deleting {
                    path.removeAll { $0 == target.id }
                    store.remove(id: target.id)
                }
            }
            Button("取消", role: .cancel) { }
        } message: {
            Text("将删除「\(deleting?.name ?? "")」及其保存的 API Key，此操作不可撤销。")
        }
    }

    private var providerList: some View {
        List {
            ForEach(store.providers) { provider in
                Button {
                    store.setActive(id: provider.id)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(provider.name)
                                .font(.themeBody())
                                .fontWeight(.semibold)
                                .foregroundStyle(AppTheme.textPrimary)
                            Text("\(provider.protocolKind.displayName) · \(provider.defaultModel.isEmpty ? "未设默认模型" : provider.defaultModel)")
                                .font(.themeCaption())
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        Spacer()
                        if provider.id == store.activeProviderID {
                            Image(systemName: "checkmark")
                                .font(.themeBody())
                                .foregroundStyle(AppTheme.accent)
                        }
                    }
                }
                .contextMenu {
                    Button { path.append(provider.id) } label: { Label("编辑", systemImage: "pencil") }
                    Button(role: .destructive) { deleting = provider } label: { Label("删除", systemImage: "trash") }
                }
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationDestination(for: String.self) { providerID in
            ProviderEditView(providerID: providerID)
        }
    }

    private var addMenu: some View {
        Menu {
            ForEach(ProviderPreset.all) { preset in
                Button {
                    let provider = APIProvider(
                        name: preset.displayName,
                        protocolKind: .openAICompatible,
                        baseURL: preset.endpoint,
                        models: preset.suggestedModels,
                        defaultModel: preset.defaultModel
                    )
                    store.add(provider)
                    path.append(provider.id)
                } label: {
                    Text(preset.displayName)
                }
            }
            Button {
                let provider = APIProvider(name: "自定义 Provider", baseURL: "")
                store.add(provider)
                path.append(provider.id)
            } label: {
                Text("空白自定义")
            }
        } label: {
            Image(systemName: "plus")
        }
    }
}
