import SwiftUI
import SwiftData

/// 对话列表页。视觉基准：design-previews/scheme-a-dark.html 屏幕①。
/// 大标题"对话" + 玻璃搜索胶囊 + 半透明卡片列表 + 悬浮玻璃 Tab Bar + 玻璃新建按钮。
struct ConversationListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Conversation.updatedAt, order: .reverse)])
    private var conversations: [Conversation]

    var body: some View {
        ZStack {
            AppTheme.bg.ignoresSafeArea()
            if conversations.isEmpty {
                EmptyStateView()
            } else {
                // TODO(Phase 3)：列表 + 滑动操作（置顶/重命名/删除）+ .searchable
                Text("对话列表（Phase 3）")
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .navigationTitle("对话")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { /* TODO(Phase 3)：新建对话 */ } label: { Image(systemName: "plus") }
            }
        }
    }
}
