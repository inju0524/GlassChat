import Foundation
import SwiftData

/// 一段对话（会话）。删除对话时级联删除其全部消息。
@Model
final class Conversation {
    var id: UUID = UUID()
    var title: String = "新对话"
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var isPinned: Bool = false
    /// 使用的服务商 id（对应 ProviderPreset.id）
    var providerID: String = "deepseek"
    /// 使用的模型 id（如 "deepseek-chat"）
    var modelID: String = "deepseek-chat"

    @Relationship(deleteRule: .cascade, inverse: \Message.conversation)
    var messages: [Message] = []

    init(title: String, providerID: String = "deepseek", modelID: String = "deepseek-chat") {
        self.title = title
        self.providerID = providerID
        self.modelID = modelID
    }

    /// 列表排序：置顶优先，其余按更新时间倒序
    static func sort(_ a: Conversation, _ b: Conversation) -> Bool {
        if a.isPinned != b.isPinned { return a.isPinned }
        return a.updatedAt > b.updatedAt
    }
}
