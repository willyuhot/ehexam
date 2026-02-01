# EHExam iOS应用 - 快速设置指南

## 步骤1: 创建Xcode项目

1. 打开 **Xcode**
2. 选择 **File** > **New** > **Project**
3. 选择 **iOS** > **App**
4. 填写项目信息：
   - **Product Name**: `EHExam`
   - **Team**: 选择你的开发团队（如果没有，选择"None"）
   - **Organization Identifier**: `com.yourname` (替换为你的标识符)
   - **Interface**: `SwiftUI`
   - **Language**: `Swift`
   - **Storage**: `None` (取消勾选Use Core Data)
   - **Include Tests**: 可选
5. 选择保存位置，点击 **Create**

## 步骤2: 添加项目文件

### 2.1 替换App入口文件

1. 在Xcode项目导航器中，找到 `EHExamApp.swift`（自动生成的文件）
2. 删除它
3. 将项目中的 `EHExamApp.swift` 拖拽到Xcode项目中
4. 确保勾选 **Copy items if needed** 和 **Add to targets: EHExam**

### 2.2 创建文件夹结构

在Xcode项目导航器中：

1. 右键点击 `EHExam` 文件夹（蓝色图标）
2. 选择 **New Group**，创建以下文件夹：
   - `Models`
   - `Views`
   - `ViewModels`
   - `Services`

### 2.3 添加Swift文件

将以下文件分别添加到对应的文件夹：

**Models文件夹:**
- `Models/Question.swift`

**Views文件夹:**
- `Views/ContentView.swift`
- `Views/QuestionView.swift`
- `Views/WrongAnswerBookView.swift`
- `Views/FavoriteView.swift`

**ViewModels文件夹:**
- `ViewModels/QuestionViewModel.swift`

**Services文件夹:**
- `Services/QuestionParser.swift`
- `Services/StorageService.swift`

**添加方法:**
1. 在Finder中找到文件
2. 拖拽到Xcode对应的文件夹
3. 确保勾选 **Copy items if needed** 和 **Add to targets: EHExam**

## 步骤3: 添加资源文件（重要！）

这是最关键的一步：

1. 在Xcode项目导航器中，右键点击 `EHExam` 文件夹
2. 选择 **Add Files to "EHExam"...**
3. 导航到 `resources/part.txt` 文件
4. **重要选项:**
   - ✅ 勾选 **Copy items if needed**
   - ✅ 在 **Add to targets** 中勾选 **EHExam**
   - ✅ 选择 **Create groups**（不是Create folder references）
5. 点击 **Add**

### 验证资源文件已添加

1. 在Xcode中，点击项目名称（蓝色图标）
2. 选择 **EHExam** target
3. 点击 **Build Phases** 标签
4. 展开 **Copy Bundle Resources**
5. 确认 `part.txt` 在列表中
6. 如果不在，点击 **+** 按钮添加

## 步骤4: 配置项目设置

### 4.1 设置最低iOS版本

1. 选择项目名称（蓝色图标）
2. 选择 **EHExam** target
3. 在 **General** 标签中
4. 设置 **Minimum Deployments** 为 **iOS 15.0** 或更高

### 4.2 配置Info.plist（如果需要）

如果遇到文件读取问题：

1. 在项目导航器中找到 `Info.plist`
2. 右键选择 **Open As** > **Source Code**
3. 添加以下内容（如果不存在）：

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## 步骤5: 构建和运行

1. 在Xcode顶部选择目标设备（模拟器或真机）
2. 按 **⌘ + R** 或点击 **Run** 按钮
3. 应用应该能正常启动

## 常见问题解决

### 问题1: "Cannot find 'Question' in scope"

**解决方案:**
- 确保所有Swift文件都已添加到target
- 检查文件是否在正确的文件夹中
- 尝试 **Product** > **Clean Build Folder** (⌘ + Shift + K)
- 重新构建项目

### 问题2: "Cannot find 'part.txt' in bundle"

**解决方案:**
1. 确认 `part.txt` 在 **Copy Bundle Resources** 中
2. 检查文件名是否正确（区分大小写）
3. 尝试删除并重新添加文件
4. 清理构建文件夹后重新构建

### 问题3: 题目解析失败

**解决方案:**
1. 检查 `part.txt` 文件格式是否正确
2. 确保文件使用UTF-8编码
3. 查看Xcode控制台的错误信息
4. 检查文件是否为空或损坏

### 问题4: 编译错误

**解决方案:**
1. 确保所有文件都已正确添加到项目
2. 检查Swift版本兼容性（需要Swift 5.5+）
3. 确保iOS部署目标设置为15.0+
4. 查看Xcode的错误提示并修复

## 测试应用

应用启动后，你应该看到：

1. **考试标签**: 显示第一道题目
2. **错题本标签**: 显示空状态（还没有错题）
3. **收藏标签**: 显示空状态（还没有收藏）

尝试以下操作：
- 选择答案并提交
- 点击"看答案"
- 点击收藏图标
- 使用上一题/下一题按钮

## 下一步

- 自定义UI颜色和样式
- 添加更多功能（搜索、统计等）
- 优化解析器以支持更多格式
- 添加题目分类功能

## 需要帮助？

如果遇到问题：
1. 检查Xcode控制台的错误信息
2. 确认所有文件都已正确添加
3. 验证 `part.txt` 文件格式
4. 查看README.md获取更多信息
