import Foundation

/// 全部网络/AI 错误的统一映射。文案面向用户，附"是否可重试"。
enum ChatError: Error, Sendable {
    case offline            // 无网络（NetworkMonitor 判定）
    case timeout            // 请求超时
    case unauthorized       // 401 API Key 无效
    case rateLimited        // 429 限流
    case server(Int)        // 5xx
    case decoding           // 响应解析失败
    case cancelled          // 用户停止生成
    case notImplemented     // 骨架占位（Phase 4/5 实现）

    var isRetryable: Bool {
        switch self {
        case .offline, .timeout, .server, .rateLimited: return true
        case .unauthorized, .decoding, .cancelled, .notImplemented: return false
        }
    }
}

extension ChatError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .offline:        return "无网络连接，请检查网络后重试"
        case .timeout:        return "请求超时，请重试"
        case .unauthorized:   return "API Key 无效或已过期，请到设置中检查"
        case .rateLimited:    return "请求过于频繁，请稍后再试"
        case .server(let c):  return "服务器错误（\(c)），请稍后再试"
        case .decoding:       return "响应格式异常，请重试"
        case .cancelled:      return "已停止生成"
        case .notImplemented: return "该功能尚未实现"
        }
    }
}

/// 从底层 URLError / HTTP 状态码映射到 ChatError
enum ChatErrorMapper {
    static func map(_ error: Error) -> ChatError {
        if let e = error as? ChatError { return e }
        let ue = error as? URLError
        switch ue?.code {
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
            return .offline
        case .timedOut:
            return .timeout
        case .cancelled:
            return .cancelled
        default:
            return .decoding
        }
    }

    static func from(status: Int) -> ChatError {
        switch status {
        case 401, 403: return .unauthorized
        case 429: return .rateLimited
        case 500...599: return .server(status)
        default: return .server(status)
        }
    }
}
