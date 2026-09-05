import Foundation

/// 本地假 AI：不联网，把用户消息回显成一段固定格式的流式输出。
/// 用途：Phase 3 在没有 API Key 的情况下验证完整对话流程（输入→流式→停止→持久化）。
struct EchoProvider: AIProvider {
    var id: String { "echo" }

    func stream(_ request: ChatRequest) -> AsyncThrowingStream<ChatEvent, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                let last = request.messages.last?.content ?? ""
                let reply = """
                （Echo 演示模式）你说的是：「\(last.prefix(50))」\
                —— 接入真实 API Key 后，这里将是模型的流式回答。\
                支持 **Markdown**、`行内代码` 与代码块。
                """
                for ch in reply {
                    if Task.isCancelled { break }
                    continuation.yield(.delta(String(ch)))
                    try? await Task.sleep(for: .milliseconds(15))
                }
                continuation.yield(.usage(TokenUsage(prompt: last.count, completion: reply.count)))
                continuation.yield(.finished(reason: "stop"))
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
