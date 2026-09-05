import SwiftUI

/// 列表单行：图标瓦片 + 标题（置顶带 pin）+ 预览 + 时间标签。半透明材质（surfaceCard），非玻璃。
struct ConversationRow: View {
    let conversation: Conversation

    private var preview: String {
        let last = conversation.messages.sorted { $0.createdAt < $1.createdAt }.last?.content ?? ""
        let trimmed = last.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "暂无消息" : String(trimmed.prefix(40))
    }

    private var timeLabel: String {
        let date = conversation.updatedAt
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return date.formatted(date: .omitted, time: .shortened)
        }
        if calendar.isDateInYesterday(date) {
            return "昨天"
        }
        if calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear) {
            return date.formatted(.dateTime.weekday(.wide))
        }
        return date.formatted(date: .abbreviated, time: .omitted)
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: conversation.isPinned ? "sparkles" : "doc.text")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)
                .frame(width: 40, height: 40)
                .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 13))
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 5) {
                    if conversation.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(AppTheme.accent)
                    }
                    Text(conversation.title)
                        .font(.themeBody().weight(.semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineLimit(1)
                }
                Text(preview)
                    .font(.themeSecondary())
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            Text(timeLabel)
                .font(.themeCaption())
                .foregroundStyle(AppTheme.textTertiary)
        }
        .padding(13)
        .background(AppTheme.cardBackground())
    }
}
