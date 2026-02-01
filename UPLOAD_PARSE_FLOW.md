# 上传导入解析功能 - 流程说明

## 从 iPhone 选择文件后的完整流程

### 1. 选择文件（我们 → 试卷管理 → 上传试卷并解析）

- **前置条件**：已在「DeepSeek API配置」中保存 API Key，否则按钮不可点。
- 点击「上传试卷并解析」后，系统会弹出 **文件选择器**（Files / iCloud / 本机）。
- **允许的类型**：`.text`、`.plainText`、`.data`（实际使用中主要是 **TXT 纯文本** 能正常解析）。
- **Word (.doc / .docx)**：可以选，但内容是二进制，按 UTF-8 读会失败，界面会提示：「无法读取为文本。请使用 TXT 格式；Word 文档请先另存为「纯文本」或 .txt」。

### 2. 选中文件之后

1. **申请访问权限**  
   对选中的 `URL` 调用 `startAccessingSecurityScopedResource()`，以便访问 App 沙盒外的文件（如「文件」App 里的文档）。读取结束后在后台任务里调用 `stopAccessingSecurityScopedResource()`。

2. **读取内容**  
   在后台线程用 `String(contentsOf: url, encoding: .utf8)` 读取：
   - **TXT（UTF-8）**：成功得到字符串。
   - **空文件**：会提示「文件为空，请选择有内容的 TXT 文件」。
   - **Word 等非纯文本**：抛错，提示使用 TXT 或从 Word 另存为纯文本。

3. **进度提示**  
   界面会依次显示：
   - 「正在读取文件...」
   - 「正在解析试卷...」 / 「正在连接并解析试卷...」
   - 「正在解析返回内容...」
   - 「已解析出 N 道题，正在验证...」
   - 「已解析 N 道题」

4. **调用 DeepSeek 解析**  
   - 把读到的**整段文本**发给 DeepSeek API。
   - 要求模型按固定格式输出：题号、原题、选项 A/B/C/D、答案、译文、考点、解析、核心词等。
   - 返回的**纯文本**再用 `QuestionParser` 解析成多道 `Question`。
   - 校验：每题必有 4 个选项、答案在 A/B/C/D 中，不合格的题会被过滤掉。

5. **加入题库**  
   - 通过 `viewModel.addQuestionsToBank(questions)`：
     - 新题的 ID 会加入「导入的题」集合（`StorageService.addImportedQuestionIds`），首页「导入的题」可筛选到。
     - 题目列表会追加这批题（`questions.append(contentsOf:)`），并触发一次 `loadQuestions()` 刷新列表。
     - **持久化**：新题会**追加**写入 App 的 **Documents 目录** 下的 `imported_questions.txt`（iPhone 上 Bundle 只读，不能写 part.txt，所以导入题单独写这里）。

6. **结束**  
   - 成功：提示「已解析 N 道题并加入题库」。
   - 失败：提示解析失败或网络错误等信息。

### 3. 下次启动 App 后

- **加载题目**时会把两部分拼在一起：
  1. **默认题库**：从 Bundle 的 `part.txt`（或开发时的 resources/part.txt）读取。
  2. **导入题目**：从 Documents 的 `imported_questions.txt` 读取（若存在）。
- 合并后再做解析、乱序/正序、按学习类型筛选等，所以**导入的题会一直保留**，不会因为重启而丢失。

### 4. 建议用法

- **推荐**：使用 **TXT 纯文本**（UTF-8），把试卷内容贴进去或存成 .txt 再选。
- **Word**：在电脑或手机上把 Word **另存为「纯文本」或 .txt**，再用本功能选择该 TXT 文件。

---

## 涉及代码位置

| 步骤           | 文件 / 位置 |
|----------------|-------------|
| 选择文件、进度 | `Views/SettingsView.swift`：`fileImporter`、`processExamFile`、`handleFileSelection` |
| 安全作用域     | `processExamFile` 内 `startAccessingSecurityScopedResource` / `stopAccessingSecurityScopedResource` |
| API 解析       | `Services/ExamParserService.swift`：`parseExam`、`buildPrompt`、`parseQuestionsFromResponse`、`validateQuestions` |
| 加入题库与持久化 | `ViewModels/QuestionViewModel.swift`：`addQuestionsToBank`、`saveQuestionsToFile`（写入 Documents/imported_questions.txt） |
| 启动时合并加载 | `ViewModels/QuestionViewModel.swift`：`loadQuestions` 中合并 Bundle part.txt + Documents/imported_questions.txt |
