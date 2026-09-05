# Phase 0 核对表 —— 全程零 Mac：GitHub 免费编译 → iPhone 安装

> 方案 A 已选定，源码骨架 + CI 流水线已就位。
> **不需要买任何东西、不需要 Mac**：Xcode 工程由 XcodeGen 在 GitHub 的 macOS 服务器上自动生成并编译打包。
> 前提阅读：`device-testing-guide.md`（免费签名 7 天有效期的原理）。

## 0. 本地核对（Windows，已完成 ✓）

- [x] `GlassChat/` 源码骨架（24 个 Swift 文件，7 层）
- [x] `project.yml`（XcodeGen 工程定义）
- [x] `.github/workflows/build-ios.yml`（云编译流水线）
- [ ] **代码尚未编译过**（Windows 没有 Swift 工具链）——首次云端编译可能报若干小错，属预期流程：把 Actions 里的红色报错文本复制发我，我改完你再点一次运行

## 1. 推到 GitHub（约 5 分钟）

本地 git 仓库已初始化并完成首次提交（见仓库根目录）。接下来：

```bash
# 1. 在 github.com 新建一个【私有】仓库（如 glasschat），不要勾选初始化 README
# 2. 在项目目录执行（替换 <你的用户名>）：
git remote add origin https://github.com/<你的用户名>/glasschat.git
git push -u origin main
```

## 2. 云端编译（约 5–10 分钟/次，免费额度足够）

1. GitHub 仓库页 → **Actions** 标签 → 左侧 **Build iOS (unsigned ipa)** → **Run workflow** → Run
2. 等待变绿 ✓（如果变红 ✗：点进去把最后的报错文本发我）
3. 任务详情页底部 **Artifacts** → 下载 **GlassChat-ipa** → 解压得到 `GlassChat.ipa`

> 免费额度：私有仓库每月 2000 分钟 macOS 时长（单次构建约 8 分钟 ≈ 每月 200+ 次）；公开仓库无限免费。

## 3. 装进你的 iPhone（约 10 分钟，一次性设置）

1. iPhone 用 **数据线** 连接 Windows
2. 安装 [Sideloadly](https://sideloadly.io)（识别不到手机就先装 Microsoft Store 的「Apple Devices」应用，或iTunes）
3. Sideloadly：拖入 `GlassChat.ipa` → 输入你的 Apple ID → **Start**（自动用免费证书签名并安装）
4. iPhone：**设置 → 通用 → VPN 与设备管理 → 信任** 你的开发者证书
5. 桌面出现 **GlassChat** ✓（首次运行会显示深色底 + 「对话/设置」双 Tab 骨架）

## 4. 续签与日常

- 免费 Apple ID 签名 **7 天有效**，到期 App 打不开是正常现象
- 强烈建议改用 **AltStore**（Windows 装 AltServer + iPhone 装 AltStore）：手机和电脑在同一 Wi-Fi 时自动续签，一劳永逸

## 5. 常见报错速查

| 报错 | 处理 |
|---|---|
| Actions 红色，Swift 编译错误 | 复制报错文本发我（预期内，骨架未本地编译过） |
| `iOS 26.0 ... SDK not found` | runner 的 Xcode 太旧：workflow 已自动选最新 Xcode；仍报错则把 `runs-on: macos-15` 改为 `macos-26` 后告诉我 |
| Sideloadly 签名失败 | Apple ID 需开启双重认证；设备已有 3 个自签 App 时先删一个 |
| App 打不开（7 天后） | 重新签名，或换 AltStore 自动续签 |

## 6. 各阶段协作节奏

- **代码**：我在 Windows 上按 Milestone 逐阶段写，你随时 `git add -A && git commit && git push`
- **验证**：每次 push 后去 Actions 点一次 Run，把结果（成功/报错）告诉我
- **调试**：功能调试（断点/模拟器交互）仍需 Mac——可选「云 Mac + ios-simulator 插件」路线（见 `device-testing-guide.md` §4）
