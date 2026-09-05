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
                        let isLastAssistant = message.id == messages.last?.id
                            && message.role == .assistant && message.status == .finished
                        MessageView(
                            message: message,
                            onRetry: message.status == .failed ? { retryFailed(message) } : nil,
                            onRegenerate: isLastAssistant && !viewModel.isGenerating
                                ? { regenerateLast() } : nil
                        )
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
                Text("● \(settings.model)")
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
                onSend: {
                    viewModel.send(
                        context: modelContext,
                        conversation: conversation,
                        provider: makeProvider()
                    )
                },
                onStop: { viewModel.stop() }
            )
        }
        .padding(.horizontal, 14)
        .padding(.top, 8)
        .padding(.bottom, 10)
    }

    /// 有真实配置时按预设走兼容协议或 Responses API；未配置则回退 Echo 演示。
    private func makeProvider() -> AIProvider {
        if let config = settings.makeProviderConfig() {
            return AIProviderFactory.make(config: config)
        }
        return EchoProvider()
    }

    private func regenerateLast() {
        viewModel.regenerate(
            context: modelContext,
            conversation: conversation,
            provider: makeProvider()
        )
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
