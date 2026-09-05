import Foundation

/// 服务商连接配置。API Key 由 KeychainService 读取，绝不落盘到 UserDefaults。
struct ProviderConfig: Sendable, Equatable {
    var presetID: String
    var endpoint: URL
    var apiKey: String
    var model: String
}

/// 流式过程中产生的事件。ViewModel 只认这三种事件，与具体协议解耦。
enum ChatEvent: Sendable {
    case delta(String)              // 增量文本
    case usage(TokenUsage)          // usage 统计（可能不出现）
    case finished(reason: String?)  // 正常结束
}

/// AI 供应商抽象。两个实现：
/// - OpenAIChatProvider      POST {endpoint}/chat/completions  (stream: true)
/// - OpenAIResponsesProvider POST {endpoint}/responses         (stream: true)
protocol AIProvider: Sendable {
    var id: String { get }
    func stream(_ request: ChatRequest) -> AsyncThrowingStream<ChatEvent, Error>
}

/// 从 ChatRequest 构造对应 Provider 的工厂
enum AIProviderFactory {
    static func make(config: ProviderConfig) -> AIProvider {
        let preset = ProviderPreset.find(config.presetID)
        if preset.usesResponsesAPI {
            return OpenAIResponsesProvider(config: config)
        }
        return OpenAIChatProvider(config: config)
    }
}
