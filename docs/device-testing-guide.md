# Windows → iPhone 真机测试指引

> 结论：**可以**在你自己的 iPhone 上安装测试，不需要上架、不需要 $99 开发者账号；但**编译必须在 macOS 上完成**（Xcode 只发布 macOS 版，这是 Apple 的硬性限制，无法绕过）。
> 本文档给出一条被大量独立开发者验证过的低成本路径。

---

## 1. 三个基本事实

1. **Xcode 只能在 macOS 上运行**。Swift 语言本身可以装在 Windows 上，但 iOS SDK、模拟器、代码签名、SwiftUI 运行时全部只在 macOS 的 Xcode 里。所以：代码可以在 Windows 写，**构建必须在 macOS**。
2. **免费 Apple ID 就能自签安装到自己的设备**。限制：签名有效期 **7 天**（到期重新签一次即可）、同时最多 3 个自签 App、不能使用部分系统能力（本 App 都用不到）。**不需要付费开发者账号。**
3. **你的 iPhone 不需要越狱**，也不需要在 App Store 出现。

## 2. 总体路线

```
┌ Windows（你现在）        ┌ macOS（按需借用）           ┌ iPhone（你手上）
│ 写 Swift 代码             │ Xcode 构建 .app/.ipa         │ Sideloadly/AltStore
│ Git 管理代码      ──────▶ │ 或 GitHub Actions 云构建 ──▶ │ 用免费 Apple ID
│ 写文档/预览               │ （模拟器调试也在这里）        │ USB 签名安装（7 天）
└──────────────────┘       └─────────────────────┘       └──────────────┘
```

macOS 的三种获取方式（按推荐排序）：

| 方式 | 成本 | 适合 |
|---|---|---|
| **GitHub Actions macOS runner** | 免费额度（公共仓库无限；私有仓库每月 2000 分钟） | 只要「能编译出 ipa」，不需要交互式调试 |
| **按小时租云 Mac**（MacStadium 约 $1/小时；MacinCloud 月付托管约 $20/月） | 低 | 需要 Xcode 图形界面、模拟器调试 |
| 朋友/家人的 Mac 借用几小时 | 免费 | 偶尔构建 |

## 3. 路线一（推荐）：GitHub Actions 自动出包 + Sideloadly 安装

### 3.1 云端构建（GitHub Actions）—— 全程零 Mac

`.github/workflows/build-ios.yml` 已就位：在 GitHub 的 macOS 服务器上**自动安装 XcodeGen 并按 `project.yml` 生成 Xcode 工程**（无需任何手工建工程步骤），编译打包出未签名 ipa。你只需要：push 代码 → Actions 页点一次 **Run workflow** → 下载 artifact 里的 `GlassChat.ipa`。

> 免费额度：私有仓库每月 2000 分钟 macOS 时长（单次约 8 分钟）；公开仓库无限。构建结果只有两种：绿色 ✓ 下载 ipa，红色 ✗ 把报错文本发给开发者修。

### 3.2 Windows 端签名并安装（Sideloadly）

1. iPhone 用 **USB 线**连接 Windows 电脑；
2. 安装 [Sideloadly](https://sideloadly.io)（如识别不到手机，先装 Apple 官方「Apple Devices」应用或旧版 iTunes 以获取 USB 驱动）；
3. Sideloadly 中：拖入 `GlassChat.ipa` → 输入你的 Apple ID → 点 Start（会自动用免费证书签名并安装）；
4. iPhone 上：**设置 → 通用 → VPN 与设备管理 → 信任你的开发者证书**；
5. 完成，App 出现在桌面。

### 3.3 续签（7 天一次）

- 手动：USB 连电脑重跑一次 Sideloadly（数据不会丢）；
- 自动（推荐）：改用 **AltStore**（Windows 端装 AltServer，iPhone 端装 AltStore），手机和电脑在同一 Wi-Fi 时会自动续签，可完全忘记这件事。

## 4. 路线二：云 Mac 交互式调试

何时需要：进入 Phase 4（接真实 API）之后，模拟器调试效率远高于「改代码 → 云构建 → 装真机」循环。

1. 租用 MacStadium / MacinCloud，远程桌面进入 macOS；
2. App Store 登录你的 Apple ID，安装 Xcode（约 12 GB，第一次要等一会）；
3. 上传代码（Git 推送到 GitHub，云端 pull 即可）；
4. 选 **iPhone 16 Pro 模拟器**运行 —— 模拟器可以访问真实网络，**流式 API 调试完全可用**；
5. UI 迭代阶段用模拟器截图核对设计，功能稳定后再走路线一装到真机日常使用。

> 说明：云 Mac 无法 USB 连接你的 iPhone，所以真机断点调试（lldb）不可用——这是此路线唯一的功能损失。本项目以「模拟器调试 + 真机使用验证」的组合完全可以推进。

## 5. 阶段化建议（花最少的钱）

| 项目阶段 | 环境需求 |
|---|---|
| Phase 0–3（架构/界面/对话系统） | 纯 Windows 写代码 + EchoProvider 自测；可零成本 |
| Phase 4–5（真 API / 流式） | 云构建出包装真机验证；或租 1–2 小时云 Mac 调试 |
| Phase 6–10（打磨/发布） | 每个里程碑云构建一次 + 真机体验；必要时段性租云 Mac |

## 6. 常见问题

- **免费证书报错 `profil provision failed`**：Apple ID 未开启双重认证（需开启）、或设备已装 3 个自签 App（删一个）。
- **Sideloadly 识别不到手机**：装 Apple Devices 应用/iTunes 驱动；换数据线（必须数据线不能是纯充电线）。
- **7 天后 App 打不开**：正常，重新签名安装；换 AltStore 自动续签。
- **想 1 年有效签名 / TestFlight**：升级 ¥688/年 开发者账号，可在开发者门户注册设备 UDID 后远程签名，有效期 1 年；本项目 V1 没必要。
- **爱思助手可以吗**：可以替代 Sideloadly 做自签安装（原理相同），按个人习惯选择。

## 7. Windows 写 Swift 的体验说明（提前有预期）

- VS Code + Swift 扩展可提供语法高亮与基础提示，但**没有完整的 SwiftUI 补全和编译**；
- 因此工作流是：Windows 写代码 → 云构建收集报错 → 回来修复。初学阶段报错会偏多，这是此环境的固有摩擦，计划里的「每阶段可运行验证」就是为控制这种摩擦设计的；
- 若后续觉得效率不够，随时可以把日常开发迁到月付云 Mac（MacinCloud 托管版）。
