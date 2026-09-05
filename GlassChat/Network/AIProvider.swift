import Foundation

/// 已解析的连接配置（由 ProviderStore.activeProvider + Keychain Key 构造）
struct ProviderConfig: Sendable, Equatable {
    var providerID: String
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

/// AI 供应商抽象。实现方按 APIProtocolKind 适配请求与解析。
protocol AIProvider: Sendable {
    var id: String { get }
    func stream(_ request: ChatRequest) -> AsyncThrowingStream<ChatEvent, Error>
}

/// 工厂：由 Provider 档案 + Key 构造对应协议的 Provider 实例
enum AIProviderFactory {
    static func make(provider: APIProvider, apiKey: String) -> AIProvider {
        guard provider.protocolKind.isImplemented else {
            return ErrorProvider(reason: "\(provider.protocolKind.displayName) 即将支持")
        }
        guard let url = URL(string: provider.baseURL), url.scheme != nil else {
            return ErrorProvider(reason: "Base URL 无效：\(provider.baseURL)")
        }
        let config = ProviderConfig(
            providerID: provider.id,
            endpoint: url,
            apiKey: apiKey,
            model: provider.defaultModel
        )
        switch provider.protocolKind {
        case .openAICompatible: return OpenAIChatProvider(config: config)
        case .anthropicMessages: return ErrorProvider(reason: "Anthropic 协议即将支持")
        }
    }
}

/// 工厂兜底：配置无效时返回一个立即抛错的流
private struct ErrorProvider: AIProvider {
    let reason: String
    var id: String { "invalid" }

    func stream(_ request: ChatRequest) -> AsyncThrowingStream<ChatEvent, Error> {
        AsyncThrowingStream { $0.finish(throwing: ChatError.api(reason)) }
    }
}

extension AIProviderFactory {
    /// 连接测试：发一条最小请求，收到首个增量即成功（返回 nil），否则返回错误文案
    static func testConnection(provider: APIProvider, apiKey: String) async -> String? {
        guard provider.protocolKind.isImplemented else {
            return "\(provider.protocolKind.displayName) 即将支持"
        }
        guard let url = URL(string: provider.baseURL), url.scheme != nil else {
            return "Base URL 无效：\(provider.baseURL)"
        }
        let config = ProviderConfig(providerID: provider.id, endpoint: url, apiKey: apiKey, model: provider.defaultModel)
        let request = ChatRequest(model: config.model, messages: [.init(role: .user, content: "ping")])
        do {
            for try await event in make(provider: provider, apiKey: apiKey).stream(request) {
                if case .delta = event { return nil }
            }
            return "连接成功但未收到内容"
        } catch {
            return ChatErrorMapper.map(error).errorDescription
        }
    }
}
