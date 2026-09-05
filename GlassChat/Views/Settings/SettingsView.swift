import SwiftUI
import SwiftData
import UIKit

/// 设置页。视觉基准：预览稿 ③ —— 玻璃分组卡（API 服务 / 外观 / 数据 / 关于）。
struct SettingsView: View {
    @Environment(SettingsStore.self) private var settings
    @Environment(ProviderStore.self) private var providerStore
    @Environment(\.modelContext) private var modelContext
    @Query private var allConversations: [Conversation]

    @State private var showingClearDialog = false
    @State private var exportURL: IdentifiedURL?
    @State private var isTesting = false
    @State private var testResult: String?
    @State private var testOK = false

    var body: some View {
        @Bindable var settings = settings
        NavigationStack {
            ZStack {
                AppTheme.bg.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        apiCard
                        card("外观") {
                            row("主题") {
                                Picker("主题", selection: $settings.appearanceRaw) {
                                    Text("跟随系统").tag("system")
                                    Text("浅色").tag("light")
                                    Text("深色").tag("dark")
                                }
                                .pickerStyle(.segmented)
                                .frame(width: 200)
                            }
                            Divider().padding(.leading, 17)
                            row("液态玻璃效果") {
                                Toggle("", isOn: $settings.liquidGlassEnabled)
                                    .tint(AppTheme.accent)
                                    .labelsHidden()
                                    .fixedSize()
                            }
                        }
                        dataCard
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
            .sheet(item: $exportURL) { item in
                ActivityShareSheet(items: [item.url])
            }
        }
    }

    // MARK: - API 服务卡

    private var apiCard: some View {
        card("API 服务") {
            NavigationLink {
                ProviderListView()
            } label: {
                row("当前 Provider") {
                    Text(providerStore.activeProvider?.name ?? "未配置")
                        .font(.themeSecondary())
                        .foregroundStyle(providerStore.activeProvider == nil ? AppTheme.dangerText : AppTheme.textSecondary)
                }
            }
            Divider().padding(.leading, 17)
            NavigationLink {
                ModelPickerView()
            } label: {
                row("默认模型") {
                    Text(providerStore.activeProvider?.defaultModel.isEmpty == false
                         ? providerStore.activeProvider!.defaultModel
                         : "—")
                        .font(.themeSecondary())
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineLimit(1)
                }
            }
            Divider().padding(.leading, 17)
            Button {
                runConnectionTest()
            } label: {
                if isTesting {
                    row("测试中…", labelColor: AppTheme.textSecondary) { EmptyView() }
                } else {
                    row("测试连接", labelColor: AppTheme.accent) { EmptyView() }
                }
            }
            .disabled(isTesting || providerStore.activeProvider == nil)
            if let testResult {
                Text(testOK ? "✓ 连接成功" : testResult)
                    .font(.themeSecondary())
                    .foregroundStyle(testOK ? AppTheme.success : AppTheme.dangerText)
                    .padding(.horizontal, 17)
                    .padding(.vertical, 8)
            }
        }
    }

    // MARK: - 数据卡

    private var dataCard: some View {
        card("数据") {
            row("对话记录") {
                Text("\(allConversations.count) 条")
                    .font(.themeSecondary())
                    .foregroundStyle(AppTheme.textSecondary)
            }
            Divider().padding(.leading, 17)
            Button {
                if let url = try? BackupExporter.exportJSON(context: modelContext, providerStore: providerStore) {
                    exportURL = IdentifiedURL(url: url)
                }
            } label: {
                row("导出备份") {
                    Text("JSON")
                        .font(.themeSecondary())
                        .foregroundStyle(AppTheme.textSecondary)
                }
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
    }

    // MARK: - 连接测试

    private func runConnectionTest() {
        guard let provider = providerStore.activeProvider else {
            testOK = false
            testResult = "未配置 Provider"
            return
        }
        guard let key = providerStore.activeAPIKey else {
            testOK = false
            testResult = "请先在 Provider 编辑页保存 API Key"
            return
        }
        isTesting = true
        testResult = nil
        Task {
            let failure = await AIProviderFactory.testConnection(provider: provider, apiKey: key)
            testOK = (failure == nil)
            testResult = failure
            isTesting = false
        }
    }

    // MARK: - 通用

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

struct IdentifiedURL: Identifiable {
    let id = UUID()
    let url: URL
}

struct ActivityShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) { }
}
