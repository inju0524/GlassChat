import Foundation

/// 内置服务商预设：设置页选择预设后自动填好 Endpoint 与默认模型。
/// 全部走 OpenAI 兼容协议（Responses API 仅 OpenAI 官方提供）。
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
}
