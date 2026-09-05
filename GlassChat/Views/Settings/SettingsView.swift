import SwiftUI

/// 设置页。视觉基准：预览稿 ③ —— 玻璃分组卡（API 服务 / 外观 / 数据 / 关于）。
/// TODO(Phase 2)：静态实现；TODO(Phase 4)：API 配置与连接测试。
struct SettingsView: View {
    var body: some View {
        ZStack {
            AppTheme.bg.ignoresSafeArea()
            Text("设置（Phase 2）").foregroundStyle(AppTheme.textSecondary)
        }
        .navigationTitle("设置")
    }
}
