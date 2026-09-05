import Foundation
import Observation
import SwiftData

/// 对话页状态机：发送、流式接收、停止、删除失败消息。核心类。
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

    func send(context: ModelContext, conversation: Conversation) {
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
        generationTask = Task {
            do {
                let request = ChatRequest.make(
                    model: conversation.modelID,
                    history: conversation.messages.sorted { $0.createdAt < $1.createdAt }
                )
                let provider = EchoProvider()
                for try await event in provider.stream(request) {
                    if case .delta(let delta) = event {
                        assistant.content += delta
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

    func deleteFailed(_ message: Message, context: ModelContext) {
        guard message.status == .failed else { return }
        context.delete(message)
        try? context.save()
    }
}
