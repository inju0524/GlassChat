import Foundation
import SwiftData

/// 备份导出：对话 + 消息 + Provider 档案（不含 API Key）→ JSON 文件
enum BackupExporter {
    struct BackupFile: Codable {
        var exportedAt: Date
        var conversations: [ConversationDTO]
        var providers: [ProviderDTO]
    }

    struct ConversationDTO: Codable {
        var title: String
        var createdAt: Date
        var updatedAt: Date
        var isPinned: Bool
        var messages: [MessageDTO]
    }

    struct MessageDTO: Codable {
        var role: String
        var content: String
        var createdAt: Date
        var promptTokens: Int
        var completionTokens: Int
    }

    struct ProviderDTO: Codable {
        var name: String
        var protocolKind: String
        var baseURL: String
        var models: [String]
        var defaultModel: String
    }

    @MainActor
    static func exportJSON(context: ModelContext, providerStore: ProviderStore) throws -> URL {
        let conversations = try context.fetch(FetchDescriptor<Conversation>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        ))
        let convoDTOs = conversations.map { conversation in
            ConversationDTO(
                title: conversation.title,
                createdAt: conversation.createdAt,
                updatedAt: conversation.updatedAt,
                isPinned: conversation.isPinned,
                messages: conversation.messages
                    .sorted { $0.createdAt < $1.createdAt }
                    .map { message in
                        MessageDTO(
                            role: message.roleRaw,
                            content: message.content,
                            createdAt: message.createdAt,
                            promptTokens: message.promptTokens,
                            completionTokens: message.completionTokens
                        )
                    }
            )
        }
        let providerDTOs = providerStore.providers.map { provider in
            ProviderDTO(
                name: provider.name,
                protocolKind: provider.protocolKind.rawValue,
                baseURL: provider.baseURL,
                models: provider.models,
                defaultModel: provider.defaultModel
            )
        }
        let file = BackupFile(exportedAt: Date(), conversations: convoDTOs, providers: providerDTOs)

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmm"
        let name = "GlassChat备份-\(formatter.string(from: Date())).json"
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(name)
        try JSONEncoder().encode(file).write(to: url, options: .atomic)
        return url
    }
}
