import Foundation
import SwiftData

/// 对话/消息的持久化读写封装。ViewModel 不直接触碰 ModelContext。
/// TODO(Phase 6)：实现真实读写；Phase 3 先用内存上下文跑通流程。
@MainActor
final class ConversationStore {
    private let _container: ModelContainer

    init(inMemory: Bool = false) {
        _container = try! ModelContainer(
            for: Conversation.self, Message.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: inMemory)
        )
    }

    var container: ModelContainer { _container }
    // TODO(Phase 6)：createConversation / appendMessage / deleteConversation /
    //                 renameConversation / togglePin / searchConversations
}
