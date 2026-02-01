# EHExam - 英语考试学习应用

一个功能完整的iOS英语考试模拟学习应用，支持题目练习、错题本、收藏等功能。

## 功能特性

✅ **题目练习**
- 从part.txt文件读取题目
- 选择题形式答题
- 提交答案自动核对
- 直接查看答案功能

✅ **错题管理**
- 答错的题目自动加入错题本
- 错题本列表查看
- 从错题本跳转练习

✅ **收藏功能**
- 点击收藏图标收藏题目
- 收藏列表管理

✅ **导航功能**
- 上一题/下一题切换
- 题目进度显示

## 项目结构

```
EHExam/
├── EHExamApp.swift          # 应用入口
├── Models/
│   └── Question.swift       # 题目数据模型
├── Views/
│   ├── ContentView.swift    # 主视图（Tab导航）
│   ├── QuestionView.swift   # 题目练习视图
│   ├── WrongAnswerBookView.swift  # 错题本视图
│   └── FavoriteView.swift   # 收藏视图
├── ViewModels/
│   └── QuestionViewModel.swift    # 题目视图模型
├── Services/
│   ├── QuestionParser.swift # 题目解析器
│   └── StorageService.swift # 存储服务（错题、收藏）
└── resources/
    └── part.txt             # 题目文件
```

## 安装和设置

### 1. 创建Xcode项目

1. 打开Xcode，选择 "Create a new Xcode project"
2. 选择 "iOS" > "App"
3. 填写项目信息：
   - Product Name: `EHExam`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - 取消勾选 "Use Core Data"

### 2. 添加文件到项目

将以下文件添加到Xcode项目：

- `EHExamApp.swift` → 替换自动生成的App文件
- 创建文件夹结构并添加所有Swift文件：
  - `Models/Question.swift`
  - `Views/` 下的所有文件
  - `ViewModels/QuestionViewModel.swift`
  - `Services/` 下的所有文件

### 3. 添加资源文件

**重要：** 必须将 `resources/part.txt` 添加到Xcode项目中：

1. 在Xcode中，右键点击项目导航器
2. 选择 "Add Files to EHExam..."
3. 选择 `resources/part.txt` 文件
4. **确保勾选 "Copy items if needed"**
5. **确保在 "Add to targets" 中勾选 EHExam**
6. 点击 "Add"

### 4. 配置Info.plist（如果需要）

如果遇到文件读取权限问题，在 `Info.plist` 中添加：

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## 题目文件格式

`part.txt` 文件应遵循以下格式：

```
第1题

原题：Doctor Green went on with his experiment...

选项：
A) for the sake of
B) but for
C) regardless of
D) in the light of
你的答案：C
核对结果：正确
译文：格林博士不顾周围的争议...

【考点·高效记忆】
介词短语辨析："不顾/不管"选 regardless of
口诀：不顾争议、不管情况 → regardless of

【解析·秒选思路】
看到"继续做某事 + 空格 + 争议/反对"，直接选 regardless of（不顾）。

核心词（音标+拆解记忆）

• regardless /rɪˈɡɑːdləs/：re-（相反）+ gard（注意）+ -less（无）→ 不注意 → 不顾

• debate /dɪˈbeɪt/：de-（强调）+ bat（打）→ 唇枪舌战 → 辩论
第2题
...
```

## 使用说明

### 考试模式
1. 打开应用，默认进入"考试"标签
2. 阅读题目，选择答案
3. 点击"提交"按钮核对答案
   - 答错的题目会自动加入错题本
4. 或点击"看答案"直接查看解析
5. 使用"上一题"/"下一题"按钮导航

### 错题本
1. 切换到"错题本"标签
2. 查看所有答错的题目
3. 点击题目查看详细解析
4. 点击"练习此题"返回考试模式

### 收藏
1. 在题目右上角点击⭐图标收藏
2. 切换到"收藏"标签查看收藏的题目
3. 再次点击⭐取消收藏

## 技术栈

- **SwiftUI**: 现代化UI框架
- **MVVM架构**: 清晰的代码结构
- **UserDefaults**: 本地数据存储（错题本、收藏）
- **文件解析**: 自定义解析器读取题目文件

## 系统要求

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## 注意事项

1. **资源文件位置**: 确保 `part.txt` 已正确添加到Xcode项目的Bundle中
2. **文件编码**: 确保 `part.txt` 使用UTF-8编码
3. **题目格式**: 严格按照格式编写题目，否则可能解析失败

## 故障排除

### 问题：无法读取题目文件
- 检查 `part.txt` 是否已添加到Xcode项目
- 检查文件是否在 "Copy Bundle Resources" 中
- 查看控制台错误信息

### 问题：题目解析失败
- 检查 `part.txt` 格式是否正确
- 确保每道题都有完整的结构
- 检查文件编码是否为UTF-8

## 开发计划

- [ ] 添加题目搜索功能
- [ ] 添加学习统计（正确率、练习次数）
- [ ] 添加随机练习模式
- [ ] 支持多套题目切换
- [ ] 添加题目难度标记

## 许可证

本项目仅供学习使用。
