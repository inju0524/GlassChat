import Foundation

/// OpenAI 新一代 Responses API 实现。
/// POST {endpoint}/responses   body: { model, input, stream: true }
/// SSE 事件负载含 "type"：response.output_text.delta / response.completed / error 等。
struct OpenAIResponsesProvider: AIProvider {
    let config: ProviderConfig
    var id: String { config.presetID }

    func stream(_ request: ChatRequest) -> AsyncThrowingStream<ChatEvent, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    var urlRequest = URLRequest(url: config.endpoint.appending(path: "responses"))
                    urlRequest.httpMethod = "POST"
                    urlRequest.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
                    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    urlRequest.timeoutInterval = 120
                    let body: [String: Any] = [
                        "model": request.model,
                        "stream": true,
                        "input": request.messages.map { ["role": $0.role.rawValue, "content": $0.content] }
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
                            switch obj["type"] as? String {
                            case "response.output_text.delta":
                                if let delta = obj["delta"] as? String, !delta.isEmpty {
                                    continuation.yield(.delta(delta))
                                }
                            case "response.completed":
                                if let responseObj = obj["response"] as? [String: Any],
                                   let usage = responseObj["usage"] as? [String: Any] {
                                    let prompt = usage["input_tokens"] as? Int ?? 0
                                    let completion = usage["output_tokens"] as? Int ?? 0
                                    if prompt > 0 || completion > 0 {
                                        continuation.yield(.usage(TokenUsage(prompt: prompt, completion: completion)))
                                    }
                                }
                            case "error", "response.failed":
                                let message = (obj["message"] as? String)
                                    ?? ((obj["error"] as? [String: Any])?["message"] as? String)
                                    ?? "Responses API 返回错误"
                                throw ChatError.api(message)
                            default:
                                break
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
