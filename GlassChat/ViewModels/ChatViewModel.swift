import Foundation
import Observation
import SwiftData

/// 对话页状态机：发送、流式接收、停止、重试。核心类。
@Observable
@MainActor
final class ChatViewModel {
    /// 正在进行的生成任务；停止生成 = task.cancel()
    @ObservationIgnored private var generationTask: Task<Void, Never>?

    private(set) var inputText: String = ""
    private(set) var isGenerating: Bool = false

    var canSend: Bool { !inputText.isEmpty && !isGenerating }

    func setInput(_ text: String) { inputText = text }

    // TODO(Phase 3)：send(in: EchoProvider)      —— 回显模式跑通全流程
    // TODO(Phase 4)：send(in: AIProvider)        —— 真实 API（先非流式）
    // TODO(Phase 5)：流式接入：delta → message.content 追加 + 钉底滚动
    // TODO(Phase 5)：stop() → generationTask?.cancel()，status = .stopped，保留已生成文本
    // TODO(Phase 5)：regenerate(_ message: Message)
}
