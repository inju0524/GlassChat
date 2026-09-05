import SwiftUI

/// 模型选择（detents Sheet）。TODO(Phase 4)：按所选服务商列出可选模型 + 自定义输入。
struct ModelPickerView: View {
    var body: some View {
        List { Text("Phase 4 实现") }
            .presentationDetents([.medium, .large])
            .navigationTitle("选择模型")
    }
}
