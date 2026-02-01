# 使用 CI/CD 构建 TestFlight 版本指南

由于您的 Mac 无法升级到 macOS 15，无法安装 Xcode 16，可以使用 CI/CD 服务在云端构建。

## 🚀 方案 1：GitHub Actions（推荐，免费）

### 前置要求

1. **GitHub 账号**（免费）
2. **将项目推送到 GitHub**
3. **配置 GitHub Secrets**

### 步骤 1：将项目推送到 GitHub

```bash
# 如果还没有 Git 仓库
cd /Users/yuhuahuan/code/EHExam
git init
git add .
git commit -m "Initial commit"

# 在 GitHub 上创建新仓库，然后：
git remote add origin https://github.com/你的用户名/EHExam.git
git branch -M main
git push -u origin main
```

### 步骤 2：配置 GitHub Secrets

1. 进入 GitHub 仓库
2. 点击 **Settings** → **Secrets and variables** → **Actions**
3. 点击 **New repository secret**，添加以下 secrets：

   - **`DEVELOPMENT_TEAM`**: `2743LCQM5N`
   - **`APP_STORE_CONNECT_API_KEY`** (可选): 你的 API Key ID
   - **`APP_STORE_CONNECT_ISSUER_ID`** (可选): 你的 Issuer ID
   - **`APP_STORE_CONNECT_API_KEY_CONTENT`** (可选): .p8 文件内容

### 步骤 3：触发构建

**方法 A：手动触发**
1. 进入 GitHub 仓库
2. 点击 **Actions** 标签
3. 选择 **"Build TestFlight IPA"** 工作流
4. 点击 **"Run workflow"**
5. 选择分支（通常是 `main`）
6. 点击 **"Run workflow"**

**方法 B：自动触发**
- 推送到 `main` 或 `master` 分支
- 或创建版本标签（如 `v1.0.0`）

### 步骤 4：下载 IPA

1. 构建完成后，进入 **Actions** 页面
2. 点击最新的构建运行
3. 在 **Artifacts** 部分下载 `EHExam-IPA`
4. 解压后得到 `EHExam.ipa` 文件
5. 使用 **Transporter** 应用上传到 TestFlight

## 🔧 方案 2：GitLab CI

如果你使用 GitLab：

### 创建 `.gitlab-ci.yml`

```yaml
build_testflight:
  image: macos-15
  before_script:
    - xcodegen generate
  script:
    - xcodebuild clean archive -project EHExam.xcodeproj -scheme EHExam -archivePath ./build/EHExam.xcarchive
    - xcodebuild -exportArchive -archivePath ./build/EHExam.xcarchive -exportPath ./build/export -exportOptionsPlist ExportOptions.plist
  artifacts:
    paths:
      - build/export/*.ipa
    expire_in: 1 week
```

## ☁️ 方案 3：其他云构建服务

### Bitrise（付费，但有免费额度）
- 网址：https://bitrise.io
- 支持 Xcode 16
- 有免费构建额度

### CircleCI（付费）
- 网址：https://circleci.com
- 支持 macOS runner

### Codemagic（付费，有免费额度）
- 网址：https://codemagic.io
- 专门用于移动应用构建

## 📝 使用 GitHub Actions 的详细步骤

### 1. 准备工作

确保项目已包含：
- ✅ `project.yml` 文件
- ✅ 所有源代码文件
- ✅ `.github/workflows/build-testflight.yml`（已创建）

### 2. 推送代码到 GitHub

```bash
cd /Users/yuhuahuan/code/EHExam

# 检查 .gitignore，确保不提交敏感文件
echo "build/
*.ipa
.DS_Store
*.xcuserdata
" >> .gitignore

# 提交并推送
git add .
git commit -m "Add CI/CD workflow for TestFlight"
git push origin main
```

### 3. 配置 Secrets

在 GitHub 仓库中设置：
- `DEVELOPMENT_TEAM`: `2743LCQM5N`

### 4. 触发构建

1. 进入 GitHub 仓库
2. Actions → Build TestFlight IPA → Run workflow
3. 等待构建完成（约 10-20 分钟）

### 5. 下载和使用 IPA

1. 构建完成后下载 Artifact
2. 解压得到 `EHExam.ipa`
3. 使用 Transporter 上传到 TestFlight

## ⚙️ 工作流说明

GitHub Actions 工作流会：
1. ✅ 使用 macOS 15 runner（自带 Xcode 16）
2. ✅ 自动安装 xcodegen
3. ✅ 生成 Xcode 项目
4. ✅ 构建 Archive（Release 配置）
5. ✅ 导出 IPA 文件
6. ✅ 上传为 Artifact 供下载

## 🔒 安全注意事项

- ⚠️ **不要**将敏感信息（如 API Key、.p8 文件）提交到代码仓库
- ✅ 使用 GitHub Secrets 存储敏感信息
- ✅ `.gitignore` 已配置排除敏感文件

## 📊 构建时间

- 首次构建：约 15-20 分钟（需要安装依赖）
- 后续构建：约 10-15 分钟

## 💰 成本

- **GitHub Actions**: 免费（公开仓库）或每月 2000 分钟（私有仓库）
- 对于个人项目通常足够使用

## 🆘 故障排除

### 构建失败

1. 检查 GitHub Actions 日志
2. 确认 Secrets 配置正确
3. 检查 `project.yml` 配置

### IPA 未生成

1. 检查 Archive 是否成功
2. 检查 ExportOptions.plist 配置
3. 查看完整构建日志

## 📞 下一步

1. 将项目推送到 GitHub
2. 配置 GitHub Secrets
3. 触发第一次构建
4. 下载 IPA 并上传到 TestFlight
