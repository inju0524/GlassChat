import SwiftUI
import SwiftData

/// 对话页。视觉基准：design-previews/scheme-a-dark.html 屏幕②。
/// 消息流 + 停止胶囊 + 模型 Chip + 玻璃输入栏（输入胶囊直接浮在内容上，无背景条）。
struct ChatView: View {
    let conversation: Conversation
    var initialInput: String = ""

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(SettingsStore.self) private var settings
    @Environment(ProviderStore.self) private var providerStore
    @Environment(NetworkMonitor.self) private var network

    @State private var viewModel = ChatViewModel()
    @State private var appliedInitialInput = false

    private var messages: [Message] {
        conversation.messages.sorted { $0.createdAt < $1.createdAt }
    }

    var body: some View {
        ZStack {
            AppTheme.bg.ignoresSafeArea()
            if messages.isEmpty {
                VStack(spacing: 10) {
                    ChatEmptyView { text in
                        viewModel.setInput(text)
                    }
                    Text("未配置 API Key 时将无法获得真实回复")
                        .font(.themeCaption())
                        .foregroundStyle(AppTheme.textTertiary)
                }
            } else {
                messageList
            }
        }
        .overlay(alignment: .top) {
            if !network.isOnline {
                HStack(spacing: 8) {
                    Image(systemName: "wifi.exclamationmark")
                    Text("无网络连接")
                }
                .font(.themeCaption())
                .foregroundStyle(AppTheme.dangerText)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.red.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(.red.opacity(0.3)))
                .transition(.move(edge: .top).combined(with: .opacity))
                .padding(.top, 4)
            }
        }
        .animation(.snappy, value: network.isOnline)
        .navigationTitle(conversation.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        modelContext.delete(conversation)
                        try? modelContext.save()
                        dismiss()
                    } label: {
                        Label("删除对话", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            inputArea
        }
        .onAppear {
            guard !appliedInitialInput else { return }
            appliedInitialInput = true
            if !initialInput.isEmpty {
                viewModel.setInput(initialInput)
            }
        }
    }

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 14) {
                    ForEach(messages) { message in
                        messageRow(message)
                            .id(message.persistentModelID)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: messages.count) { _, _ in
                scrollToBottom(proxy)
            }
            .onChange(of: messages.last?.content) { _, _ in
                scrollToBottom(proxy)
            }
        }
    }

    /// 拆分表达式：避免 SwiftUI 大表达式触发编译器类型检查超时
    private func messageRow(_ message: Message) -> some View {
        let isLastAssistant = message.id == messages.last?.id
            && message.role == .assistant && message.status == .finished
        return MessageView(
            message: message,
            tokenSummary: tokenSummary(for: message),
            onRetry: message.status == .failed ? { retryFailed(message) } : nil,
            onRegenerate: isLastAssistant && !viewModel.isGenerating ? { regenerateLast() } : nil
        )
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        guard let last = messages.last else { return }
        proxy.scrollTo(last.persistentModelID, anchor: .bottom)
    }

    private var inputArea: some View {
        VStack(spacing: 10) {
            if viewModel.isGenerating {
                HStack {
                    Spacer()
                    StopButton { viewModel.stop() }
                }
            }
            HStack {
                Text("● \(providerStore.activeProvider?.defaultModel ?? "Echo 演示")")
                    .font(.themeCaption())
                    .foregroundStyle(AppTheme.textSecondary)
                    .glassEffect()
                Spacer()
                if viewModel.isGenerating {
                    Text("正在生成")
                        .font(.themeCaption())
                        .foregroundStyle(AppTheme.textTertiary)
                }
            }
            GlassInputBar(
                text: Binding(
                    get: { viewModel.inputText },
                    set: { viewModel.setInput($0) }
                ),
                isGenerating: viewModel.isGenerating,
                onSend: { startSend() },
                onStop: { viewModel.stop() }
            )
        }
        .padding(.horizontal, 14)
        .padding(.top, 8)
        .padding(.bottom, 10)
    }

    /// 无有效配置时插入失败提示；有配置则按协议工厂构造真实 Provider
    private func startSend() {
        guard let provider = activeProviderOrNotify() else { return }
        viewModel.send(context: modelContext, conversation: conversation, provider: provider)
    }

    private func regenerateLast() {
        guard let provider = activeProviderOrNotify() else { return }
        viewModel.regenerate(context: modelContext, conversation: conversation, provider: provider)
    }

    private func activeProviderOrNotify() -> AIProvider? {
        guard let provider = providerStore.activeProvider,
              let key = providerStore.activeAPIKey, !key.isEmpty else {
            viewModel.insertNotConfiguredNotice(context: modelContext, conversation: conversation)
            return nil
        }
        return AIProviderFactory.make(provider: provider, apiKey: key)
    }

    private func tokenSummary(for message: Message) -> String? {
        guard message.role == .assistant, message.status == .finished else { return nil }
        guard message.promptTokens > 0 || message.completionTokens > 0 else { return nil }
        return "\(message.promptTokens) + \(message.completionTokens) tokens"
    }

    private func retryFailed(_ failed: Message) {
        modelContext.delete(failed)
        if let lastUser = messages.last(where: { $0.role == .user }) {
            viewModel.setInput(lastUser.content)
            modelContext.delete(lastUser)
        }
        try? modelContext.save()
    }
}
