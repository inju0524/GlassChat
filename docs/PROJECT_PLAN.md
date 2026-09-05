# Liquid Glass Chat — 完整项目计划

> 工作代号：**GlassChat**（正式名称待定，可在选定 UI 方案后一起定）
> 版本：v1.1 · 2026-09-05 · 状态：**已选定方案 A「曜黑 Glass」**，Phase 0 骨架已交付
> 配套文件：`design-previews/`（4 套 UI 预览） · `DESIGN_SPEC_A.md`（选定方案视觉契约） · `PHASE0_CHECKLIST.md`（建工程核对表） · `device-testing-guide.md`（真机测试指引）

---

## 第一部分：产品定位

**一句话定位**：一款把「AI 对话」做到 iOS 26 原生质感的轻量聊天 App——填入自己的 API Key 即可使用，所有数据保存在本机。

**三个核心体验支柱**（所有决策都向这三条对齐）：

1. **原生质感**：全面采用 Apple 官方 Liquid Glass 设计语言与系统 API（`glassEffect` / `GlassEffectContainer` / `.buttonStyle(.glass)` 等），不模仿第三方网页玻璃拟态，不做装饰性堆料。
2. **即刻可用**：内置主流服务商预设（DeepSeek / OpenAI / 智谱 / Kimi / Ollama 等），填 Key → 点连接测试 → 开始对话，全程不超过 1 分钟。
3. **数据私有**：对话存本机（SwiftData），API Key 存钥匙串（Keychain），支持一键导出 JSON 备份。无账号体系、无云端依赖。

**明确不做（V1 范围控制）**：
- 不做多用户/社区/分享；
- 不做多模态（图片/语音输入，V2 预留）；
- 不做云同步与跨端（iCloud 同步列为 V2 候选）；
- **不上架 App Store**——个人设备侧载自用（安装路径见 `device-testing-guide.md`）。

**目标用户**：拥有自己 API Key、在意隐私与质感、以中文为主的个人用户与开发者。

---

## 第二部分：UI 设计方向

四套方案共用同一信息架构，差异在**布局结构、组件形态、玻璃使用密度**三个维度，而不是只换颜色。

| | 方案 A · 曜黑 Glass | 方案 B · 原生镜面 | 方案 C · 晨曦 Halo | 方案 D · 素笺 Minimal |
|---|---|---|---|---|
| 基调 | 深色沉浸 | 浅色 · 系统原生 | 浅色 + 极光光晕 | 纸面排版 |
| 布局骨架 | 大标题列表 + 悬浮 Tab Bar + 悬浮玻璃输入栏 | 原生大标题 + inset 列表 + 系统 Tab Bar | 问候语头部 + 悬浮 Tab Bar（中央凸起 FAB） | 纯排版列表 + **无 Tab Bar**（push 导航） |
| 消息形态 | AI 无气泡直排 / 用户玻璃胶囊 | iMessage 式双色气泡 | AI 白玻璃卡片 + 渐变 orb / 用户 tinted 玻璃气泡 | AI 文档流直排 / 用户浅灰缩进块 |
| 玻璃密度 | 高（一切悬浮物皆玻璃） | 低（仅系统栏位） | 中高（统一白玻璃 + 渐变点缀） | 极低（仅导航栏 + 输入栏） |
| 状态演示重点 | 生成失败 + 重试 | 发送失败（系统式） | 无网络横幅 + Token 用量 | 流式直排 + 文字操作 |

每套方案的完整设计理念、优缺点、适合人群写在各自预览页顶部，此处不重复。

---

## 第三部分：UI 预览图

**打开方式**：双击任一 HTML 用浏览器查看（推荐 Chrome/Edge，玻璃模糊为实时渲染）；`screenshots/` 内是每屏的 PNG 导出图。

| 文件 | 内容 |
|---|---|
| `design-previews/index.html` | **总览对比页（建议先看）**：四方案速览 + 六维对比表 + 全部 16 张截图索引 |
| `design-previews/scheme-a-dark.html` | 方案 A · 曜黑 Glass —— 4 屏 |
| `design-previews/scheme-b-native.html` | 方案 B · 原生镜面 —— 4 屏 |
| `design-previews/scheme-c-halo.html` | 方案 C · 晨曦 Halo —— 4 屏 |
| `design-previews/scheme-d-minimal.html` | 方案 D · 素笺 Minimal —— 4 屏 |

