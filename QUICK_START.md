# 🚀 快速开始 - 安装到iPhone

## ✅ 项目已自动生成！

Xcode项目文件已经创建完成。现在按照以下步骤安装到你的iPhone：

## 步骤1: 打开Xcode项目

项目文件应该已经在Xcode中自动打开了。如果没有：

1. 打开 **Finder**
2. 导航到 `/Users/yuhuahuan/code/EHExam`
3. 双击 `EHExam.xcodeproj` 文件

## 步骤2: 配置代码签名

1. 在Xcode左侧项目导航器中，点击最顶部的 **EHExam**（蓝色图标）
2. 在中间面板，选择 **EHExam** target（在TARGETS下）
3. 点击 **Signing & Capabilities** 标签
4. 勾选 ✅ **Automatically manage signing**
5. 在 **Team** 下拉菜单中：
   - 如果已有Apple ID，选择它
   - 如果没有，点击 **Add Account...** 添加你的Apple ID
   - 如果没有Apple ID，去 [appleid.apple.com](https://appleid.apple.com) 注册一个（免费）

## 步骤3: 连接iPhone

1. 用USB线将iPhone连接到Mac
2. 在iPhone上，如果出现"信任此电脑"提示，点击 **信任**
3. 输入iPhone密码确认
4. 在Xcode顶部工具栏，点击设备选择器（显示"Any iOS Device"的地方）
5. 选择你的iPhone

## 步骤4: 运行应用

1. 按 **⌘ + R** 或点击左上角的 **▶️ Run** 按钮
2. Xcode会开始构建应用
3. 构建完成后，应用会自动安装到iPhone并启动

## 步骤5: 信任开发者（首次安装）

如果是第一次安装，iPhone会提示"未受信任的开发者"：

1. 在iPhone上，打开 **设置** 应用
2. 进入 **通用** > **VPN与设备管理**（或 **设备管理**）
3. 找到你的Apple ID/开发者证书
4. 点击它，然后点击 **信任**
5. 返回主屏幕，打开 **EHExam** 应用

## 🎉 完成！

应用现在应该已经在你的iPhone上运行了！

---

## 如果遇到问题

### 问题: "No signing certificate"

**解决**: 确保在Signing & Capabilities中选择了Team，并且勾选了"Automatically manage signing"

### 问题: 设备未显示

**解决**: 
- 确保iPhone已解锁
- 确保USB线连接正常
- 在iPhone上信任此电脑
- 尝试重新连接USB线

### 问题: 应用无法读取题目

**解决**: 
- 在Xcode中，项目 > Build Phases > Copy Bundle Resources
- 确认 `part.txt` 在列表中
- 如果不在，点击 **+** 添加 `resources/part.txt`

### 问题: 编译错误

**解决**:
- 查看Xcode底部的错误信息
- 确保所有Swift文件都在项目中
- 尝试 **Product** > **Clean Build Folder** (⌘ + Shift + K)
- 重新构建

---

## 需要帮助？

查看以下文档获取更多信息：
- `INSTALL_TO_IPHONE.md` - 详细安装指南
- `SETUP_GUIDE.md` - 完整设置步骤
- `README.md` - 项目说明
