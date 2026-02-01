# 🚀 最简单安装方法

## 一键自动安装

我已经修复了项目格式问题，现在只需要：

### 方法1: 使用自动化脚本（推荐）

```bash
cd /Users/yuhuahuan/code/EHExam
./auto_install.sh
```

脚本会自动：
- ✅ 验证项目文件
- ✅ 检查连接的iPhone
- ✅ 打开Xcode项目
- ✅ 提供详细指导

### 方法2: 手动打开（如果脚本有问题）

1. **打开项目**
   ```bash
   cd /Users/yuhuahuan/code/EHExam
   open EHExam.xcodeproj
   ```

2. **在Xcode中配置签名**（必须）
   - 点击左侧的 **EHExam**（蓝色图标）
   - 选择 **EHExam** target
   - 点击 **Signing & Capabilities**
   - 勾选 ✅ **Automatically manage signing**
   - 选择你的 **Apple ID** 作为 Team

3. **连接iPhone**
   - 用USB连接iPhone
   - 在iPhone上点击"信任此电脑"
   - 在Xcode顶部选择你的iPhone

4. **运行应用**
   - 按 **⌘+R** 运行

5. **信任开发者**（首次）
   - iPhone: 设置 > 通用 > VPN与设备管理 > 信任你的证书

## ✅ 项目已修复

- ✅ 项目格式已修复（兼容Xcode 15.4）
- ✅ 所有文件已包含
- ✅ 资源文件已配置
- ✅ 可以直接打开使用

## 如果还有问题

运行诊断：
```bash
cd /Users/yuhuahuan/code/EHExam
xcodebuild -project EHExam.xcodeproj -list
```

如果显示项目信息，说明项目正常！
