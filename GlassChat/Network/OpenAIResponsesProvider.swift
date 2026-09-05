import Foundation

/// OpenAI 新一代 Responses API 实现。
/// POST {endpoint}/responses   body: { model, input: [...], stream: true }
/// SSE 事件：response.output_text.delta（增量）、response.completed（含 usage）。
/// TODO(Phase 5)：在流式管线打通后实现。
struct OpenAIResponsesProvider: AIProvider {
    let config: ProviderConfig
    var id: String { config.presetID }

    func stream(_ request: ChatRequest) -> AsyncThrowingStream<ChatEvent, Error> {
        AsyncThrowingStream { continuation in
            continuation.finish(throwing: ChatError.notImplemented)
            // TODO(Phase 5)：与 OpenAIChatProvider 共用 SSE 管线，仅事件类型不同
        }
    }
}
