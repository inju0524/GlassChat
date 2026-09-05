import Foundation

/// 内置服务商预设：设置页选择预设后自动填好 Endpoint 与默认模型。
struct ProviderPreset: Identifiable, Equatable {
    let id: String
    let displayName: String
    let endpoint: String
    let defaultModel: String
    let usesResponsesAPI: Bool

    static let all: [ProviderPreset] = [
        .init(id: "deepseek", displayName: "DeepSeek", endpoint: "https://api.deepseek.com/v1", defaultModel: "deepseek-chat", usesResponsesAPI: false),
        .init(id: "openai", displayName: "OpenAI", endpoint: "https://api.openai.com/v1", defaultModel: "gpt-4o-mini", usesResponsesAPI: false),
        .init(id: "openai-responses", displayName: "OpenAI (Responses)", endpoint: "https://api.openai.com/v1", defaultModel: "gpt-4o-mini", usesResponsesAPI: true),
        .init(id: "zhipu", displayName: "智谱 GLM", endpoint: "https://open.bigmodel.cn/api/paas/v4", defaultModel: "glm-4-flash", usesResponsesAPI: false),
        .init(id: "moonshot", displayName: "Kimi", endpoint: "https://api.moonshot.cn/v1", defaultModel: "moonshot-v1-8k", usesResponsesAPI: false),
        .init(id: "ollama", displayName: "Ollama（本地）", endpoint: "http://localhost:11434/v1", defaultModel: "qwen2.5:7b", usesResponsesAPI: false),
        .init(id: "custom", displayName: "自定义", endpoint: "", defaultModel: "", usesResponsesAPI: false),
    ]

    static func find(_ id: String) -> ProviderPreset {
        all.first { $0.id == id } ?? all[0]
    }

    /// 模型选择页的推荐列表
    var suggestedModels: [String] {
        switch id {
        case "deepseek": return ["deepseek-chat", "deepseek-reasoner"]
        case "openai": return ["gpt-4o-mini", "gpt-4o", "o4-mini"]
        case "openai-responses": return ["gpt-4o-mini", "gpt-4o", "o4-mini"]
        case "zhipu": return ["glm-4-flash", "glm-4-plus", "glm-4.5"]
        case "moonshot": return ["moonshot-v1-8k", "moonshot-v1-32k"]
        case "ollama": return ["qwen2.5:7b", "llama3.1:8b"]
        default: return []
        }
    }
}
