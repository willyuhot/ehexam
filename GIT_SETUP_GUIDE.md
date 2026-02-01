# Git 免密配置指南

本指南将帮助你在 Mac 上配置 Git，使其可以不用输入账号密码就能使用 git 命令。

## 📋 配置方式对比

| 方式 | 优点 | 缺点 | 推荐度 |
|------|------|------|--------|
| **SSH 密钥** | 更安全、一次配置永久使用、支持所有 Git 操作 | 需要生成密钥对 | ⭐⭐⭐⭐⭐ |
| **HTTPS + 凭据助手** | 配置简单、使用系统钥匙串 | 需要定期更新 token | ⭐⭐⭐⭐ |

## 🔑 方法 1：SSH 密钥（推荐）

### 步骤 1：检查是否已有 SSH 密钥

```bash
ls -la ~/.ssh/id_*.pub
```

如果看到 `id_rsa.pub` 或 `id_ed25519.pub` 等文件，说明已有密钥，可以跳过步骤 2。

### 步骤 2：生成 SSH 密钥

```bash
# 使用 ed25519 算法（推荐，更安全）
ssh-keygen -t ed25519 -C "your_email@example.com"

# 或者使用 RSA 算法（兼容性更好）
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

**提示**：
- 按 Enter 使用默认路径 `~/.ssh/id_ed25519`
- 可以设置密码保护密钥（推荐），也可以直接按 Enter 跳过
- 将 `your_email@example.com` 替换为你的 GitHub 邮箱

### 步骤 3：启动 SSH 代理并添加密钥

```bash
# 启动 SSH 代理
eval "$(ssh-agent -s)"

# 添加密钥到 SSH 代理
ssh-add ~/.ssh/id_ed25519
# 如果使用 RSA，则使用：
# ssh-add ~/.ssh/id_rsa
```

### 步骤 4：复制公钥到剪贴板

```bash
# 复制 ed25519 公钥
pbcopy < ~/.ssh/id_ed25519.pub

# 或者复制 RSA 公钥
# pbcopy < ~/.ssh/id_rsa.pub
```

### 步骤 5：在 GitHub 上添加 SSH 密钥

1. 登录 GitHub
2. 点击右上角头像 → **Settings**
3. 左侧菜单选择 **SSH and GPG keys**
4. 点击 **New SSH key**
5. **Title**：填写一个描述（如 "MacBook Pro"）
6. **Key**：粘贴刚才复制的公钥（`Cmd+V`）
7. 点击 **Add SSH key**

### 步骤 6：测试 SSH 连接

```bash
ssh -T git@github.com
```

如果看到类似以下消息，说明配置成功：
```
Hi username! You've successfully authenticated, but GitHub does not provide shell access.
```

### 步骤 7：配置 Git 使用 SSH

如果项目已经存在，需要修改 remote URL：

```bash
cd /Users/yuhuahuan/code/EHExam

# 查看当前 remote
git remote -v

# 如果使用的是 HTTPS，改为 SSH
git remote set-url origin git@github.com:你的用户名/EHExam.git
```

如果还没有添加 remote：

```bash
cd /Users/yuhuahuan/code/EHExam
git remote add origin git@github.com:你的用户名/EHExam.git
```

### 步骤 8：配置 SSH 自动加载密钥（可选）

创建或编辑 `~/.ssh/config` 文件：

```bash
cat >> ~/.ssh/config << 'EOF'
Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
EOF
```

这样每次使用 SSH 时，密钥会自动加载到钥匙串。

## 🔐 方法 2：HTTPS + 凭据助手（macOS Keychain）

### 步骤 1：配置 Git 使用 macOS 钥匙串

```bash
# 配置 Git 使用 macOS 钥匙串存储凭据
git config --global credential.helper osxkeychain
```

### 步骤 2：生成 GitHub Personal Access Token

1. 登录 GitHub
2. 点击右上角头像 → **Settings**
3. 左侧菜单选择 **Developer settings**
4. 选择 **Personal access tokens** → **Tokens (classic)**
5. 点击 **Generate new token** → **Generate new token (classic)**
6. 填写：
   - **Note**：描述（如 "Mac Git Access"）
   - **Expiration**：选择过期时间（建议 90 天或更长）
   - **Scopes**：勾选 `repo`（完整仓库访问权限）
7. 点击 **Generate token**
8. **重要**：复制生成的 token（只显示一次！）

### 步骤 3：使用 Token 进行首次操作

```bash
cd /Users/yuhuahuan/code/EHExam

