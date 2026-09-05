import SwiftUI

/// 模型选择：按所选服务商列出推荐模型 + 自定义输入。
struct ModelPickerView: View {
    @Environment(SettingsStore.self) private var store

    @State private var customModel = ""

    var body: some View {
        @Bindable var store = store
        List {
            Section("推荐模型（\(ProviderPreset.find(store.providerID).displayName)）") {
                ForEach(ProviderPreset.find(store.providerID).suggestedModels, id: \.self) { model in
                    Button {
                        store.model = model
                    } label: {
                        HStack {
                            Text(model)
                                .font(.themeBody())
                                .foregroundStyle(AppTheme.textPrimary)
                            Spacer()
                            if store.model == model {
                                Image(systemName: "checkmark")
                                    .font(.themeSecondary())
                                    .foregroundStyle(AppTheme.accent)
                            }
                        }
                    }
                }
            }

            Section("自定义") {
                HStack {
                    TextField("模型 ID", text: $customModel)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    Button("使用") {
                        let model = customModel.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !model.isEmpty else { return }
                        store.model = model
                    }
                }
            }

            Section {
                Text("当前模型：\(store.model)")
                    .font(.themeSecondary())
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .navigationTitle("默认模型")
    }
}
