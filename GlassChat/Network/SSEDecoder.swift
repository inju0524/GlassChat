import Foundation

/// SSE（Server-Sent Events）增量解码器。
/// 处理：按行切分、"data:" 前缀剥离、跨 chunk 半包缓冲、[DONE] 结束标记。
/// Phase 5 实现；当前提供最小可用版本（chat/completions 的 JSON 行已够用）。
struct SSEDecoder {
    private var buffer: String = ""

    /// 喂入一段原始文本（可能是不完整的 chunk），返回其中完整的 data 负载。
    mutating func feed(_ text: String) -> [String] {
        buffer += text
        var payloads: [String] = []

        while let newline = buffer.firstIndex(of: "\n") {
            let line = String(buffer[..<newline])
            buffer.removeSubrange(...newline)

            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.hasPrefix("data:") else { continue }
            let payload = trimmed.dropFirst(5).trimmingCharacters(in: .whitespaces)
            if payload == "[DONE]" { continue }
            if !payload.isEmpty { payloads.append(String(payload)) }
        }
        return payloads
    }
}
