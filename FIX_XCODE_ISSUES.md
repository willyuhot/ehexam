# 修复 Xcode 构建问题指南

## 问题 1: 签名需要开发团队

### 解决方案 A: 在 Xcode 中设置（推荐）

1. 打开 `EHExam.xcodeproj`
2. 在左侧项目导航器中，点击最顶部的 **蓝色项目图标**（EHExam）
3. 在中间面板，选择 **EHExam** target（不是项目）
4. 点击 **"Signing & Capabilities"** 标签
5. 在 **"Signing"** 部分：
   - 如果**有 Apple Developer 账号**：
     - 勾选 **"Automatically manage signing"**
     - 在 **"Team"** 下拉菜单中选择你的团队
   - 如果**没有 Apple Developer 账号**（仅用于模拟器）：
     - 取消勾选 **"Automatically manage signing"**
     - 或者选择 **"Team: None"**（如果可用）

### 解决方案 B: 仅用于模拟器（不需要签名）

如果你只想在模拟器中运行，可以：

1. 在 Xcode 中，选择 **"Any iOS Simulator"** 作为目标设备
2. 模拟器不需要签名，可以直接运行

## 问题 2: Cannot find 'AnswerDetailView' in scope

### 解决方案

项目已经包含了 `AnswerDetailView.swift`，如果仍然报错：

1. **清理构建缓存**：
   - 在 Xcode 中按 `Cmd + Shift + K`（Product > Clean Build Folder）

2. **重新构建**：
   - 按 `Cmd + B`（Product > Build）

3. **如果还是不行，手动添加文件**：
   - 在 Xcode 项目导航器中，右键点击 `Views` 文件夹
   - 选择 **"Add Files to EHExam..."**
   - 导航到 `Views/AnswerDetailView.swift`
   - 确保勾选 **"Copy items if needed"** 和 **"Add to targets: EHExam"**
   - 点击 **"Add"**

4. **验证文件在项目中**：
   - 在项目导航器中，应该能看到 `Views/AnswerDetailView.swift`
   - 如果看不到，说明文件没有正确添加到项目

## 快速修复脚本

运行以下命令自动修复：

```bash
./fix_build_issues.sh
```

这个脚本会：
- 清理构建缓存
- 重新生成项目
- 验证文件存在
- 提供详细的修复说明

## 验证修复

修复后，在 Xcode 中：

1. 按 `Cmd + Shift + K` 清理
2. 按 `Cmd + B` 构建
3. 应该没有错误了

如果还有问题，请检查：
- Xcode 版本是否兼容（15.4+）
- 所有 Swift 文件是否都在项目中
- 项目文件是否损坏（可以删除 `.xcodeproj` 重新生成）
