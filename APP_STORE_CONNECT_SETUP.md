# App Store Connect 设置指南

## 问题：找不到合适的应用程序记录

错误信息：
```
无法为 App "EHExam.ipa"创建临时 .itmsp 软件包。
找不到合适的应用程序记录。
请验证你的捆绑包标识符"com.ehexam.EHExam.yuhuahuan.1769935853"是否正确，
以及你是否在 App Store Connect 中已通过可访问该 App 的 Apple 账户登录。
```

## 解决方案：在 App Store Connect 中创建 App

### 步骤 1：登录 App Store Connect

1. 打开浏览器，访问：https://appstoreconnect.apple.com
2. 使用你的 Apple Developer 账号登录

### 步骤 2：创建新的 App

1. 登录后，点击 **"我的App"**（My Apps）
2. 点击左上角的 **"+"** 按钮
3. 选择 **"新App"**（New App）

### 步骤 3：填写 App 信息

在创建新 App 的表单中填写：

- **平台**：选择 **iOS**
- **名称**：`EHExam`（或你想要的名称）
- **主要语言**：选择你的语言（如：简体中文）
- **Bundle ID**：
  - 如果下拉列表中有 `com.ehexam.EHExam.yuhuahuan.1769935853`，直接选择
  - 如果没有，需要先注册这个 Bundle ID（见步骤 4）
- **SKU**：`EHExam-001`（或任何唯一标识符，用于内部追踪）

### 步骤 4：注册 Bundle ID（如果需要）

如果 Bundle ID 不在列表中，需要先在 Apple Developer 中注册：

1. 访问：https://developer.apple.com/account/resources/identifiers/list
2. 点击 **"+"** 按钮
3. 选择 **"App IDs"**
4. 点击 **"继续"**
5. 选择 **"App"** 类型
6. 填写：
   - **描述**：`EHExam App`
   - **Bundle ID**：选择 **"显式"**（Explicit），输入：`com.ehexam.EHExam.yuhuahuan.1769935853`
7. 点击 **"继续"**，然后 **"注册"**

### 步骤 5：完成 App 创建

1. 在 App Store Connect 中完成 App 创建表单
2. 点击 **"创建"**
3. 等待几秒钟，App 就会出现在你的 App 列表中

### 步骤 6：重新上传 IPA

1. 打开 **Transporter** 应用
2. 拖拽 `EHExam.ipa` 文件
3. 点击 **"交付"**
4. 现在应该可以成功上传了

## 替代方案：使用更简单的 Bundle ID

如果你不想使用带时间戳的 Bundle ID，可以修改为更简单的格式：

### 修改 Bundle ID

1. 编辑 `project.yml`：
   ```yaml
   targets:
     EHExam:
       settings:
         base:
           PRODUCT_BUNDLE_IDENTIFIER: com.yuhuahuan.EHExam  # 改为更简单的格式
   ```

2. 重新生成项目：
   ```bash
   cd /Users/yuhuahuan/code/EHExam
   rm -rf EHExam.xcodeproj
   xcodegen generate
   ```

3. 重新构建 IPA：
   ```bash
   ./build_for_testflight.sh
   ```

4. 在 App Store Connect 中创建使用新 Bundle ID 的 App

## 检查当前 Bundle ID

查看 IPA 文件中的 Bundle ID：
```bash
unzip -q -o EHExam.ipa -d /tmp/ipa_check
/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" /tmp/ipa_check/Payload/EHExam.app/Info.plist
```

## 常见问题

### Q: 上传时提示 "Missing required icon file. The bundle does not contain an app icon for iPhone / iPod Touch of exactly '120x120' pixels"
**A:** 这是图标配置问题。解决方法：
1. 运行修复脚本：
   ```bash
   ./fix_app_icon.sh
   ```
2. 或者手动生成 120x120 图标：
   ```bash
   cd Assets.xcassets/AppIcon.appiconset
   sips -z 120 120 icon_1024.png --out icon_120.png
   ```
3. 确保 `Contents.json` 中包含 120x120 的配置（60x60 @2x）
4. 重新构建项目并上传

### Q: 为什么 Bundle ID 这么长？
**A:** 这是因为 Xcode 自动签名时为了避免冲突，自动添加了后缀。这是正常的。

### Q: 可以修改 Bundle ID 吗？
**A:** 可以，但一旦在 App Store Connect 中创建了 App，就不能再更改 Bundle ID 了。所以建议：
- 如果还没创建 App，可以修改为更简单的格式
- 如果已经创建了 App，必须在 App Store Connect 中使用相同的 Bundle ID

### Q: 需要付费账号吗？
**A:** 是的，上传到 TestFlight 需要 Apple Developer Program 会员资格（$99/年）。

## 推荐流程

1. ✅ 在 App Store Connect 中创建 App（使用当前 Bundle ID）
2. ✅ 使用 Transporter 上传 IPA
3. ✅ 在 TestFlight 中添加测试员
