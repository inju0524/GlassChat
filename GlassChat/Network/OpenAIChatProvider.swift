import Foundation

/// OpenAI 兼容协议的通用流式实现（适配器由 APIProtocolKind 提供）。
/// URL = Base URL（已规范化）+ apiPath；非 2xx 时解析响应体中的错误信息。
struct OpenAIChatProvider: AIProvider {
    let config: ProviderConfig
    let kind: APIProtocolKind

    init(config: ProviderConfig, kind: APIProtocolKind = .openAICompatible) {
        self.config = config
        self.kind = kind
    }

    var id: String { config.providerID }

    func stream(_ request: ChatRequest) -> AsyncThrowingStream<ChatEvent, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    var urlRequest = URLRequest(url: config.endpoint.appending(path: kind.apiPath))
                    urlRequest.httpMethod = "POST"
                    urlRequest.timeoutInterval = 120
                    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    kind.authorize(&urlRequest, apiKey: config.apiKey)
                    urlRequest.httpBody = try kind.makeBody(
                        model: config.model,
                        messages: request.messages,
                        stream: true
                    )

                    let (bytes, response) = try await URLSession.shared.bytes(for: urlRequest)
                    guard let http = response as? HTTPURLResponse else { throw ChatError.decoding }
                    guard (200..<300).contains(http.statusCode) else {
                        throw try await Self.error(from: bytes, status: http.statusCode)
                    }

                    var decoder = SSEDecoder()
                    for try await line in bytes.lines {
                        if Task.isCancelled { break }
                        for payload in decoder.feed(line + "\n") {
                            for event in try kind.parse(payload: payload) {
                                continuation.yield(event)
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

    /// 非 2xx：优先解析响应体中服务商给出的可读错误（如 "Model ... does not exist"）
    private static func error(from bytes: URLSession.AsyncBytes, status: Int) async throws -> Error {
        var body = ""
        var iterator = bytes.lines.makeAsyncIterator()
        while case let line? = await iterator.next() {
            body += line
            if body.count > 8_000 { break }
        }
        if let data = body.data(using: .utf8),
           let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let err = obj["error"] as? [String: Any], let message = err["message"] as? String {
                return ChatError.api("\(message)（HTTP \(status)）")
            }
            if let message = obj["message"] as? String {
                return ChatError.api("\(message)（HTTP \(status)）")
            }
        }
        return ChatErrorMapper.from(status: status)
    }
}
