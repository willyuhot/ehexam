# TestFlight 构建和上传指南

## 前置要求

1. **Apple Developer账号**（$99/年）
   - 登录 https://developer.apple.com
   - 确保账号已激活

2. **App Store Connect中的App** ⚠️ **重要！**
   - 登录 https://appstoreconnect.apple.com
   - **必须先在 App Store Connect 中创建 App，Bundle ID 必须与 IPA 文件中的完全匹配**
   - 如果遇到"找不到合适的应用程序记录"错误，请查看 [APP_STORE_CONNECT_SETUP.md](./APP_STORE_CONNECT_SETUP.md)
   - 当前项目的 Bundle ID：`com.ehexam.EHExam.yuhuahuan.1769935853`

## 方法一：使用脚本构建和上传

### 步骤1：构建IPA文件

```bash
cd /Users/yuhuahuan/code/EHExam
chmod +x build_for_testflight.sh
./build_for_testflight.sh
```

脚本会提示你输入：
- **Team ID**：在 https://developer.apple.com/account 的Membership页面查看

### 步骤2：上传到TestFlight

#### 选项A：使用Transporter应用（推荐）

1. 从Mac App Store下载 **Transporter** 应用
2. 打开Transporter
3. 拖拽 `EHExam.ipa` 文件到Transporter
4. 点击"交付"
5. 等待上传完成

#### 选项B：使用命令行上传

```bash
chmod +x upload_to_testflight.sh
./upload_to_testflight.sh
```

需要配置API Key（**推荐使用上面的Transporter方法，更简单**）：
1. 登录 https://appstoreconnect.apple.com
2. 点击右上角的用户图标，选择 "Users and Access"
3. 点击左侧的 "Keys" 标签
4. 点击 "+" 创建新的API Key
5. 下载.p8文件（只能下载一次！请妥善保存）
6. 记录 Key ID 和 Issuer ID（Issuer ID在页面顶部，是UUID格式，如：`12345678-1234-1234-1234-123456789012`）

## 方法二：使用Xcode Archive（GUI方式）

### 步骤1：在Xcode中Archive

1. 打开项目：
   ```bash
   open EHExam.xcodeproj
   ```

2. 选择 "Any iOS Device" 作为目标

3. 菜单：**Product > Archive**

4. 等待Archive完成

### 步骤2：上传到App Store Connect

1. Archive完成后，Xcode会打开Organizer窗口

2. 选择刚创建的Archive

3. 点击 **"Distribute App"**

4. 选择 **"App Store Connect"**

5. 选择 **"Upload"**

6. 按照向导完成：
   - 选择分发选项
   - 选择签名方式（自动签名）
   - 等待上传完成

### 步骤3：在App Store Connect中处理

1. 登录 https://appstoreconnect.apple.com

2. 进入你的App

3. 进入 **TestFlight** 标签

4. 等待构建处理完成（通常5-30分钟）

5. 添加测试员：
   - **内部测试**：最多100人，立即可用
   - **外部测试**：最多10,000人，需要审核

## 方法三：使用Fastlane（自动化）

如果你熟悉Fastlane，可以设置自动化流程：

```bash
# 安装Fastlane
sudo gem install fastlane

# 初始化
cd /Users/yuhuahuan/code/EHExam
fastlane init
```

## 常见问题

### Q: 构建失败，提示需要签名
**A:** 确保在Xcode中配置了正确的Team：
1. 打开项目设置
2. 选择EHExam target
3. Signing & Capabilities标签
4. 选择你的Team

### Q: 上传失败，提示权限问题
**A:** 确保你的Apple ID有App Manager或Admin权限

### Q: TestFlight中看不到构建
**A:** 
- 等待处理完成（可能需要30分钟）
- 检查构建状态是否为"Ready to Submit"
- 确保版本号递增

### Q: 如何添加测试员
**A:**
1. 在TestFlight页面
2. 点击"Testers"标签
3. 添加内部测试员（使用Apple ID邮箱）
4. 或创建外部测试组

## 版本号管理

每次上传新版本，需要：
- 增加 `CFBundleVersion`（Build号）
- 可以保持 `CFBundleShortVersionString`（版本号）不变

在 `Info.plist` 中修改：
```xml
<key>CFBundleVersion</key>
<string>2</string>  <!-- 每次+1 -->
```

## 测试流程

1. **内部测试**（立即）
   - 添加团队成员
   - 立即可以测试

2. **外部测试**（需要审核）
   - 创建测试组
   - 提交审核
   - 审核通过后可以测试

## 注意事项

- ⚠️ 首次上传需要较长时间处理
- ⚠️ 外部测试需要App Store审核（通常1-2天）
- ⚠️ 确保Bundle ID与App Store Connect中的一致
- ⚠️ 确保版本号递增
