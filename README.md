# GlassChat

原生 iOS AI 聊天应用 · Swift / SwiftUI · iOS 26 · Apple Liquid Glass 设计语言

一个可扩展的 AI Chat 工具，采用液态玻璃材质。填入自己的 API Key 即可使用，所有对话数据保存在本机，不上架 App Store，个人侧载使用。

## 当前状态

**Phase 0 已完成**：方案 A「曜黑 Glass」UI 骨架 + 数据/网络分层 + GitHub 云编译流水线。开发进行中。

## 特性（V1 规划）

- AI 多轮对话：流式输出、Markdown、代码块、停止/重新生成、复制
- 对话管理：搜索、置顶、重命名、删除、最近使用
- 服务商预设：DeepSeek / OpenAI（兼容协议 + 新一代 Responses API）/ 智谱 / Kimi / Ollama
- 数据私有：对话存 SwiftData（本机），API Key 存 Keychain，支持 JSON 导出
- 液态玻璃 UI：全部使用 Apple 官方系统 API（`glassEffect` / `GlassEffectContainer`），零第三方依赖

## 构建（全程零 Mac）

GitHub Actions 免费云编译 → Windows 上 Sideloadly 签名安装到 iPhone（免费 Apple ID，7 天自动续签）。

1. 推送代码后，仓库 **Actions → Build iOS (unsigned ipa) → Run workflow**
2. 完成后在任务页 Artifacts 下载 `GlassChat.ipa`
3. 用 [Sideloadly](https://sideloadly.io) 通过 USB 安装到 iPhone（详细步骤见 [`docs/PHASE0_CHECKLIST.md`](docs/PHASE0_CHECKLIST.md)）

## 文档

| 文档 | 内容 |
|---|---|
| [`docs/PROJECT_PLAN.md`](docs/PROJECT_PLAN.md) | 完整项目计划（产品定位 / 技术架构 / Milestone Phase 0–10） |
| [`docs/DESIGN_SPEC_A.md`](docs/DESIGN_SPEC_A.md) | 方案 A 视觉契约（色板 / 字号 / 玻璃参数） |
| [`docs/PHASE0_CHECKLIST.md`](docs/PHASE0_CHECKLIST.md) | 云编译 + 真机安装核对表 |
| [`docs/device-testing-guide.md`](docs/device-testing-guide.md) | Windows → iPhone 测试原理与路线 |
| [`design-previews/index.html`](design-previews/index.html) | 4 套 UI 方案预览（浏览器打开） |

## 目录结构

```
GlassChat/            Swift 源码（App / Models / Views / ViewModels / Services / Network / DesignSystem）
design-previews/      UI 设计预览（HTML + PNG）
docs/                 项目文档
project.yml           XcodeGen 工程定义（CI 自动生成 .xcodeproj）
```
