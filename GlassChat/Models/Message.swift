import Foundation
import SwiftData

enum Role: String, Codable {
    case user, assistant, system
}

enum MessageStatus: String, Codable {
    case streaming   // 正在流式生成
    case finished    // 正常完成
    case stopped     // 用户手动停止
    case failed      // 生成失败（errorText 有值）
}

/// 单条消息。role/status 以原始字符串持久化，通过计算属性类型化访问。
@Model
final class Message {
    var id: UUID = UUID()
    var roleRaw: String = Role.user.rawValue
    var content: String = ""
    var statusRaw: String = MessageStatus.finished.rawValue
    var createdAt: Date = Date()
    /// token 用量（仅 assistant 消息记录）
    var promptTokens: Int = 0
    var completionTokens: Int = 0
    /// 失败时的用户可读错误信息
    var errorText: String?
    var conversation: Conversation?

    init(role: Role, content: String = "", status: MessageStatus = .finished) {
        self.roleRaw = role.rawValue
        self.content = content
        self.statusRaw = status.rawValue
    }

    var role: Role {
        get { Role(rawValue: roleRaw) ?? .user }
        set { roleRaw = newValue.rawValue }
    }
    var status: MessageStatus {
        get { MessageStatus(rawValue: statusRaw) ?? .finished }
        set { statusRaw = newValue.rawValue }
    }
}
