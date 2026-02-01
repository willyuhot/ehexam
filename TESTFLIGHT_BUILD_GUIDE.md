# TestFlight 构建快速指南

## 🚀 快速开始

### 方法一：使用脚本构建（推荐）

```bash
cd /Users/yuhuahuan/code/EHExam
./build_for_testflight.sh
```

脚本会自动：
1. 提示输入 Team ID（如果没有设置）
2. 清理之前的构建
3. 生成/更新 Xcode 项目
4. 构建 Archive（Release 配置）
5. 导出 IPA 文件

### 方法二：在 Xcode 中构建

1. **打开项目**：
   ```bash
   open EHExam.xcodeproj
   ```

2. **配置签名**：
   - 选择项目（蓝色图标）
   - 选择 **EHExam** target
   - 进入 **"Signing & Capabilities"** 标签
   - 勾选 **"Automatically manage signing"**
   - 选择你的 **Team**

3. **构建 Archive**：
   - 在顶部选择 **"Any iOS Device"**（不是模拟器）
   - 菜单：**Product > Archive**
   - 等待构建完成

4. **导出 IPA**：
   - Archive 完成后，点击 **"Distribute App"**
   - 选择 **"App Store Connect"**
   - 选择 **"Upload"**
   - 按照向导完成

## 📋 前置要求

### 1. Apple Developer 账号
- 需要付费账号（$99/年）
- 登录 https://developer.apple.com 确认账号状态

### 2. App Store Connect 中的 App
- 登录 https://appstoreconnect.apple.com
- **必须先创建 App**，Bundle ID 必须匹配
- 当前 Bundle ID：`com.ehexam.EHExam.yuhuahuan.1769935853`
- 详细步骤见 [APP_STORE_CONNECT_SETUP.md](./APP_STORE_CONNECT_SETUP.md)

### 3. 获取 Team ID
- 登录 https://developer.apple.com/account
- 在 **Membership** 页面查看 **Team ID**
- 格式类似：`2743LCQM5N`

## 🔧 构建步骤详解

### 步骤 1：设置 Team ID（可选）

如果不想每次输入，可以设置环境变量：

```bash
export DEVELOPMENT_TEAM="你的Team ID"
```

或者添加到 `~/.zshrc` 或 `~/.bash_profile`：

```bash
echo 'export DEVELOPMENT_TEAM="你的Team ID"' >> ~/.zshrc
source ~/.zshrc
```

### 步骤 2：运行构建脚本

```bash
./build_for_testflight.sh
```

脚本会：
- ✅ 自动清理旧构建
- ✅ 生成/更新项目文件
- ✅ 构建 Release 版本的 Archive
- ✅ 导出 IPA 文件到 `./EHExam.ipa`

### 步骤 3：上传到 TestFlight

#### 选项 A：使用 Transporter（最简单）

1. 从 Mac App Store 下载 **Transporter** 应用
2. 打开 Transporter
3. 拖拽 `EHExam.ipa` 到 Transporter
4. 点击 **"交付"**
5. 等待上传完成

#### 选项 B：使用 Xcode Organizer

1. 在 Xcode 中：**Window > Organizer**
2. 选择刚创建的 Archive
3. 点击 **"Distribute App"**
4. 选择 **"App Store Connect"** > **"Upload"**

## 📱 在 App Store Connect 中处理

1. 登录 https://appstoreconnect.apple.com
2. 进入你的 App
3. 进入 **TestFlight** 标签
4. 等待构建处理完成（通常 5-30 分钟）
5. 处理完成后，可以：
   - 添加内部测试员（立即可用）
   - 创建外部测试组（需要审核）

## ⚠️ 常见问题

### Q: 构建失败，提示需要签名
**A:** 
1. 确保在 Xcode 中选择了正确的 Team
2. 或者运行脚本时提供 Team ID：
   ```bash
   DEVELOPMENT_TEAM="你的Team ID" ./build_for_testflight.sh
   ```

### Q: 上传失败，提示找不到应用程序记录
**A:** 
- 必须在 App Store Connect 中先创建 App
- Bundle ID 必须完全匹配
- 查看 [APP_STORE_CONNECT_SETUP.md](./APP_STORE_CONNECT_SETUP.md)

### Q: 版本号问题
**A:** 
- 每次上传新版本，需要增加 Build 号（`CFBundleVersion`）
- 在 `Info.plist` 中修改，或使用脚本自动递增

## 🔄 版本号管理

每次上传新版本前，需要增加 Build 号：

```bash
# 方法1：手动修改 Info.plist
# 将 CFBundleVersion 从 "1" 改为 "2"

# 方法2：使用 sed 命令
sed -i '' 's/<string>1<\/string>/<string>2<\/string>/' Info.plist
```

## 📝 完整流程示例

```bash
# 1. 进入项目目录
cd /Users/yuhuahuan/code/EHExam

# 2. 设置 Team ID（可选，如果已设置可跳过）
export DEVELOPMENT_TEAM="2743LCQM5N"

# 3. 构建 TestFlight 版本
./build_for_testflight.sh

# 4. 上传到 TestFlight（使用 Transporter）
# 打开 Transporter 应用，拖拽 EHExam.ipa 进去
```

## 💡 提示

- ✅ 使用脚本构建最快速
- ✅ Transporter 应用上传最简单
- ✅ 确保 Bundle ID 与 App Store Connect 中的匹配
- ✅ 每次上传前记得增加 Build 号
