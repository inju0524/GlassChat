import SwiftUI
import SwiftData

/// 设置页。视觉基准：预览稿 ③ —— 玻璃分组卡（API 服务 / 外观 / 数据 / 关于）。
struct SettingsView: View {
    @Environment(SettingsStore.self) private var store
    @Environment(\.modelContext) private var modelContext
    @Query private var allConversations: [Conversation]

    @State private var showingClearDialog = false

    var body: some View {
        @Bindable var store = store
        NavigationStack {
            ZStack {
                AppTheme.bg.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        card("API 服务") {
                            NavigationLink {
                                APIConfigView()
                            } label: {
                                row("提供商") {
                                    Text(ProviderPreset.find(store.providerID).displayName)
                                        .font(.themeSecondary())
                                        .foregroundStyle(AppTheme.textSecondary)
                                }
                            }
                            Divider().padding(.leading, 17)
                            NavigationLink {
                                APIConfigView()
                            } label: {
                                row("API Key") { keyBadge }
                            }
                            Divider().padding(.leading, 17)
                            NavigationLink {
                                ModelPickerView()
                            } label: {
                                row("默认模型") {
                                    Text(store.model)
                                        .font(.themeSecondary())
                                        .foregroundStyle(AppTheme.textSecondary)
                                        .lineLimit(1)
                                }
                            }
                        }

                        card("外观") {
                            row("主题") {
                                Picker("主题", selection: $store.appearanceRaw) {
                                    Text("跟随系统").tag("system")
                                    Text("浅色").tag("light")
                                    Text("深色").tag("dark")
                                }
                                .pickerStyle(.segmented)
                                .frame(width: 200)
                            }
                            Divider().padding(.leading, 17)
                            row("液态玻璃效果") {
                                Toggle("", isOn: $store.liquidGlassEnabled)
                                    .tint(AppTheme.accent)
                                    .labelsHidden()
                                    .fixedSize()
                            }
                        }

                        card("数据") {
                            row("对话记录") {
                                Text("\(allConversations.count) 条")
                                    .font(.themeSecondary())
                                    .foregroundStyle(AppTheme.textSecondary)
                            }
                            Divider().padding(.leading, 17)
                            Button {
                                showingClearDialog = true
                            } label: {
                                row("清除全部对话", labelColor: AppTheme.dangerText) {
                                    EmptyView()
                                }
                            }
                        }

                        card("关于") {
                            row("版本") {
                                Text(versionString)
                                    .font(.themeSecondary())
                                    .foregroundStyle(AppTheme.textSecondary)
                            }
                        }

                        Text("API Key 保存在 iOS 钥匙串中 · 对话数据仅存于本机")
                            .font(.themeCaption())
                            .foregroundStyle(AppTheme.textTertiary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("设置")
            .confirmationDialog("清除全部对话", isPresented: $showingClearDialog, titleVisibility: .visible) {
                Button("删除", role: .destructive) {
                    try? modelContext.delete(model: Conversation.self)
                    try? modelContext.save()
                }
                Button("取消", role: .cancel) { }
            } message: {
                Text("全部对话与消息将被删除，此操作不可撤销。")
            }
        }
    }

    private var keyBadge: some View {
        let key = KeychainService.loadKey(for: store.providerID)
        return HStack(spacing: 5) {
            if let key, !key.isEmpty {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(AppTheme.success)
            }
            Text(KeychainService.maskedKey(key))
                .font(.themeSecondary())
                .foregroundStyle(AppTheme.textSecondary)
        }
    }

    private var versionString: String {
        (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? "1.0.0"
    }

    private func row(_ label: String,
                     labelColor: Color = AppTheme.textPrimary,
                     @ViewBuilder value: () -> some View) -> some View {
        HStack {
            Text(label)
                .font(.themeBody())
                .foregroundStyle(labelColor)
            Spacer()
            value()
        }
        .padding(.horizontal, 17)
        .padding(.vertical, 10)
    }

    private func card(_ header: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(header)
                .font(.themeCaption())
                .foregroundStyle(AppTheme.textTertiary)
            VStack(spacing: 0) {
                content()
            }
            .background(AppTheme.cardBackground())
        }
    }
}
