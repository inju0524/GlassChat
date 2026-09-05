import Foundation

/// OpenAI 兼容协议实现（DeepSeek / Kimi / 智谱 / OpenRouter / Ollama 通吃）。
/// POST {endpoint}/chat/completions   body: { model, messages, stream: true }
/// SSE 事件：data: {"choices":[{"delta":{"content":"..."}}]}，data: [DONE] 结束。
/// TODO(Phase 4)：先实现非流式请求跑通；TODO(Phase 5)：接入 SSEDecoder 流式。
struct OpenAIChatProvider: AIProvider {
    let config: ProviderConfig
    var id: String { config.presetID }

    func stream(_ request: ChatRequest) -> AsyncThrowingStream<ChatEvent, Error> {
        AsyncThrowingStream { continuation in
            continuation.finish(throwing: ChatError.notImplemented)
            // TODO(Phase 4/5)：
            // 1. 构造 URLRequest（Authorization: Bearer <key>）
            // 2. URLSession.bytes(for:) 取 AsyncLineSequence
            // 3. SSEDecoder 逐行解析 delta.content → yield(.delta)
            // 4. 解析 usage → yield(.usage)；收到 [DONE] → yield(.finished) + finish()
        }
    }
}
