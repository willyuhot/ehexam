# 自动下载 IPA 文件指南

## 🤔 为什么需要 GitHub CLI？

### GitHub CLI 的作用

GitHub CLI (`gh`) 是一个命令行工具，可以：
- ✅ **简化操作**：不需要手动处理 API Token
- ✅ **自动认证**：登录一次，后续自动使用
- ✅ **更安全**：Token 存储在系统钥匙串中
- ✅ **更简单**：命令更直观，如 `gh run download`

### 不使用 GitHub CLI 也可以

如果你不想安装 GitHub CLI，也可以：
- 使用 GitHub API 直接下载（需要手动获取 Token）
- 手动从网页下载

---

## 📥 三种下载方式

### 方式 1：使用 GitHub CLI（推荐，最简单）

**优点**：
- ✅ 最简单，命令直观
- ✅ 自动处理认证
- ✅ 可以使用 Token 免交互登录

**步骤**：

```bash
# 1. 安装 GitHub CLI（如果还没有）
brew install gh

# 2. 使用 Token 登录（推荐，免交互）
./setup_gh_token.sh
# 或者手动：
# echo "你的Token" | gh auth login --with-token

# 3. 运行下载脚本
./download_ipa_simple.sh
```

**或者使用交互式登录**：

```bash
gh auth login
# 选择：GitHub.com > HTTPS > Login with a web browser
```

**为什么推荐**：
- 安装一次，永久使用
- 登录一次，后续自动认证
- 命令简单，不容易出错

---

### 方式 2：不使用 GitHub CLI（使用 API）

**优点**：
- ✅ 不需要安装额外工具
- ✅ 只需要 curl（Mac 自带）

**缺点**：
- ⚠️ 需要手动获取 GitHub Token
- ⚠️ 需要安装 jq（可选，但推荐）

**步骤**：

```bash
# 1. 获取 GitHub Token（可选但推荐）
# 访问：https://github.com/settings/tokens
# 点击 "Generate new token (classic)"
# 勾选 "public_repo" 权限
# 复制生成的 Token

# 2. 运行脚本（会提示输入 Token）
./download_ipa_no_cli.sh
```

**或者设置环境变量**：

```bash
export GITHUB_TOKEN="你的Token"
./download_ipa_no_cli.sh
```

---

### 方式 3：手动下载（最简单，但需要手动操作）

**步骤**：

1. 访问：https://github.com/willyuhot/ehexam/actions
2. 点击最新的构建运行（绿色 ✓）
3. 滚动到底部，找到 **Artifacts**
4. 点击 **EHExam-IPA** 下载
5. 解压 ZIP 文件，得到 `EHExam.ipa`

---

## 🎯 推荐方案对比

| 方式 | 安装难度 | 使用难度 | 自动化程度 | 推荐度 |
|------|---------|---------|-----------|--------|
| **GitHub CLI** | ⭐⭐ | ⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **API 方式** | ⭐ | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **手动下载** | ⭐ | ⭐⭐⭐ | ⭐ | ⭐⭐ |

---

## 📋 快速开始

### 如果你想要最简单的体验：

```bash
# 安装 GitHub CLI（只需一次）
brew install gh

# 登录（只需一次）
gh auth login

# 以后每次只需要运行：
./download_ipa_simple.sh
```

### 如果你不想安装任何工具：

1. 使用手动下载方式（见上方）
2. 或者运行 `./download_ipa_no_cli.sh`（需要 Token）

---

## 🔧 安装 GitHub CLI

### 为什么安装 GitHub CLI？

**一句话总结**：安装一次，永久方便。

**详细原因**：

1. **简化操作**
   - 不用 GitHub CLI：需要获取 Token、设置环境变量、处理 API 请求
   - 使用 GitHub CLI：直接运行 `gh run download`，自动处理一切

2. **更安全**
   - Token 存储在系统钥匙串中，不会泄露
   - 自动处理 Token 刷新

3. **更强大**
   - 支持更多 GitHub 操作（issues、PR、releases 等）
   - 统一的命令行界面

4. **一次安装，永久使用**
   - 安装：`brew install gh`（约 1 分钟）
   - 登录：`gh auth login`（约 30 秒）
   - 以后：直接使用，无需再配置

### 安装步骤

```bash
# 1. 安装（使用 Homebrew）
brew install gh

# 2. 登录
gh auth login
# 选择：GitHub.com
# 选择：HTTPS
# 选择：Login with a web browser
# 按提示完成登录

# 3. 验证
gh auth status
```

**总耗时**：约 2 分钟

---

## 💡 常见问题

### Q: 必须安装 GitHub CLI 吗？

**A**: 不是必须的。你可以：
- 使用 `download_ipa_no_cli.sh`（需要 Token）
- 或者手动从网页下载

### Q: GitHub CLI 安全吗？

**A**: 是的，非常安全：
- Token 存储在 macOS 钥匙串中
- 只请求必要的权限
- 由 GitHub 官方维护

### Q: 可以不用 Token 吗？

**A**: 对于公开仓库，可以不用 Token，但：
- API 请求限制较低（每小时 60 次）
- 某些操作可能失败

### Q: 哪个脚本最好？

**A**: 
- **最简单**：`download_ipa_simple.sh`（需要 GitHub CLI）
- **最灵活**：`download_ipa_no_cli.sh`（不需要 CLI，但需要 Token）
- **最完整**：`download_ipa.sh`（支持两种方式）

---

## 🚀 推荐工作流程

```bash
# 1. 推送代码触发构建
git push origin main

# 2. 等待几分钟后，下载 IPA
./download_ipa_simple.sh

# 3. 上传到 TestFlight
# 使用 Transporter 应用
```

---

## 📚 相关文档

- [BUILD_FROM_GITHUB.md](./BUILD_FROM_GITHUB.md) - 构建指南
- [GIT_SETUP_GUIDE.md](./GIT_SETUP_GUIDE.md) - Git 配置指南
