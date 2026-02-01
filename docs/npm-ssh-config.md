# npm SSH 配置问题解决方案

## 问题背景

`@whiskeysockets/baileys` 依赖 `libsignal-node`，而 `libsignal-node` 是从 GitHub 下载的原生 C++ 模块。npm install 时，这个依赖的编译过程会通过 SSH 访问 GitHub，导致以下错误：

```
Permission denied (publickey)
fatal: Could not read from remote repository
```

这个错误影响所有平台：Windows、macOS、Linux（包括容器内部）。

## 解决方案概述

本项目采用 **多层配置策略**，确保 npm/git 使用 HTTPS 而不是 SSH 访问 GitHub：

### 1️⃣ npm 配置 (`.npmrc`)

**文件**: `.npmrc`

```ini
git-protocol=https
fetch-timeout=120000
fetch-retry-mintimeout=20000
fetch-retry-maxtimeout=120000
```

**作用**: 告诉 npm 使用 HTTPS 协议访问 git 仓库，并增加超时时间以应对网络延迟。

### 2️⃣ postinstall 脚本自动配置

**文件**: `scripts/postinstall.js`

在 `npm install` 完成后自动配置 git 的 URL 重定向：

```javascript
git config url."https://github.com/".insteadOf ssh://git@github.com/
git config url."https://".insteadOf git://
```

这样 git 会自动将 SSH URLs 转换为 HTTPS。

### 3️⃣ Docker 镜像全局配置

**文件**: `Dockerfile`, `Dockerfile.sandbox`, `Dockerfile.sandbox-browser`

在容器构建时全局配置 git：

```dockerfile
RUN git config --global url."https://github.com/".insteadOf ssh://git@github.com/
RUN git config --global url."https://".insteadOf git://
```

### 4️⃣ 手动配置脚本（可选）

**文件**: `scripts/setup-npm-git-config.sh`

如果需要手动设置 git 配置：

```bash
# 项目级别配置
bash scripts/setup-npm-git-config.sh

# 全局配置（需要 sudo）
sudo bash scripts/setup-npm-git-config.sh --global
```

## 如何使用

### 本地开发

1. **首次 clone 项目**
   ```bash
   git clone https://github.com/clawdbot/clawdbot.git
   cd clawdbot
   ```

2. **安装依赖**
   ```bash
   pnpm install
   ```
   
   postinstall 脚本会自动：
   - 配置 git URL 重定向
   - 设置 git 钩子
   - 应用补丁文件

### Docker 部署

所有 Dockerfile 已预配置，直接构建即可：

```bash
docker build -t clawdbot:latest .
docker build -f Dockerfile.sandbox -t clawdbot:sandbox .
docker build -f Dockerfile.sandbox-browser -t clawdbot:sandbox-browser .
```

### CI/CD 环境

在 GitHub Actions 或其他 CI/CD 中，`.npmrc` 配置会自动应用。如果需要额外配置：

```yaml
- name: Setup npm git config
  run: bash scripts/setup-npm-git-config.sh
  
- name: Install dependencies
  run: pnpm install
```

## 配置优先级

Git 会按以下顺序应用配置（后面的覆盖前面的）：

1. 系统级 (`/etc/gitconfig`)
2. 用户级 (`~/.gitconfig`)
3. 项目级 (`.git/config` - 在 postinstall 中设置)
4. .npmrc 中的 `git-protocol=https`

## 故障排除

### 如果仍然出现 SSH 错误

**方案 1**: 手动配置 git
```bash
git config url."https://github.com/".insteadOf ssh://git@github.com/
git config url."https://".insteadOf git://
```

**方案 2**: 删除 node_modules 重新安装
```bash
rm -rf node_modules pnpm-lock.yaml
pnpm install
```

**方案 3**: 清除 npm 缓存
```bash
npm cache clean --force
pnpm install
```

### 检查当前配置

```bash
# 查看项目级 git 配置
git config --list --local | grep url

# 查看全局 git 配置
git config --list --global | grep url

# 查看 npm 配置
npm config list | grep git
```

## 技术细节

### 为什么需要这个配置？

- npm 内部使用 git 克隆 `libsignal-node`
- npm 在某些情况下会将 HTTPS git URLs 转换为 SSH
- SSH 需要正确的密钥配置和访问权限
- HTTPS 使用账户授权（GitHub Personal Access Token）或直接公开访问

### 为什么 git-protocol=https 还不够？

- npm 仍然可能在某些环境中转换为 SSH
- git 自身的 URL 重定向规则优先级更高
- 同时配置 npm 和 git 确保全覆盖

### Windows 上是否有效？

是的。git 和 npm 在 Windows 上使用相同的 git 配置机制。

## 参考链接

- [npm 文档：git-protocol](https://docs.npmjs.com/cli/v9/using-npm/config#git-protocol)
- [Git 文档：url.<base>.insteadOf](https://git-scm.com/docs/git-config#core.sshCommand)
- [Baileys GitHub](https://github.com/WhiskeySockets/Baileys)
- [libsignal-node GitHub](https://github.com/whiskeysockets/libsignal-node)

