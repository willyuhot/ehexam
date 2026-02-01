# 设置 GitHub Actions 构建 TestFlight 版本

## 📋 快速开始

您的仓库地址：https://github.com/willyuhot/ehexam

## 步骤 1：初始化 Git 并推送代码

```bash
cd /Users/yuhuahuan/code/EHExam

# 初始化 Git（如果还没有）
git init

# 添加远程仓库
git remote add origin https://github.com/willyuhot/ehexam.git

# 检查当前状态
git status

# 添加所有文件
git add .

# 提交
git commit -m "Initial commit: Add EHExam iOS app with CI/CD"

# 推送到 GitHub
git branch -M main
git push -u origin main
```

## 步骤 2：配置 GitHub Secrets

1. 打开 https://github.com/willyuhot/ehexam
2. 点击 **Settings**（设置）
3. 左侧菜单选择 **Secrets and variables** → **Actions**
4. 点击 **New repository secret**，添加：

   **Secret 1: DEVELOPMENT_TEAM**
   - Name: `DEVELOPMENT_TEAM`
   - Value: `2743LCQM5N`
   - 点击 **Add secret**

   （可选）如果需要自动上传，添加：
   - `APP_STORE_CONNECT_API_KEY`: 你的 API Key ID
   - `APP_STORE_CONNECT_ISSUER_ID`: 你的 Issuer ID
   - `APP_STORE_CONNECT_API_KEY_CONTENT`: .p8 文件内容

## 步骤 3：触发构建

### 方法 A：手动触发（推荐首次使用）

1. 进入 https://github.com/willyuhot/ehexam
2. 点击 **Actions** 标签
3. 在左侧选择 **"Build TestFlight IPA"** 工作流
4. 点击 **"Run workflow"** 按钮
5. 选择分支：`main`
6. 点击绿色的 **"Run workflow"** 按钮
7. 等待构建完成（约 10-20 分钟）

### 方法 B：自动触发

- 推送到 `main` 分支会自动触发构建
- 或创建版本标签（如 `v1.0.0`）也会触发

## 步骤 4：下载 IPA 文件

1. 构建完成后，进入 **Actions** 页面
2. 点击最新的构建运行（绿色 ✓ 表示成功）
3. 滚动到底部，找到 **Artifacts** 部分
4. 点击 **EHExam-IPA** 下载
5. 解压下载的 zip 文件，得到 `EHExam.ipa`

## 步骤 5：上传到 TestFlight

### 使用 Transporter 应用（推荐）

1. 从 Mac App Store 下载 **Transporter** 应用
2. 打开 Transporter
3. 拖拽 `EHExam.ipa` 文件到 Transporter
4. 点击 **"交付"** 按钮
5. 等待上传完成

### 或使用命令行

```bash
./upload_to_testflight.sh
```

## 📝 工作流说明

GitHub Actions 工作流会：
- ✅ 使用 macOS 15 runner（自带 Xcode 16 和 iOS 18 SDK）
- ✅ 自动安装 xcodegen
- ✅ 生成 Xcode 项目
- ✅ 构建 Release 版本的 Archive
- ✅ 导出 IPA 文件（符合 App Store Connect 要求）
- ✅ 上传为 Artifact 供下载

## 🔍 检查构建状态

1. 进入 https://github.com/willyuhot/ehexam/actions
2. 查看构建历史
3. 点击任意构建查看详细日志

## ⚠️ 注意事项

1. **首次构建**可能需要较长时间（15-20 分钟）
2. **后续构建**通常更快（10-15 分钟）
3. **免费额度**：公开仓库无限，私有仓库每月 2000 分钟
4. **构建日志**：如果失败，查看详细日志排查问题

## 🆘 常见问题

### Q: 构建失败怎么办？
A: 
1. 点击失败的构建查看日志
2. 检查 GitHub Secrets 是否配置正确
3. 确认 `project.yml` 配置无误

### Q: 找不到 IPA 文件？
A: 
1. 确认构建成功（绿色 ✓）
2. 滚动到页面底部查看 Artifacts
3. 如果构建失败，查看错误日志

### Q: 如何查看构建日志？
A: 
1. 进入 Actions 页面
2. 点击构建运行
3. 展开各个步骤查看详细日志

## 🎯 下一步

1. ✅ 推送代码到 GitHub
2. ✅ 配置 GitHub Secrets
3. ✅ 触发第一次构建
4. ✅ 下载 IPA 并上传到 TestFlight

## 📞 需要帮助？

如果遇到问题：
1. 查看构建日志
2. 检查 `CI_CD_GUIDE.md` 详细文档
3. 确认所有配置正确
