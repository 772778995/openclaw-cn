---
summary: "安全更新 Openclaw（全局安装或源码），以及回滚策略"
read_when:
  - 更新 Openclaw
  - 更新后出现问题
---

# 更新 Openclaw

本文档帮助你将 Openclaw 更新到最新版本，并在遇到问题时进行排查。

## 一分钟快速更新

**大多数用户只需要这一个命令：**

**Linux / macOS：**
```bash
npm i -g openclaw-cn@latest && openclaw-cn doctor && openclaw-cn gateway restart
```

**Windows（PowerShell）：**
```powershell
npm i -g openclaw-cn@latest; openclaw-cn doctor; openclaw-cn gateway restart
```

这会：更新到最新版本 → 运行诊断修复 → 重启 Gateway。

## 逐步更新指南

### 第一步：检查当前版本

```bash
openclaw-cn --version
```

### 第二步：更新 Openclaw

**方法 A：使用安装脚本（推荐）**

```bash
curl -fsSL https://clawd.org.cn/install.sh | bash -s -- --no-onboard
```

添加 `--no-onboard` 跳过引导向导（你已经配置过了）。

**方法 B：使用 npm 直接更新**

```bash
npm i -g openclaw-cn@latest
```

**方法 C：使用淘宝镜像源更新（国内推荐）**

如果 npm 官方源较慢，可以使用淘宝镜像：

```bash
npm i -g openclaw-cn@latest --registry=https://registry.npmmirror.com
```

或者永久设置淘宝源后再更新：

```bash
npm config set registry https://registry.npmmirror.com
npm i -g openclaw-cn@latest
```

**方法 D：安装测试版本**

如果你想测试预发布版本：

```bash
npm i -g openclaw-cn@test
# 或指定具体版本
npm i -g openclaw-cn@2026.2.2-test.0
```

### 第三步：运行诊断

更新后**必须**运行 doctor 命令：

```bash
openclaw-cn doctor
```

Doctor 会自动：
- 迁移旧配置到新格式
- 检查并修复常见问题
- 验证 Gateway 健康状态

### 第四步：重启 Gateway

```bash
openclaw-cn gateway restart
```

### 第五步：验证更新

```bash
openclaw-cn status
```

## 更新后问题排查

### 常用诊断命令

| 命令 | 用途 |
|------|------|
| `openclaw-cn status` | 查看整体状态概览 |
| `openclaw-cn status --all` | 完整诊断报告（可粘贴分享） |
| `openclaw-cn doctor` | 自动检测并修复问题 |
| `openclaw-cn logs --follow` | 实时查看日志 |
| `openclaw-cn channels status` | 查看消息通道状态 |
| `openclaw-cn models status` | 查看 AI 模型认证状态 |

### 问题 1：Gateway 无法启动

**症状**：运行 `openclaw-cn gateway restart` 后无响应

**排查步骤**：

```bash
# 1. 查看 Gateway 状态
openclaw-cn gateway status

# 2. 查看详细日志
openclaw-cn logs --follow

# 3. 尝试重新安装服务
openclaw-cn gateway install
openclaw-cn gateway restart
```

### 问题 2：消息通道断开

**症状**：Telegram/微信/飞书等通道无法收发消息

**排查步骤**：

```bash
# 1. 查看通道状态
openclaw-cn channels status --probe

# 2. 重启 Gateway
openclaw-cn gateway restart

# 3. 如果问题持续，检查日志
openclaw-cn logs --follow
```

### 问题 3：API 认证失效

**症状**：提示"未找到提供者的 API 密钥"

**排查步骤**：

```bash
# 1. 查看当前认证状态
openclaw-cn models status

# 2. 重新设置认证
openclaw-cn models auth setup-token --provider anthropic
# 或
openclaw-cn models auth setup-token --provider openai
```

### 问题 4：配置迁移失败

**症状**：提示需要运行 doctor 但 doctor 报错

**排查步骤**：

```bash
# 1. 备份当前配置
cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.backup

# 2. 运行非交互式 doctor
openclaw-cn doctor --non-interactive

# 3. 如果仍有问题，尝试修复模式
openclaw-cn doctor --repair
```

## 回滚到旧版本

如果新版本有问题，可以回滚到之前的版本：

```bash
# 查看可用版本
npm view openclaw-cn versions --json | tail -20

# 安装指定版本（替换 2026.1.15 为你需要的版本）
npm i -g openclaw-cn@2026.1.15

# 运行 doctor 并重启
openclaw-cn doctor
openclaw-cn gateway restart
```

## 获取帮助

如果问题无法解决：

1. 运行 `openclaw-cn status --all` 获取完整诊断报告
2. 查看 [故障排除指南](/gateway/troubleshooting)
3. 在 Discord 社区提问：https://discord.gg/clawd

---

## 高级：更新渠道

Openclaw 有三个发布渠道：

| 渠道 | 说明 | 安装命令 |
|------|------|----------|
| stable | 稳定版（默认） | `npm i -g openclaw-cn@latest` |
| beta | 预发布测试版 | `npm i -g openclaw-cn@beta` |
| test | 开发测试版 | `npm i -g openclaw-cn@test` |

切换渠道：

```bash
openclaw-cn update --channel beta
openclaw-cn update --channel stable
```

## 高级：从源码更新

如果你是从 Git 仓库安装的：

```bash
# 方法 A：使用内置更新命令
openclaw-cn update

# 方法 B：手动更新
git pull
pnpm install
pnpm build
openclaw-cn doctor
openclaw-cn gateway restart
```

## 高级：Gateway 服务管理

**查看服务状态**：

```bash
openclaw-cn gateway status
```

**启动/停止/重启**：

```bash
openclaw-cn gateway start
openclaw-cn gateway stop
openclaw-cn gateway restart
```

**安装/卸载系统服务**：

```bash
openclaw-cn gateway install    # 安装为系统服务（开机自启）
openclaw-cn gateway uninstall  # 卸载系统服务
```

**平台特定命令**：

- macOS：`launchctl kickstart -k gui/$UID/com.openclaw.gateway`
- Linux：`systemctl --user restart clawdbot-gateway.service`