每套均包含：**① 对话列表页 ② AI 对话页（含流式输出/错误/无网络等状态）③ 设置页 ④ 空状态·新建对话页**。
预览中刻意演示的 UI 状态：流式输出光标、停止生成、生成失败重试（A）、发送未送达（B）、无网络横幅（C）、Token 用量（C）、复制/重新生成（D）、空状态、搜索入口、删除/重命名入口。

说明：HTML 为高保真方向稿。实际 SwiftUI 的玻璃质感（实时折射、动态高光、系统材质）会优于网页模拟；开发阶段以选定方案为「视觉基准」，逐屏比对。

---

## 第四部分：方案对比

| 维度 | A 曜黑 Glass | B 原生镜面 | C 晨曦 Halo | D 素笺 Minimal |
|---|---|---|---|---|
| 视觉效果 | ★★★★★ 惊艳、沉浸 | ★★★★ 精致耐看 | ★★★★★ 有记忆点 | ★★★ 淡雅 |
| 原生 iOS 感 | ★★★☆ | ★★★★★ | ★★★☆ | ★★★★ |
| 开发难度（星少=易） | ★★★（自定义组件较多） | ★（全系统组件） | ★★★★（渐变+玻璃平衡需调校） | ★★（排版为主） |
| 性能风险 | 低-中（多层 blur） | 最低 | 中（光晕需节制） | 最低 |
| 长时间使用舒适度 | ★★★★（夜间佳） | ★★★★★ | ★★★☆（视觉信息略多） | ★★★★★（阅读最佳） |
| 产品辨识度 | ★★★★ | ★★ | ★★★★★ | ★★★ |

**我的推荐（不替你做最终决定）**：

- **首选推荐：B（原生镜面）为基座，吸收 D 的一个特性**——提供一个「气泡 / 直排」显示开关（设置里切换），AI 长回答用 D 式直排更易读。理由：你是 iOS 初学者、开发环境受限（无法每天在真机上调），B 的全部界面由系统组件搭建，出错面最小、维护最省，且最符合你「接近 Apple 原生」的要求；加一个显示开关的成本约多半天。
- **如果你想第一眼就惊艳**：选 C（辨识度最高，但需要接受更多视觉调校工作）。
- **如果你主要在夜间使用**：选 A（深色玻璃氛围最好，开发量中等）。

选定后我不会再擅自改动已确认的设计；若开发中发现某设计在真机上不可行，会先说明问题与替代方案，经你确认后再改。

---

## 第五部分：完整项目计划（产品设计侧）

> 本部分回答：页面结构、导航关系、用户流程、Liquid Glass 组件映射、动画清单。
> 技术实现细节在第六部分，目录在第七部分，阶段拆解在第八部分。

### 5.1 产品架构（页面与导航关系）

```
RootTabView（A/B/C：Tab 结构；D：无 Tab，列表为根视图）
├── 对话 Tab
│   ├── ConversationListView  对话列表
│   │     ├── 搜索（.searchable）
│   │     ├── 滑动/长按操作：置顶、重命名、删除（确认弹窗）
│   │     └── push ▶ ChatView  对话页
│   │           ├── 流式输出 / 停止生成 / 重新生成 / 复制
│   │           ├── 长按消息：复制、重新生成、删除
│   │           ├── 模型切换 Sheet（detents）
│   │           └── 空状态（新建对话 = 一个无消息的 ChatView）
│   └── 新建对话（+ 按钮 → 直接 push 空的 ChatView，首条消息发出后自动命名）
└── 设置 Tab
      ├── API 服务：提供商 / Endpoint / API Key（Keychain）/ 默认模型 / 连接测试
      ├── 外观：主题（跟随系统/浅/深）、玻璃效果开关、（C：光晕开关）（D：夜间纸张色）
      ├── 数据：记录统计 / 导出备份 / 清除全部（双重确认）
      └── 关于：版本 / 隐私政策
```

