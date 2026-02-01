# 🚀 上游合并快速开始指南

> 用于安全合并 [openclaw/openclaw](https://github.com/openclaw/openclaw) 上游更新到本项目

## 📋 TL;DR（最快路径）

```bash
# 一键启动交互式合并向导
./scripts/merge-helpers/merge-wizard.sh
```

向导会自动引导你完成整个合并流程，适合首次合并或不熟悉流程的用户。

---

## 📚 完整文档

- **详细策略**: [MERGE_UPSTREAM_STRATEGY.md](./MERGE_UPSTREAM_STRATEGY.md) - 8000+ 字完整指南
- **工具文档**: [scripts/merge-helpers/README.md](./scripts/merge-helpers/README.md) - 辅助工具说明

---

## 🛠️ 工具箱

| 工具 | 用途 | 使用时机 |
|------|------|----------|
| `merge-wizard.sh` | 交互式向导 | ⭐ 推荐首次使用 |
| `pre-merge-check.sh` | 环境预检查 | 合并前检查准备工作 |
| `classify-conflicts.sh` | 冲突分类处理 | 合并产生冲突时 |
| `sync-version.sh` | 版本号同步 | 合并后更新版本 |

---

## ⚡ 快速合并流程

### 选项 A: 使用向导（推荐）

```bash
# 一条命令完成所有步骤
./scripts/merge-helpers/merge-wizard.sh
```

向导会依次：
1. ✅ 运行预检查
2. ✅ 创建备份分支
3. ✅ 配置上游远程
4. ✅ 获取最新更新
5. ✅ 创建合并分支
6. ✅ 执行合并（可选择策略）
7. ✅ 处理冲突
8. ✅ 同步版本号
9. ✅ 运行测试

### 选项 B: 手动分步执行

```bash
# 1. 预检查（必须）
./scripts/merge-helpers/pre-merge-check.sh

# 2. 创建备份（强烈推荐）
git branch backup-before-merge

# 3. 创建合并分支
git checkout -b merge-upstream-$(date +%Y%m%d)

# 4. 配置并获取上游（如果还没配置）
git remote add upstream https://github.com/openclaw/openclaw
git fetch upstream

# 5. 执行合并
git merge upstream/main --no-ff -m "merge: sync with upstream openclaw"

# 6. 处理冲突（如果有）
./scripts/merge-helpers/classify-conflicts.sh

# 7. 手动解决剩余冲突
# 编辑冲突文件...
git add <resolved-files>
git merge --continue

# 8. 同步版本号
./scripts/merge-helpers/sync-version.sh

# 9. 测试验证
pnpm install
pnpm build
pnpm test

# 10. 推送
git push origin merge-upstream-$(date +%Y%m%d)
```

---

## 🎯 合并策略选择

### 策略 1: 完整合并（推荐）

**适用**: 长期未同步，需要获取所有上游更新

```bash
git merge upstream/main --no-ff
```

**优点**: 
- ✅ 获得所有功能更新和 bug 修复
- ✅ 保持与上游同步

**缺点**:
- ⚠️ 可能产生较多冲突（工具会帮你处理）

### 策略 2: 部分合并

**适用**: 只想合并到某个特定版本

```bash
# 查看上游提交
git log --oneline upstream/main -50

# 合并到指定提交
git merge <commit-hash> --no-ff
```

### 策略 3: Cherry-pick

**适用**: 只需要特定的 bug 修复或功能

```bash
# 查看上游安全修复
git log --oneline upstream/main --grep="security:"

# 选择性合并
git cherry-pick <commit-hash>
```

---

## 🔧 冲突处理策略

合并时可能遇到冲突，工具会自动分类：

### 自动处理（工具完成）

✅ **保留本地版本**:
- `README.md` - 完全中文化
- `FEISHU_NPM_READY.md` - 本地新增文档
- `.github/workflows/npm-publish.yml` - 自定义发布流程
- `docs/` - 中文文档

✅ **采用上游版本**:
- `src/infra/` - 基础设施代码
- `src/media/` - 媒体处理
- `src/providers/` - AI 提供商
- `test/**/*.test.ts` - 测试文件

### 需要手动处理

⚠️ 这些文件需要你审查：
- `package.json` - 包名、依赖合并
- `.env.example` - 配置示例
- `src/cli/*` - CLI 命令（可能有中文提示）
- `src/gateway/*` - 网关核心

**处理方法**:
```bash
# 1. 查看冲突标记
<<<<<<< HEAD (你的版本)
中文提示文本
=======
English prompt
>>>>>>> upstream/main

# 2. 保留中文，采用上游逻辑
logger.info("配置已保存");  // 中文文本 + 上游新API
```

---

## ✅ 测试检查清单

合并后必须验证：

```bash
# 1. 依赖安装
pnpm install
# ✓ 应该没有错误

# 2. 类型检查和构建
pnpm build
# ✓ 应该编译成功

# 3. 运行测试
pnpm test
# ✓ 应该通过（允许少量无关测试失败）

# 4. Lint 检查
pnpm lint
# ✓ 应该没有错误

# 5. 功能测试
pnpm openclaw-cn --version
pnpm openclaw-cn --help
# ✓ 命令应该可用

# 6. 检查中文化是否完整
cat README.md | grep "openclaw-cn"
# ✓ 应该看到中文内容
```

---

## 🆘 常见问题

### Q: "upstream 未配置" 错误

```bash
git remote add upstream https://github.com/openclaw/openclaw
git fetch upstream
```

### Q: 冲突太多，怎么办？

1. 运行 `./scripts/merge-helpers/classify-conflicts.sh` 自动处理简单冲突
2. 分批处理剩余冲突，先处理关键文件（`package.json`）
3. 如果实在太多，考虑"部分合并"策略

### Q: 测试失败了

```bash
# 查看详细错误
pnpm build 2>&1 | tee build-errors.log

# 对比依赖变化
git diff upstream/main..HEAD package.json

# 重新安装
rm -rf node_modules pnpm-lock.yaml
pnpm install
```

### Q: 如何回滚？

```bash
# 如果还未推送
git reset --hard backup-before-merge

# 如果已推送到分支
git checkout main
git branch -D merge-upstream-YYYYMMDD

# 恢复备份
git reset --hard backup-before-merge
```

### Q: 版本号怎么定？

工具会自动计算：

```
上游版本: 2026.1.30
建议版本: 2026.1.30-cn.1
```

格式：`<上游版本>-cn.<补丁版本>`

---

## 📊 当前状态

根据分析：
- 📦 **文件差异**: ~3815 个文件
- 📝 **提交差距**: 480+ 个提交
- 🔧 **主要改动**: 包名、文档、UI 中文化

---

## 🎓 最佳实践

1. **定期同步**: 每 1-2 个月同步一次，避免差距过大
2. **先备份**: 总是创建 `backup-before-merge` 分支
3. **分步测试**: 合并后立即测试，发现问题早解决
4. **记录变更**: 在 `CHANGELOG.md` 中记录本次同步的上游版本
5. **使用标签**: 每次合并后打 tag（工具会提示）

---

## 📞 获取帮助

- 📖 查看详细文档: [MERGE_UPSTREAM_STRATEGY.md](./MERGE_UPSTREAM_STRATEGY.md)
- 🔧 工具使用指南: [scripts/merge-helpers/README.md](./scripts/merge-helpers/README.md)
- 🐛 报告问题: [GitHub Issues](https://github.com/jiulingyun/openclaw-cn/issues)

---

**祝合并顺利！** 🎉

有任何问题欢迎在 Issues 中讨论。
