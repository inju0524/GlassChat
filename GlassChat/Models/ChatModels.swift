import Foundation
import SwiftData

/// 发送给 AI 的一次请求（由对话内消息组装而来）
struct ChatRequest: Sendable {
    struct RequestMessage: Sendable {
        var role: Role
        var content: String
    }

    var model: String
    var messages: [RequestMessage]

    /// 由会话内全部消息（按时间排序）构造请求
    static func make(model: String, history: [Message]) -> ChatRequest {
        ChatRequest(
            model: model,
            messages: history.map { .init(role: $0.role, content: $0.content) }
        )
    }
}

/// token 用量统计（来自 API 响应的 usage 字段）
struct TokenUsage: Equatable, Sendable {
    var prompt: Int
    var completion: Int

    var total: Int { prompt + completion }
}