导航规则：列表 ↔ 详情用 `NavigationStack` push（系统转场）；设置子页 push；模型选择/新建面板用 Sheet；所有破坏性操作（删除对话、清除全部）走系统 `confirmationDialog`/`alert`。

### 5.2 首启与主流程

1. **首次启动**：检测到无 API Key → 全屏引导 Sheet（选择服务商 → 填 Key → 连接测试 → 完成），也提供「先随便看看（本地 Echo 演示模式）」入口。
2. **日常主流程**：打开 App → 列表（或上次对话）→ 进入对话 → 输入 → 流式回答 → 返回。核心路径永远 ≤ 2 步。
3. **空状态**：列表空 → 展示欢迎 + 建议问题；对话页空 → 问候语 + 建议胶囊（点击即填入输入框）。

### 5.3 UI 状态清单（V1 必须全部覆盖）

| 状态 | 表现 | 演示屏 |
|---|---|---|
| 首次启动 | 引导 Sheet（配置向导） | 未入预览，实现于 Phase 4 |
| 列表空 | 欢迎语 + 建议问题 | 各方案 ④ |
| 正在生成 | 呼吸光标 + 停止按钮 + 状态小字 | A/B/C ② |
| 流式输出 | 文本渐进追加 + 自动滚动 | 各方案 ② |
| 生成失败 | 错误卡片 + 重试按钮 | A ② |
| 发送失败 | 未送达标记 + 点按重试 | B ② |
| 无网络 | 顶部横幅（NWPathMonitor） | C ② |
| API 错误（401/429/5xx） | 可读文案 + 跳转设置引导 | Phase 8 |
| 加载 | 历史消息载入骨架（克制） | Phase 3 |
| 删除确认 | 系统 confirmationDialog | 全部 |
| 搜索 | .searchable 展开态 | 各方案 ① |

### 5.4 Liquid Glass UI 实现方案（应该 / 不应该）

**原则：玻璃是「窗框」不是「窗户」——只用于悬浮于内容之上的控件层；内容主体（文本、列表、代码块）一律普通材质，保证可读性与性能。**

| 组件 | 是否玻璃 | 设计 |
|---|---|---|
| 导航栏 | 系统 | `NavigationStack` 原生 scroll edge effect（内容滚过时自动玻璃浮现），不自绘背景 |
| Tab Bar | 系统 | 原生玻璃；列表页开 `.tabBarMinimizeBehavior(.onScrollDown)`（C 方案含中央 FAB，用 `GlassEffectContainer` + `glassEffectID` 与新建面板 morph） |
| Floating Button | 玻璃 | `.glassEffect()` 圆形；按下 scale 0.96 + spring |
| 输入栏 | 玻璃 | 自定义 `GlassInputBar`：`.glassEffect(in: .capsule)`；发送键 `.buttonStyle(.glassProminent)`；**生成中发送键 morph 为停止键**（`glassEffectID`） |
| 键盘工具条 | 玻璃 | 生成中显示「停止」，系统 `ToolbarItemGroup(placement: .keyboard)` |
| Sheet | 系统 | `presentationDetents([.medium, .large])`，iOS 26 Sheet 自带玻璃抓取区，内部内容普通材质 |
| Card（列表行/分组） | **不用** | 普通材质（系统 List 或纯色+描边），保证滚动性能与可读性 |
| Context Menu | 系统 | `.contextMenu` 原生（iOS 26 自动玻璃化） |
| Alert / 确认 | 系统 | `.alert` / `.confirmationDialog` 原生，不自定义 |
| 消息气泡 | 半透明 ≠ 玻璃 | 用户气泡可用 tint 材质（B/C），**AI 正文永不放玻璃上** |
| 代码块 | **不用** | 实色深底 + 圆角，保证语法色对比度 |

### 5.5 动画与交互清单（自然、克制、可关）

