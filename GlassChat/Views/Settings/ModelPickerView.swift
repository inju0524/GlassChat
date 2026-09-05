import SwiftUI

/// 当前启用 Provider 的默认模型选择：列表点选 + 手动添加（即添加即设为默认）。
struct ModelPickerView: View {
    @Environment(ProviderStore.self) private var store

    @State private var modelInput = ""

    private var active: APIProvider? { store.activeProvider }

    var body: some View {
        Group {
            if let provider = active {
                modelList(provider)
            } else {
                ContentUnavailableView(
                    "未配置 Provider",
                    systemImage: "square.stack.3d.up.slash",
                    description: Text("请先在「API Provider」中添加并启用一个服务商")
                )
            }
        }
        .background(AppTheme.bg.ignoresSafeArea())
        .navigationTitle("默认模型")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .simultaneousGesture(TapGesture().onEnded { _ in modelInput = "" })
    }

    @ViewBuilder
    private func modelList(_ provider: APIProvider) -> some View {
        List {
            Section {
                if provider.models.isEmpty {
                    Text("模型列表为空，请在 Provider 编辑页获取或添加模型")
                        .font(.themeSecondary())
                        .foregroundStyle(AppTheme.textSecondary)
                }
                ForEach(provider.models, id: \.self) { model in
                    Button {
                        store.setDefaultModel(id: provider.id, model: model)
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
            } header: {
                Text(provider.name)
            } footer: {
                Text("点击模型设为默认。当前默认：\(provider.defaultModel.isEmpty ? "未设置" : provider.defaultModel)")
            }

            Section("手动添加") {
                HStack {
                    TextField("模型 ID（如 openai/gpt-5.6-sol）", text: $modelInput)
                        .font(.themeBody())
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .submitLabel(.done)
                        .onSubmit { addModel(provider) }
                    Button("添加并使用") { addModel(provider) }
                        .disabled(modelInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func addModel(_ provider: APIProvider) {
        let model = modelInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !model.isEmpty else { return }
        store.setDefaultModel(id: provider.id, model: model)
        modelInput = ""
    }
}