# 添加 remote（如果还没有）
git remote add origin https://github.com/你的用户名/EHExam.git

# 执行一次需要认证的操作（如 push）
git push -u origin main
```

**提示**：
- **Username**：输入你的 GitHub 用户名
- **Password**：**不要输入密码**，而是粘贴刚才生成的 Personal Access Token

凭据会自动保存到 macOS 钥匙串，以后就不需要再输入了。

### 步骤 4：验证配置

```bash
# 查看保存的凭据
git config --global credential.helper
# 应该显示：osxkeychain

# 测试推送（应该不需要输入密码）
git push
```

## 🔄 从 HTTPS 切换到 SSH

如果之前使用的是 HTTPS，想切换到 SSH：

```bash
cd /Users/yuhuahuan/code/EHExam

# 查看当前 remote URL
git remote -v

# 将 HTTPS URL 改为 SSH URL
# 从：https://github.com/用户名/仓库名.git
# 改为：git@github.com:用户名/仓库名.git
git remote set-url origin git@github.com:你的用户名/EHExam.git

# 验证
git remote -v
```

## ✅ 验证配置

### 测试 SSH 方式

```bash
# 测试 GitHub 连接
ssh -T git@github.com

# 测试推送（应该不需要输入密码）
cd /Users/yuhuahuan/code/EHExam
git push
```

### 测试 HTTPS 方式

```bash
# 测试推送（应该不需要输入密码）
cd /Users/yuhuahuan/code/EHExam
git push
```

## 🛠️ 故障排除

### SSH 连接失败

1. **检查 SSH 密钥是否添加到 GitHub**
   ```bash
   # 查看公钥内容
   cat ~/.ssh/id_ed25519.pub
   # 确认已在 GitHub 上添加
   ```

2. **检查 SSH 代理**
   ```bash
   # 启动 SSH 代理
   eval "$(ssh-agent -s)"
   ssh-add ~/.ssh/id_ed25519
   ```

3. **测试连接**
   ```bash
   ssh -vT git@github.com
   # -v 参数显示详细日志，帮助诊断问题
   ```

### HTTPS 仍然要求输入密码

1. **检查凭据助手配置**
   ```bash
   git config --global credential.helper
   # 应该显示：osxkeychain
   ```

2. **清除旧的凭据**
   ```bash
   # 打开"钥匙串访问"应用
   open /Applications/Utilities/Keychain\ Access.app
   # 搜索 "github.com"，删除相关条目
   ```

3. **重新配置**
   ```bash
   git config --global credential.helper osxkeychain
   # 再次执行 git push，输入 token
   ```

### Token 过期

如果使用 HTTPS 方式，token 过期后需要：
1. 在 GitHub 上生成新的 token
2. 清除钥匙串中的旧凭据
3. 重新执行 git 操作并输入新 token

## 📝 推荐配置

**推荐使用 SSH 方式**，因为：
- ✅ 更安全（密钥对加密）
- ✅ 一次配置，永久使用
- ✅ 不需要定期更新 token
- ✅ 支持所有 Git 操作

## 🎯 快速设置脚本

如果你想快速设置 SSH 方式，可以运行：

```bash
# 生成 SSH 密钥（如果还没有）
if [ ! -f ~/.ssh/id_ed25519 ]; then
    echo "生成 SSH 密钥..."
    ssh-keygen -t ed25519 -C "$(git config user.email)" -f ~/.ssh/id_ed25519 -N ""
fi

# 启动 SSH 代理并添加密钥
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# 配置 SSH config
mkdir -p ~/.ssh
cat >> ~/.ssh/config << 'EOF'
Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
EOF

# 复制公钥到剪贴板
pbcopy < ~/.ssh/id_ed25519.pub

echo "✅ SSH 密钥已生成并复制到剪贴板"
echo "📋 请到 GitHub 添加 SSH 密钥："
echo "   https://github.com/settings/keys"
echo ""
echo "🔑 公钥已复制到剪贴板，直接粘贴即可"
```

## 📚 相关资源

- [GitHub SSH 密钥文档](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
- [Git 凭据存储文档](https://git-scm.com/book/en/v2/Git-Tools-Credential-Storage)
- [macOS 钥匙串访问](https://support.apple.com/guide/keychain-access/welcome/mac)