| 变化 | 动画 | 实现 |
|---|---|---|
| 页面 push/pop / Tab 切换 / Sheet | 系统默认 | 不干预 |
| 新建对话 → 列表出现新行 | 行插入动画 | `withAnimation(.snappy)` |
| 新消息出现 | 淡入 + 轻微上移 | `transition(.opacity.combined(with: .move(edge: .bottom)))`，仅新消息 |
| 流式输出 | 文本追加 + 视图钉底 | `ScrollViewReader` onChange 平滑到底（`.smooth`）；光标 opacity 闪烁 |
| 发送键 ↔ 停止键 | 玻璃 morph | `GlassEffectContainer` + `glassEffectID` |
| 输入框高度变化（多行） | 高度过渡 | `animation(.snappy, value: textHeight)` |
| 键盘 | 系统默认 | 不干预 |
| 删除对话 | 行左滑 + 确认 + 移除动画 | `swipeActions` + `withAnimation` |
| 搜索展开 | 系统 `.searchable` | 附 `.searchToolbarBehavior(.minimize)` |
| 加载状态 | 克制呼吸 | opacity 脉冲（`TimelineView`），不用大骨架屏 |
| 错误出现/消失 | 缩放+淡入 | `transition(.scale(0.96).combined(with: .opacity))` |
| 内容高度变化（错误条、横幅） | 高度过渡 | `animation(value:)` |

全局原则：时长 0.2–0.35s；优先 spring(.snappy)；**尊重「减弱动态效果」**（`@Environment(\.accessibilityReduceMotion)` 时全部降级为淡入淡出）；除了流式光标外没有任何循环动画。

---

## 第六部分：技术架构

### 6.1 总体

- **Xcode 26 / Swift 6 工具链 / SwiftUI / iOS 26.0 部署目标**；采用 Xcode 26 新模板默认的 Approachable Concurrency（默认 MainActor 隔离），对初学者最友好。
- **架构**：MVVM + `@Observable`（Observation 框架）。`View → ViewModel → Service → (Network / Store)`，单向依赖，禁止 View 直接触碰网络与数据库。
- **状态管理**：页面级 ViewModel（`@Observable`）；列表用 SwiftData `@Query` 直接驱动；跨页服务通过 `Environment` 注入的 `AppContainer`。
- **依赖**：**零第三方库**（全部 Apple SDK）。若后续 Markdown 渲染需要更强能力，再评估 `swift-markdown-ui`（SPM），默认自研轻量渲染。

### 6.2 AI Chat 架构

**数据模型（内存/持久化共用）**
- `Conversation`：id、title、createdAt、updatedAt、isPinned、providerID、modelID
- `Message`：id、role（user/assistant/system）、content、status（`streaming / finished / stopped / failed`）、createdAt、usage?、errorText?
- `TokenUsage`：promptTokens、completionTokens、costEstimate?

**Provider 抽象（本次确认：OpenAI 兼容协议为主，同时支持 OpenAI 新一代 Responses API）**

```swift
protocol AIProvider {
    var id: String { get }                     // "deepseek" / "openai" / ...
    func stream(_ request: ChatRequest) -> AsyncThrowingStream<ChatEvent, Error>
}

enum ChatEvent {
    case delta(String)                         // 增量文本
    case usage(TokenUsage)                     // usage 统计
    case finished(reason: String?)             // 结束原因
}
```

两个实现，共用同一套 SSE 解析与错误映射：
- `OpenAIChatProvider` — `POST {endpoint}/chat/completions`（`stream: true`）。SSE 行：`data: {"choices":[{"delta":{"content":"..."}}]}`，`data: [DONE]` 结束。兼容 DeepSeek / Kimi / 智谱 / OpenRouter / Ollama。
- `OpenAIResponsesProvider` — `POST {endpoint}/responses`（`stream: true`）。事件流：`response.output_text.delta`（增量）、`response.completed`（含 usage）。用于 OpenAI 新一代 API 与推理模型。

**流式管道**：`URLSession.bytes(for:)` → `AsyncLineSequence` → `SSEDecoder`（处理半包/粘包、跨 chunk 事件）→ `AsyncThrowingStream<ChatEvent>` → ViewModel 逐 delta 追加。

