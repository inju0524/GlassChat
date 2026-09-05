# 方案 A「曜黑 Glass」设计规范 v1.0

> 状态：**已确认（2026-09-05，用户选定）**。本文件是视觉契约：开发阶段的玻璃与暗色实现以此为准；
> 网页预览（scheme-a-dark.html）是参照稿。后续修改必须先更新本文件再改代码。
> 配套：`PROJECT_PLAN.md` · 真机指引 `device-testing-guide.md`

---

## 1. 设计原则（方案 A 的三条铁律）

1. **玻璃只给悬浮层**：导航栏、Tab Bar、输入栏、悬浮按钮、菜单 = Liquid Glass；内容主体（列表卡片、正文、代码块）= 普通半透明材质/实色，保证可读性与滚动性能。
2. **深色为默认体验**：A 方案深色优先设计；浅色模式作为"跟随系统"的适配（见 §7），不是主视觉。
3. **唯一的彩色实心元素是发送键**；其余彩色只以 tint、状态色出现。

## 2. 色板（Dark · 默认）

| Token | 值 | 用途 |
|---|---|---|
| `bg` | `#0A0B10` + 顶部蓝紫辉光（radial, 8%~13% 不透明度） | 页面背景 |
| `textPrimary` | `#ECEEF4` | 主文字 |
| `textSecondary` | `#9AA0B0` | 次要文字（预览、值） |
| `textTertiary` | `#62687A` | 时间戳、分组标题、占位 |
| `surfaceCard` | 白 5.5% + 描边白 8%（列表卡片，**非玻璃**） | 对话列表卡片 |
| `glass` | 渐变 rgba(40,44,62,.58)→rgba(20,22,33,.42)，blur 26 / saturate 1.5，描边白 10%，顶部内高光白 13% | 所有悬浮玻璃控件 |
| `accent` | `#6EA3FF`（浅色文字/图标态 `#A9C6FF`） | 强调、未读点、链接 |
| `accentFill` | 渐变 `#4F86FF → #3B5FD9` + 顶部内高光 | **发送键**（唯一实心彩） |
| `userBubble` | 渐变 rgba(88,120,220,.42)→rgba(52,66,140,.30)，描边 rgba(142,172,255,.30)，blur 18 | 用户消息胶囊 |
| `success` | `#7FD8AB` | 已送达、已配置 |
| `danger` | `#E5484D` 底 10% / 文字 `#FF8A8E` / 描边 32% | 错误卡、清除类操作 |
| `codeBg` | `#12141D`（实色）+ 描边白 8%，头部条白 4.5% | 代码块 |
| 语法色 | 关键字 `#FF7AB2` · 类型 `#7CC7FF` · 函数 `#63D8C4` · 数字 `#FFC48A` · 注释 `#667083` | 代码高亮 |

## 3. 字号（SF Pro / PingFang SC）

| 场景 | 字号/字重 |
|---|---|
| 大标题（对话/设置） | 33–34 / Bold 800 |
| 页面标题（聊天导航） | 16.5–17 / Semibold |
| 列表条目标题 | 15 / Semibold 600 |
| 正文（AI 回复） | 14.6 / Regular，行高 1.7 |
| 用户消息 | 15 / Regular，行高 1.55 |
| 预览/次要 | 12.8 / Regular |
| 时间戳/分组标题 | 11.5–12.5 / Medium，字距 +0.8 |
| Tab 标签 | 10.5 / Medium |
| 代码 | 12.3 / Mono（SF Mono / ui-monospace），行高 1.75 |

## 4. 间距与圆角

- 屏幕左右边距 **16**；卡片内边距 12–13；卡片间距 8；分组标题上 20 下 8。
- 圆角：对话卡片 **20** · 用户气泡 20（右下角收为 7）· 输入胶囊/Tab Bar **999（胶囊）** · 圆形按钮 38–40 · 错误卡 16 · 代码块 14。
- 悬浮 Tab Bar：宽 236 × 高 60，距底 32；输入栏距底 46（聊天页，无 Tab Bar 时）。
- 状态栏高度 58，大标题区顶边距 74。

## 5. Liquid Glass 组件映射（SwiftUI）

| 组件 | 实现 |
|---|---|
| 聊天页导航栏 | `NavigationStack` 原生栏 + `.glassEffect()`（系统 scroll edge effect 自动浮现） |
| 悬浮 Tab Bar | 自定义胶囊 + `.glassEffect(in: .capsule)`；列表页可用 `.tabBarMinimizeBehavior(.onScrollDown)` |
| 玻璃搜索胶囊 | `.glassEffect()` + `magnifyingglass` |
| 列表卡片 | **不用玻璃**：`surfaceCard` 半透明材质 |
| 用户气泡 | tinted glass：`.glassEffect(.regular.tint(.blue.opacity(0.3)))` 近似，参数 Phase 7 真机校准 |
| AI 回复 | 无气泡直排文字（普通渲染） |
| 输入栏 | 玻璃胶囊容器；发送键 `.buttonStyle(.glassProminent)` 或渐变填充 |
| 发送↔停止 | `GlassEffectContainer` + `glassEffectID` morph |
| 模型切换 Chip / 停止胶囊 | 小号玻璃胶囊 |
| 长按菜单 / 删除确认 | 系统 `.contextMenu` / `.confirmationDialog`（iOS 26 自动玻璃化） |

> 诚实说明：网页预览中的玻璃参数是模拟值；真机由系统材质渲染为准，Phase 7 对照校准的是 tint 与层次，不逐像素抠。

## 6. 图标（全部 SF Symbols）

`chevron.left`（返回）· `plus`（新建）· `magnifyingglass`（搜索）· `ellipsis`（更多）· `gearshape`（设置）· `bubble.left.and.bubble.right`（对话 Tab）· `arrow.up`（发送）· `stop.fill`（停止）· `doc.on.doc`（复制）· `sparkles`（AI/空状态）· `pin`（置顶）· `checkmark`（送达/已配置）· `exclamationmark.triangle`（错误）· `key`（API Key）· `paintpalette`（外观）· `cylinder`（数据）· `square.and.arrow.up`（导出）· `trash`（清除）

## 7. 浅色模式适配（跟随系统时的对照）

| Token | Dark（默认） | Light 适配 |
|---|---|---|
| bg | `#0A0B10` | `#EEF0F5` + 冷灰辉光 |
| 文字三级 | 白系（见 §2） | `#17181D` / `#5C6270` / `#8A8F9C` |
| surfaceCard | 白 5.5% | 白 78% + 描边黑 6% |
| glass | 深玻璃 | 系统 `.regular` 玻璃原样（白玻璃） |
| userBubble / accentFill / danger | 同左 | 同左（彩色元素两版一致） |
| codeBg | `#12141D` | 不变（代码块恒为深色） |

## 8. 动效

- 全局 `spring(.snappy)`（≈0.3s）；页面切换/键盘/Sheet 用系统默认，不自定义。
- 流式输出：文本追加 + 平滑钉底；光标为 accent 竖线 1s 闪烁。
- 发送↔停止：`glassEffectID` morph；新消息：opacity + 轻微上移；错误条：scale 0.96 + fade。
- `accessibilityReduceMotion` 时全部降级为淡入淡出。

## 9. 文案基调

冷静、简短、可执行；按钮用动词（重试/停止生成/清除全部对话）；错误信息 = 状态 + 用户该做什么（"生成失败 · 网络连接中断 / 重试"）。API Key 永远只显示尾 4 位。
