import Foundation
import Observation
import SwiftData

/// 对话页状态机：发送、流式接收、停止、重新生成、删除失败消息。核心类。
@Observable
@MainActor
final class ChatViewModel {
    /// 正在进行的生成任务；停止生成 = task.cancel()
    @ObservationIgnored private var generationTask: Task<Void, Never>?

    private(set) var inputText: String = ""
    private(set) var isGenerating: Bool = false

    var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isGenerating
    }

    func setInput(_ text: String) {
        inputText = text
    }

    func stop() {
        generationTask?.cancel()
    }

    /// 发送：用户消息 + assistant 占位入库，随后用传入的 Provider 流式填充。
    func send(context: ModelContext, conversation: Conversation, provider: AIProvider) {
        guard canSend else { return }
        let text = inputText
        inputText = ""

        let user = Message(role: .user, content: text)
        let assistant = Message(role: .assistant, content: "", status: .streaming)
        user.conversation = conversation
        assistant.conversation = conversation
        context.insert(user)
        context.insert(assistant)

        if conversation.title == "新对话" {
            conversation.title = String(text.prefix(20))
        }
        conversation.updatedAt = Date()
        try? context.save()

        isGenerating = true
        generationTask = streamTask(provider: provider, conversation: conversation, assistant: assistant)
    }

    /// 重新生成：删除最后一条 assistant 消息，重新流式填充。
    func regenerate(context: ModelContext, conversation: Conversation, provider: AIProvider) {
        guard !isGenerating else { return }
        let sorted = conversation.messages.sorted { $0.createdAt < $1.createdAt }
        guard let lastAssistant = sorted.last, lastAssistant.role == .assistant else { return }
        context.delete(lastAssistant)

        let assistant = Message(role: .assistant, content: "", status: .streaming)
        assistant.conversation = conversation
        context.insert(assistant)
        try? context.save()

        isGenerating = true
        generationTask = streamTask(provider: provider, conversation: conversation, assistant: assistant)
    }

    /// 无有效 Provider 配置时，插入一条失败占位消息引导用户去设置
    func insertNotConfiguredNotice(context: ModelContext, conversation: Conversation) {
        let message = Message(role: .assistant, content: "", status: .failed)
        message.conversation = conversation
        message.errorText = ChatError.notConfigured.errorDescription
        context.insert(message)
        try? context.save()
    }

    func deleteFailed(_ message: Message, context: ModelContext) {
        guard message.status == .failed else { return }
        context.delete(message)
        try? context.save()
    }

    /// 流式任务：消费 Provider 事件流，把增量写入 assistant 消息，结束时落定状态。
    private func streamTask(provider: AIProvider, conversation: Conversation, assistant: Message) -> Task<Void, Never> {
        Task {
            do {
                let history = conversation.messages
                    .sorted { $0.createdAt < $1.createdAt }
                    .filter { !($0.content.isEmpty && $0.status == .streaming) }
                let request = ChatRequest.make(model: conversation.modelID, history: history)
                for try await event in provider.stream(request) {
                    switch event {
                    case .delta(let delta):
                        assistant.content += delta
                    case .usage(let usage):
                        assistant.promptTokens = usage.prompt
                        assistant.completionTokens = usage.completion
                    case .finished:
                        break
                    }
                }
            } catch {
                if !(error is CancellationError) {
                    assistant.status = .failed
                    assistant.errorText = ChatErrorMapper.map(error).errorDescription
                }
            }
            if assistant.status == .streaming {
                assistant.status = Task.isCancelled ? .stopped : .finished
            }
            self.isGenerating = false
        }
    }
}