**取消（停止生成）**：ViewModel 持有生成 `Task`；点停止 → `task.cancel()` → 底层流抛 `CancellationError` → 状态置 `.stopped`，**已生成文本保留**。

**错误映射 `ChatError`**：`offline（无网络）/ timeout / unauthorized（401，引导去设置）/ rateLimited（429）/ server（5xx）/ decoding / cancelled`；每个错误带用户可读中文文案 + 是否可重试。**重试策略：V1 仅手动**（重试按钮/重新生成），不做自动指数退避——理由：流式场景下自动重试会造成重复扣费与重复文本，手动语义更清晰。

**Token / usage**：从响应 `usage` 字段解析（chat.completions：`prompt_tokens/completion_tokens`；responses：`input_tokens/output_tokens`），写入 `Message.usage`，会话页累计展示（C 方案在每条消息下展示胶囊，其余方案放消息详情）。

### 6.3 数据存储

| 数据 | 存储 | 为什么 |
|---|---|---|
| 对话 / 消息 | **SwiftData** | 关系建模 + 级联删除 + `@Query` 驱动列表；系统原生，无需第三方 |
| **API Key（敏感）** | **Keychain** | 系统级加密存储；UserDefaults/数据库是明文，可被备份与提取，**绝不放 UserDefaults** |
| Endpoint / 模型 / 主题 / 字号 / 玻璃开关 | **UserDefaults（@AppStorage）** | 非敏感、小体量、键值型 |
| 导出备份 | **文件（JSON）+ ShareLink** | 用户可控的迁移/备份方式 |

SwiftData 要点：`Conversation.messages` 用 `@Relationship(deleteRule: .cascade)`；列表按 `isPinned desc, updatedAt desc` 排序；标题自动生成取首条用户消息前 20 字。

---

## 第七部分：目录结构

```
GlassChat/
├── App/                          # 应用入口与根视图
│   ├── GlassChatApp.swift        #   @main；SwiftData container + AppContainer 注入
│   └── RootTabView.swift         #   Tab 骨架（或 D 方案的 NavigationStack 根）
├── Models/                       # 纯数据模型（无逻辑）
│   ├── Conversation.swift        #   @Model 对话
│   ├── Message.swift             #   @Model 消息
│   ├── ChatModels.swift          #   Role/MessageStatus/TokenUsage/ChatRequest
│   └── ProviderPreset.swift      #   服务商预设（endpoint/默认模型）
├── ViewModels/                   # @Observable 页面状态机
│   ├── ConversationListViewModel.swift
│   ├── ChatViewModel.swift       #   生成任务/流式追加/停止/重试
│   └── SettingsViewModel.swift
├── Views/
│   ├── Conversations/            # 列表页、行视图、空状态、重命名弹窗
│   ├── Chat/                     # 聊天页、GlassInputBar、MessageView、
│   │                             #   MarkdownView、CodeBlockView、StopButton
│   ├── Settings/                 # 设置主页 + API 配置/模型选择/关于
│   └── Components/               # ErrorBanner、SuggestionChip、GlassCapsuleButton…
├── Services/                     # 无 UI 的系统能力封装
│   ├── KeychainService.swift     #   API Key 存取（唯一入口）
│   ├── SettingsStore.swift       #   @AppStorage 包装
│   ├── ConversationStore.swift   #   SwiftData 读写
│   └── NetworkMonitor.swift      #   NWPathMonitor 无网络监测
├── Network/                      # AI 供应商层
│   ├── AIProvider.swift          #   协议 + ChatEvent
│   ├── OpenAIChatProvider.swift  #   chat/completions + SSE
│   ├── OpenAIResponsesProvider.swift
│   ├── SSEDecoder.swift          #   SSE 行解析（含半包处理）
│   ├── ChatError.swift           #   错误枚举 + 文案映射
│   └── EchoProvider.swift        #   本地假 AI（无 Key 演示/开发用）
└── Resources/
    ├── Assets.xcassets           # 图标/颜色/图片
    └── Localizable.xcstrings     # 中文为主，预留英文
```

命名规约：一个文件一个主类型；`View`/`ViewModel` 后缀；Model 层禁止 import SwiftUI；每层只能调用相邻下层。

