# 学习吧 - 英语考试学习应用

一个功能完整的 iOS 英语考试模拟学习应用，支持题目练习、错题本、收藏、单词本、自定义单词本等功能。

## 功能特性

### 题目练习
- 从 `part.txt` 或上传试卷读取题目
- 选择题形式答题，支持正序/乱序模式
- 提交答案自动核对，支持看答案、智能解析（DeepSeek API）
- 翻译、语音朗读

### 学习管理
- **错题本**：答错自动加入，可练习错题
- **收藏**：收藏题目便于复习
- **单词本**：题目核心词 + 用户收藏词，支持单行删除、点击调用 DeepSeek 智能解析（词根词缀拆解记忆）
- **自定义单词本**：试卷解析出的超纲词（超出初中范围），格式含原文、译文、记忆要点

### 首页与统计
- **今日概览**：当天做题数、对错、学词数
- **学习数据**：日历网格显示 16 天，点击日期查看当日详情

### 设置
- 正序/乱序模式切换
- DeepSeek API 配置
- 试卷管理：上传试卷并解析、解析单词（提取超纲词）；解析时切到其他页面仍继续，完成后有提示

## 项目结构

```
ehexam-2/
├── EHExamApp.swift           # 应用入口
├── Models/
│   ├── Question.swift        # 题目数据模型
│   └── ParsedWord.swift      # 解析出的超纲词模型
├── Views/
│   ├── ContentView.swift     # 主视图（Tab 导航）
│   ├── HomeView.swift        # 首页（今日学习、学习类型）
│   ├── QuestionView.swift    # 题目练习视图
│   ├── WrongAnswerBookView   # 错题本
│   ├── FavoriteView.swift    # 收藏
│   ├── WordBookView.swift    # 单词本
│   ├── CustomWordBookView.swift  # 自定义单词本（超纲词）
│   ├── SettingsView.swift    # 设置
│   └── ...
├── ViewModels/
│   └── QuestionViewModel.swift
├── Services/
│   ├── QuestionParser.swift  # 题目解析
│   ├── ExamParserService.swift   # 试卷解析（API）
│   ├── DeepSeekParseService.swift  # DeepSeek 智能解析
│   ├── ProcessingService.swift  # 全局解析进度（切页继续、完成提示）
│   ├── StorageService.swift  # 本地存储
│   ├── SpeechService.swift   # 语音朗读
│   └── TranslationService.swift
└── resources/
    └── part.txt              # 题目文件
```

## 快速开始

### 命令行构建与安装

```bash
cd /path/to/ehexam-2

# 构建
xcodebuild -project EHExam.xcodeproj -scheme EHExam \
  -configuration Debug -destination 'generic/platform=iOS' \
  -derivedDataPath ./build clean build

# 安装到设备（需连接 iPhone）
APP_PATH=$(find ./build -name "EHExam.app" -type d | head -1)
xcrun devicectl device install app --device <设备UDID> "$APP_PATH"
```

### 配置 DeepSeek API（可选）
在「设置 → DeepSeek API 配置」中输入 API Key，用于：
- 题目智能解析
- 单词词根词缀拆解
- 试卷解析、解析单词

## 题目文件格式

`part.txt` 需包含：
- 题号（如 `第1题`）
- 原题、选项（A/B/C/D）
- 你的答案、译文
- 【考点·高效记忆】、【解析·秒选思路】
- 核心词（音标 + 拆解记忆）

## 系统要求

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## 文档

- `INSTALL_WITHOUT_XCODE.md`：不通过 Xcode 安装到 iPhone
- `TESTFLIGHT_BUILD_GUIDE.md`：TestFlight 构建指南
- `CLEANUP_GUIDE.md`：项目清理指南



## 许可证

本项目仅供学习使用。
