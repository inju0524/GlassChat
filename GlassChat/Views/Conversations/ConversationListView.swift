import SwiftUI
import SwiftData

/// 列表 → 对话页的导航路由。
enum ChatRoute: Hashable {
    case chat(Conversation, initialInput: String)
}

/// 对话列表页。视觉基准：design-previews/scheme-a-dark.html 屏幕①。
/// 大标题"对话" + 玻璃搜索胶囊 + 半透明卡片列表 + 玻璃新建按钮。
struct ConversationListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Conversation.updatedAt, order: .reverse)])
    private var conversations: [Conversation]

    @State private var path: [ChatRoute] = []
    @State private var searchText = ""
    @State private var renaming: Conversation?
    @State private var renameText = ""
    @State private var deleting: Conversation?

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                AppTheme.bg.ignoresSafeArea()
                content
            }
            .navigationTitle("对话")
            .searchable(text: $searchText, prompt: "搜索对话")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        let conversation = Conversation(title: "新对话")
                        modelContext.insert(conversation)
                        try? modelContext.save()
                        path.append(.chat(conversation, initialInput: ""))
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .navigationDestination(for: ChatRoute.self) { route in
                switch route {
                case .chat(let conversation, let initial):
                    ChatView(conversation: conversation, initialInput: initial)
                }
            }
            .alert("重命名对话", isPresented: Binding(
                get: { renaming != nil },
                set: { if !$0 { renaming = nil } }
            )) {
                TextField("对话名称", text: $renameText)
                Button("确定") {
                    if let conversation = renaming {
                        let name = renameText.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !name.isEmpty {
                            conversation.title = name
                            try? modelContext.save()
                        }
                    }
                    renaming = nil
                }
                Button("取消", role: .cancel) { }
            }
            .confirmationDialog(
                deleting?.title ?? "",
                isPresented: Binding(
                    get: { deleting != nil },
                    set: { if !$0 { deleting = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button("删除对话", role: .destructive) {
                    if let conversation = deleting {
                        path.removeAll { route in
                            if case .chat(let target, _) = route { return target == conversation }
                            return false
                        }
                        modelContext.delete(conversation)
                        try? modelContext.save()
                    }
                    deleting = nil
                }
                Button("取消", role: .cancel) { }
            } message: {
                Text("对话「\(deleting?.title ?? "")」及其全部消息将被删除，此操作不可撤销。")
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if conversations.isEmpty {
            EmptyStateView { text in
                let conversation = Conversation(title: "新对话")
                modelContext.insert(conversation)
                try? modelContext.save()
                path.append(.chat(conversation, initialInput: text))
            }
        } else if filtered.isEmpty {
            Text("没有找到相关对话")
                .font(.themeSecondary())
                .foregroundStyle(AppTheme.textTertiary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(sections) { section in
                        Text(section.title)
                            .font(.themeCaption())
                            .foregroundStyle(AppTheme.textTertiary)
                            .padding(.top, 12)
                        ForEach(section.items) { conversation in
                            row(for: conversation)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
    }

    private func row(for conversation: Conversation) -> some View {
        ConversationRow(conversation: conversation)
            .onTapGesture { path.append(.chat(conversation, initialInput: "")) }
            .contextMenu {
                Button {
                    renaming = conversation
                    renameText = conversation.title
                } label: {
                    Label("重命名", systemImage: "pencil")
                }
                Button {
                    conversation.isPinned.toggle()
                    try? modelContext.save()
                } label: {
                    Label(conversation.isPinned ? "取消置顶" : "置顶", systemImage: "pin")
                }
                Button(role: .destructive) {
                    deleting = conversation
                } label: {
                    Label("删除", systemImage: "trash")
                }
            }
    }

    private var filtered: [Conversation] {
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !keyword.isEmpty else { return conversations }
        return conversations.filter { conversation in
            if conversation.title.localizedCaseInsensitiveContains(keyword) { return true }
            let last = conversation.messages.sorted { $0.createdAt < $1.createdAt }.last?.content ?? ""
            return last.localizedCaseInsensitiveContains(keyword)
        }
    }

    private var sections: [ConversationSection] {
        let sorted = filtered.sorted(by: Conversation.sort)
        var pinned: [Conversation] = []
        var today: [Conversation] = []
        var yesterday: [Conversation] = []
        var earlier: [Conversation] = []
        let calendar = Calendar.current
        for conversation in sorted {
            if conversation.isPinned {
                pinned.append(conversation)
            } else if calendar.isDateInToday(conversation.updatedAt) {
                today.append(conversation)
            } else if calendar.isDateInYesterday(conversation.updatedAt) {
                yesterday.append(conversation)
            } else {
                earlier.append(conversation)
            }
        }
        var result: [ConversationSection] = []
        if !pinned.isEmpty { result.append(ConversationSection(title: "置顶", items: pinned)) }
        if !today.isEmpty { result.append(ConversationSection(title: "今天", items: today)) }
        if !yesterday.isEmpty { result.append(ConversationSection(title: "昨天", items: yesterday)) }
        if !earlier.isEmpty { result.append(ConversationSection(title: "更早", items: earlier)) }
        return result
    }
}

private struct ConversationSection: Identifiable {
    let title: String
    let items: [Conversation]
    var id: String { title }
}