---

## 第八部分：开发 Milestone（Phase 0–10）

> 每阶段结束都有「可运行验证点」。估时按业余节奏（每天 1–2 小时）。

| Phase | 目标 | 主要交付 | 验收标准 | 可能的问题 |
|---|---|---|---|---|
| **0 初始化** (0.5d) | 工程能跑 | Xcode 26 建工程（iOS 26.0/Swift 6/SwiftUI）、Git 初始化、目录骨架 | 模拟器显示 App 名 | Windows 无 Xcode：先写代码，首次构建用云 Mac（见测试指引） |
| **1 基础架构** (1–2d) | 骨架与主题 | Models、AppContainer、SettingsStore、KeychainService、AppTheme（浅/深色板） | 编译通过；深浅色切换生效 | SwiftData 容器初始化时机 |
| **2 UI Shell** (2–3d) | 静态界面骨架 | 列表页/聊天页/设置页静态版（假数据、#Preview） | 能在页面间导航，与选定预览对齐 | 对 iOS 26 新 API 不熟，边做边查 |
| **3 对话系统** (3–4d) | 全流程可交互 | 输入栏、消息渲染（Markdown/代码块）、EchoProvider（本地假流式）、会话 CRUD/搜索/置顶 | **不联网**即可完成完整对话体验（Echo 模式） | Markdown 渲染范围控制（先标题/粗体/列表/代码） |
| **4 AI API** (2d) | 真 Key 能回复 | 设置页 API 配置、OpenAIChatProvider（先非流式）、错误映射、连接测试 | 填入真实 Key 拿到一条完整回复；401/无网各有正确文案 | 各家 endpoint/鉴权差异；中文字符转义 |
| **5 流式输出** (3–4d) | 逐字显示 | SSEDecoder、流式接入 UI、自动滚动、停止生成、重新生成、ResponsesProvider | 真流式逐字；停止即时生效且保留已生成文本 | SSE 半包/粘包；弱网中断处理 |
| **6 持久化** (2d) | 数据不丢 | SwiftData 接入真实读写、启动恢复、usage 统计、导出 JSON | 杀 App 重开数据完整；导出文件可再导入 | @Model 与 ViewModel 的转换边界 |
| **7 玻璃与动效** (3d) | 视觉达标 | 按选定方案落地 glassEffect/morph/tabBarMinimize、全部动效清单、深浅色双检 | 与预览稿逐屏比对通过 | 过度玻璃导致可读性/性能问题——对照第五部分约束 |
| **8 错误处理** (2d) | 任何失败都好看 | 无网络横幅、401 引导、429/5xx 文案、失败重试全覆盖 | 每类错误可手工复现并正确展示 | NWPathMonitor 误报；超时阈值调优 |
| **9 测试** (2d) | 可回归 | SSEDecoder/ChatError/ChatViewModel 单测；手动回归清单 | XcodeTest 全绿 + 清单通过 | 云 Mac 上跑测试的流程成本 |
| **10 发布准备** (1d) | 稳定自用包 | 图标/名称、隐私说明、本地化检查、出 ipa + AltStore 安装 | 真机安装稳定可用 | 签名 7 天续签习惯养成 |

**合计约 3–5 周**（业余节奏）。关键路径是 Phase 3→5（对话系统 → 真 API → 流式），这三步打通后产品即「可用」。

---

## 第九部分：第一阶段任务（现在要做的事）

**只做一件事：从 4 套预览中选定一套。**

1. 双击打开 `design-previews/index.html`（总览对比）→ 逐个打开 A/B/C/D 四个页面；
2. 回复我你的选择，例如「选 B，但气泡改成 D 的直排」或「选 C，光晕弱一点」——**允许任何组合与修改意见**；
3. 我收到选择后立即启动 **Phase 0**：输出选定方案的《设计规范》（色板/字号/间距/玻璃参数）+ 项目源码骨架（Phase 1 目录与空实现）+ 云 Mac 构建/AltStore 安装清单核对表。

在你选定之前，我不会开始写任何 App 代码。
