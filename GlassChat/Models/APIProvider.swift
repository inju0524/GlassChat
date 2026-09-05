import Foundation

/// API 协议类型：决定 URL 路径、认证方式、请求体与解析方式。
/// Provider（服务档案）与协议分离——多个 Provider 可共用同一协议。
enum APIProtocolKind: String, Codable, CaseIterable {
    case openAICompatible = "openai"
    case anthropicMessages = "anthropic"   // 预留，暂未实现

    var displayName: String {
        switch self {
        case .openAICompatible: return "OpenAI 兼容"
        case .anthropicMessages: return "Anthropic Messages（即将支持）"
        }
    }

    /// 相对 Base URL 的对话 API 路径
    var apiPath: String {
        switch self {
        case .openAICompatible: return "chat/completions"
        case .anthropicMessages: return "messages"
        }
    }

    /// 相对 Base URL 的模型列表 API 路径
    var modelsPath: String {
        switch self {
        case .openAICompatible: return "models"
        case .anthropicMessages: return "models"
        }
    }

    var isImplemented: Bool {
        switch self {
        case .openAICompatible: return true
        case .anthropicMessages: return false
        }
    }

    /// 设置认证头：OpenAI 兼容用 Bearer，Anthropic 用 x-api-key + 版本号
    func authorize(_ request: inout URLRequest, apiKey: String) {
        switch self {
        case .openAICompatible:
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        case .anthropicMessages:
            request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
            request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        }
    }

    /// 构造请求体。未实现协议直接抛错，由调用方呈现。
    func makeBody(model: String, messages: [ChatRequest.RequestMessage], stream: Bool) throws -> Data {
        switch self {
        case .openAICompatible:
            let body: [String: Any] = [
                "model": model,
                "stream": stream,
                "messages": messages.map { ["role": $0.role.rawValue, "content": $0.content] }
            ]
            return try JSONSerialization.data(withJSONObject: body)
        case .anthropicMessages:
            throw ChatError.api("Anthropic 协议即将支持")
        }
    }

    /// 解析单条 SSE data 负载，返回 0..n 个事件。业务错误抛 ChatError.api。
    func parse(payload: String) throws -> [ChatEvent] {
        switch self {
        case .anthropicMessages:
            throw ChatError.api("Anthropic 协议即将支持")
        case .openAICompatible:
            guard let data = payload.data(using: .utf8),
                  let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return [] }
            if let err = obj["error"] as? [String: Any] {
                throw ChatError.api((err["message"] as? String) ?? "API 返回错误")
            }
            var events: [ChatEvent] = []
            if let choices = obj["choices"] as? [[String: Any]],
               let delta = choices.first?["delta"] as? [String: Any],
               let content = delta["content"] as? String, !content.isEmpty {
                events.append(.delta(content))
            }
            if let usage = obj["usage"] as? [String: Any] {
                let prompt = usage["prompt_tokens"] as? Int ?? 0
                let completion = usage["completion_tokens"] as? Int ?? 0
                if prompt > 0 || completion > 0 {
                    events.append(.usage(TokenUsage(prompt: prompt, completion: completion)))
                }
            }
            return events
        }
    }

    /// 解析 GET /models 响应，返回模型 ID 列表
    func parseModels(data: Data) throws -> [String] {
        guard let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw ChatError.decoding
        }
        if let err = obj["error"] as? [String: Any] {
            throw ChatError.api((err["message"] as? String) ?? "获取模型列表失败")
        }
        guard let list = obj["data"] as? [[String: Any]] else {
            throw ChatError.decoding
        }
        let ids = list.compactMap { $0["id"] as? String }
        return ids.sorted()
    }
}

/// 一个可切换的 API 服务商档案。API Key 不在此结构中——按 id 存于 Keychain。
struct APIProvider: Identifiable, Codable, Equatable {
    var id: String
    var name: String
    var protocolKind: APIProtocolKind
    var baseURL: String
    var models: [String]
    var defaultModel: String

    init(id: String = UUID().uuidString, name: String, protocolKind: APIProtocolKind = .openAICompatible, baseURL: String, models: [String] = [], defaultModel: String = "") {
        self.id = id
        self.name = name
        self.protocolKind = protocolKind
        self.baseURL = APIProvider.normalizedBaseURL(baseURL)
        self.models = models
        self.defaultModel = defaultModel
    }

    /// Base URL 规范化：只存基础地址。去空白/尾斜杠；误粘完整 endpoint 时剥离已知 API 路径；
    /// 折叠双斜杠与重复 /v1，避免请求路径重复拼接。
    static func normalizedBaseURL(_ raw: String) -> String {
        var s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        repeat {
            var changed = false
            while s.hasSuffix("/") { s.removeLast(); changed = true }
            let lower = s.lowercased()
            for suffix in ["/chat/completions", "/messages", "/responses", "/models"] where lower.hasSuffix(suffix) {
                s.removeLast(suffix.count)
                changed = true
            }
            if lower.hasSuffix("/v1/v1") {
                s.removeLast(3)
                changed = true
            }
            if !changed { break }
        } while true
        // 折叠路径中的双斜杠（保留 scheme 后的 "://"）
        if let schemeRange = s.range(of: "://") {
            let head = String(s[..<schemeRange.upperBound])
            let rest = String(s[schemeRange.upperBound...]).replacingOccurrences(of: "//", with: "/")
            s = head + rest
        } else {
            s = s.replacingOccurrences(of: "//", with: "/")
        }
        return s
    }
}
