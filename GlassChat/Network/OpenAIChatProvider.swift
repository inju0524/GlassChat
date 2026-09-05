import Foundation

/// OpenAI 兼容协议实现（DeepSeek / Kimi / 智谱 / OpenRouter / Ollama 通吃）。
/// POST {endpoint}/chat/completions   body: { model, messages, stream: true }
/// SSE 事件：data: {"choices":[{"delta":{"content":"..."}}]}，data: [DONE] 结束。
struct OpenAIChatProvider: AIProvider {
    let config: ProviderConfig
    var id: String { config.presetID }

    func stream(_ request: ChatRequest) -> AsyncThrowingStream<ChatEvent, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    var urlRequest = URLRequest(url: config.endpoint.appending(path: "chat/completions"))
                    urlRequest.httpMethod = "POST"
                    urlRequest.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
                    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    urlRequest.timeoutInterval = 120
                    let body: [String: Any] = [
                        "model": request.model,
                        "stream": true,
                        "messages": request.messages.map { ["role": $0.role.rawValue, "content": $0.content] }
                    ]
                    urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body)

                    let (bytes, response) = try await URLSession.shared.bytes(for: urlRequest)
                    guard let http = response as? HTTPURLResponse else { throw ChatError.decoding }
                    guard (200..<300).contains(http.statusCode) else { throw ChatErrorMapper.from(status: http.statusCode) }

                    var decoder = SSEDecoder()
                    for try await line in bytes.lines {
                        if Task.isCancelled { break }
                        for payload in decoder.feed(line + "\n") {
                            guard let data = payload.data(using: .utf8),
                                  let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { continue }
                            if let err = obj["error"] as? [String: Any] {
                                throw ChatError.api((err["message"] as? String) ?? "API 返回错误")
                            }
                            if let choices = obj["choices"] as? [[String: Any]],
                               let delta = choices.first?["delta"] as? [String: Any],
                               let content = delta["content"] as? String, !content.isEmpty {
                                continuation.yield(.delta(content))
                            }
                            if let usage = obj["usage"] as? [String: Any] {
                                let prompt = usage["prompt_tokens"] as? Int ?? 0
                                let completion = usage["completion_tokens"] as? Int ?? 0
                                if prompt > 0 || completion > 0 {
                                    continuation.yield(.usage(TokenUsage(prompt: prompt, completion: completion)))
                                }
                            }
                        }
                    }
                    if Task.isCancelled { continuation.finish(); return }
                    continuation.yield(.finished(reason: "stop"))
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: ChatErrorMapper.map(error))
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
