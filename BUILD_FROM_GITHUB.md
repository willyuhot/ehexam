# 从 GitHub 构建 TestFlight 版本指南

## 🎯 两种方式对比

| 方式 | 优点 | 缺点 | 推荐度 |
|------|------|------|--------|
| **GitHub Actions（云端）** | 无需本地 Xcode、自动构建、支持 Xcode 16 | 需要配置 Secrets | ⭐⭐⭐⭐⭐ |
| **本地构建** | 速度快、可调试 | 需要本地 Xcode | ⭐⭐⭐⭐ |

---

## 🚀 方式 1：使用 GitHub Actions（推荐）

### 步骤 1：配置 GitHub Secrets

1. 打开仓库：https://github.com/willyuhot/ehexam
2. 点击 **Settings**（设置）
3. 左侧菜单选择 **Secrets and variables** → **Actions**
4. 点击 **New repository secret**，添加：

   **Secret Name**: `DEVELOPMENT_TEAM`  
   **Secret Value**: `2743LCQM5N`  
   点击 **Add secret**

### 步骤 2：触发构建

**方法 A：手动触发（推荐首次使用）**

1. 进入 https://github.com/willyuhot/ehexam
2. 点击 **Actions** 标签
3. 在左侧选择 **"Build TestFlight IPA"** 工作流
4. 点击右侧的 **"Run workflow"** 按钮
5. 选择分支：`main`
6. 点击绿色的 **"Run workflow"** 按钮
7. 等待构建完成（约 10-20 分钟）

**方法 B：自动触发**

- 推送到 `main` 分支会自动触发构建
- 或创建版本标签（如 `v1.0.0`）也会触发

### 步骤 3：下载 IPA 文件

1. 构建完成后，进入 **Actions** 页面
2. 点击最新的构建运行（绿色 ✓ 表示成功）
3. 滚动到底部，找到 **Artifacts** 部分
4. 点击 **EHExam-IPA** 下载
5. 解压下载的 zip 文件，得到 `EHExam.ipa`

### 步骤 4：上传到 TestFlight

**使用 Transporter 应用（推荐）**

1. 从 Mac App Store 下载 **Transporter** 应用
2. 打开 Transporter
3. 拖拽 `EHExam.ipa` 文件到 Transporter
4. 点击 **Deliver**（交付）
5. 等待上传完成

**或使用命令行**

```bash
xcrun altool --upload-app \
  --type ios \
  --file ./EHExam.ipa \
  --apiKey YOUR_API_KEY \
  --apiIssuer YOUR_ISSUER_ID
```

---

## 💻 方式 2：本地构建

### 步骤 1：拉取最新代码

```bash
cd /Users/yuhuahuan/code/EHExam
git pull origin main
```

### 步骤 2：运行构建脚本

```bash
# 设置 Team ID（如果还没有）
export DEVELOPMENT_TEAM="2743LCQM5N"

# 运行构建脚本
./build_for_testflight.sh
```

脚本会自动：
- ✅ 清理之前的构建
- ✅ 生成/更新 Xcode 项目
- ✅ 构建 Archive（Release 配置）
- ✅ 导出 IPA 文件

### 步骤 3：上传到 TestFlight

构建完成后，IPA 文件在：`./EHExam.ipa`

使用 Transporter 应用上传（同上）。

---

## 📋 前置要求

### 1. Apple Developer 账号
- 需要付费账号（$99/年）
- 登录 https://developer.apple.com 确认账号状态

### 2. App Store Connect 中的 App
- 登录 https://appstoreconnect.apple.com
- **必须先创建 App**，Bundle ID 必须匹配
- 当前 Bundle ID：`com.ehexam.EHExam.yuhuahuan.1769935853`
- 详细步骤见 [APP_STORE_CONNECT_SETUP.md](./APP_STORE_CONNECT_SETUP.md)

### 3. Team ID
- 你的 Team ID：`2743LCQM5N`
- 登录 https://developer.apple.com/account 可以查看

---

## 🔍 查看构建状态

### GitHub Actions

1. 访问：https://github.com/willyuhot/ehexam/actions
2. 查看最新的构建运行
3. 点击进入查看详细日志

### 构建时间

- **首次构建**：约 15-20 分钟（需要安装依赖）
- **后续构建**：约 10-15 分钟

---

## 🛠️ 故障排除

### 构建失败

1. **检查 GitHub Secrets**
   - 确认 `DEVELOPMENT_TEAM` 已正确配置
   - 值应该是：`2743LCQM5N`

2. **查看构建日志**
   - 进入 Actions 页面
   - 点击失败的构建
   - 查看详细错误信息

3. **常见问题**
   - **签名错误**：检查 Team ID 是否正确
   - **项目生成失败**：检查 `project.yml` 文件
   - **依赖问题**：检查是否需要安装 xcodegen

### IPA 未生成

1. 检查 Archive 是否成功构建
2. 检查 ExportOptions.plist 配置
3. 查看完整构建日志

---

## 📚 相关文档

- [CI_CD_GUIDE.md](./CI_CD_GUIDE.md) - 详细的 CI/CD 配置指南
- [TESTFLIGHT_BUILD_GUIDE.md](./TESTFLIGHT_BUILD_GUIDE.md) - TestFlight 构建指南
- [APP_STORE_CONNECT_SETUP.md](./APP_STORE_CONNECT_SETUP.md) - App Store Connect 设置

---

## ✅ 快速检查清单

- [ ] GitHub Secrets 已配置（`DEVELOPMENT_TEAM`）
- [ ] App Store Connect 中已创建 App
- [ ] Bundle ID 匹配：`com.ehexam.EHExam.yuhuahuan.1769935853`
- [ ] 已触发 GitHub Actions 构建
- [ ] 构建成功并下载了 IPA
- [ ] 使用 Transporter 上传到 TestFlight

---

## 🎉 完成！

构建完成后，你可以在 App Store Connect 的 TestFlight 页面看到新构建，然后分发给测试人员。
