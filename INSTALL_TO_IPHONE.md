# 安装到iPhone - 详细指南

由于无法直接通过命令行创建完整的Xcode项目文件，这里提供两种方法将应用安装到你的iPhone。

## 方法1: 使用Xcode GUI（最简单，推荐）

### 步骤1: 创建Xcode项目

1. **打开Xcode**
2. **File** > **New** > **Project**
3. 选择 **iOS** > **App**
4. 填写信息：
   - Product Name: `EHExam`
   - Team: 选择你的Apple ID（如果没有，点击"Add Account"添加）
   - Organization Identifier: `com.yourname`（替换为你的）
   - Interface: `SwiftUI`
   - Language: `Swift`
   - 取消勾选 "Use Core Data"
5. 选择保存位置：**不要**选择 `/Users/yuhuahuan/code/EHExam`，选择**父目录**或**其他位置**
6. 点击 **Create**

### 步骤2: 移动项目到正确位置

创建项目后，Xcode会在你选择的位置创建 `EHExam` 文件夹。我们需要将我们已有的文件复制过去：

```bash
# 假设Xcode项目创建在 ~/Desktop/EHExam
# 复制所有Swift文件
cp -r /Users/yuhuahuan/code/EHExam/Models ~/Desktop/EHExam/
cp -r /Users/yuhuahuan/code/EHExam/Views ~/Desktop/EHExam/
cp -r /Users/yuhuahuan/code/EHExam/ViewModels ~/Desktop/EHExam/
cp -r /Users/yuhuahuan/code/EHExam/Services ~/Desktop/EHExam/
cp /Users/yuhuahuan/code/EHExam/EHExamApp.swift ~/Desktop/EHExam/
cp -r /Users/yuhuahuan/code/EHExam/resources ~/Desktop/EHExam/
```

### 步骤3: 在Xcode中添加文件

1. 在Xcode项目导航器中，**删除**自动生成的 `EHExamApp.swift`
2. 右键点击项目名称（蓝色图标）
3. 选择 **Add Files to "EHExam"...**
4. 添加以下文件/文件夹：
   - `EHExamApp.swift`
   - `Models/` 文件夹
   - `Views/` 文件夹
   - `ViewModels/` 文件夹
   - `Services/` 文件夹
   - `resources/part.txt`（**重要：确保勾选"Copy items if needed"和"Add to targets: EHExam"**）

### 步骤4: 配置代码签名

1. 在Xcode中，点击项目名称（蓝色图标）
2. 选择 **EHExam** target
3. 点击 **Signing & Capabilities** 标签
4. 勾选 **Automatically manage signing**
5. 在 **Team** 下拉菜单中选择你的Apple ID
6. 如果出现错误，点击 **Try Again**

### 步骤5: 连接iPhone

1. 用USB线连接iPhone到Mac
2. 在iPhone上，如果提示"信任此电脑"，点击**信任**
3. 输入iPhone密码确认
4. 在Xcode顶部，选择你的iPhone作为目标设备

### 步骤6: 构建并运行

1. 按 **⌘ + R** 或点击 **Run** 按钮
2. 如果是第一次安装，iPhone会提示"未受信任的开发者"
3. 在iPhone上：**设置** > **通用** > **VPN与设备管理** > 选择你的Apple ID > **信任**
4. 应用应该能正常启动

---

## 方法2: 使用命令行（高级用户）

如果你已经有Xcode项目文件，可以使用提供的脚本：

### 快速设置

```bash
cd /Users/yuhuahuan/code/EHExam
./quick_setup.sh
```

### 构建并安装

```bash
./build_and_install.sh
```

### 手动命令行安装

```bash
# 1. 构建
cd /Users/yuhuahuan/code/EHExam
xcodebuild -project EHExam.xcodeproj \
           -scheme EHExam \
           -configuration Release \
           -destination 'generic/platform=iOS' \
           clean build

# 2. 查找构建的.app
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "EHExam.app" -type d | head -1)

# 3. 安装到设备（需要设备UDID）
xcrun devicectl device install app --device <DEVICE_UDID> "$APP_PATH"
```

---

## 常见问题

### Q: "Could not open file" 错误

**原因**: Xcode无法直接打开文件夹，需要打开 `.xcodeproj` 文件

**解决**:
1. 在Finder中找到 `EHExam.xcodeproj` 文件
2. 双击打开，或
3. 在Xcode中选择 **File** > **Open** > 选择 `.xcodeproj` 文件

### Q: 代码签名错误

**错误信息**: "No signing certificate" 或 "No provisioning profile"

**解决**:
1. 在Xcode中，项目 > Signing & Capabilities
2. 勾选 "Automatically manage signing"
3. 选择你的Apple ID作为Team
4. 如果还没有Apple ID，去 [appleid.apple.com](https://appleid.apple.com) 注册

### Q: 设备未显示在Xcode中

**解决**:
1. 确保iPhone已解锁
2. 确保USB线连接正常
3. 在iPhone上信任此电脑
4. 尝试重新连接USB线
5. 在Xcode中，**Window** > **Devices and Simulators** 检查设备状态

### Q: 应用安装后无法打开

**解决**:
1. 在iPhone上：**设置** > **通用** > **VPN与设备管理**
2. 找到你的开发者证书
3. 点击 **信任**

### Q: 无法读取part.txt文件

**解决**:
1. 确保 `part.txt` 已添加到项目的 "Copy Bundle Resources"
2. 检查文件名大小写（应该是 `part.txt`）
3. 在Xcode中：项目 > Build Phases > Copy Bundle Resources，确认文件在列表中

---

## 推荐工作流程

1. ✅ 使用Xcode GUI创建项目（最简单）
2. ✅ 添加所有文件到项目
3. ✅ 配置代码签名
4. ✅ 连接iPhone
5. ✅ 运行应用（⌘+R）

---

## 需要帮助？

如果遇到问题：
1. 查看Xcode控制台的错误信息
2. 检查所有文件是否已正确添加
3. 确认代码签名配置正确
4. 参考 `SETUP_GUIDE.md` 获取详细步骤
