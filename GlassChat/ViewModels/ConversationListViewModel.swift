import Foundation
import Observation
import SwiftData

/// 对话列表状态机：排序、搜索、增删改。Phase 3 实现。
@Observable
@MainActor
final class ConversationListViewModel {
    private(set) var searchText: String = ""

    // TODO(Phase 3)：通过 @Query 或 ModelContext 拉取并按 Conversation.sort 排序
    // TODO(Phase 3)：createConversation() -> Conversation（进入空对话页）
    // TODO(Phase 3)：rename / togglePin / delete（删除需确认弹窗）
}
