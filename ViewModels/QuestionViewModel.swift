//
//  QuestionViewModel.swift
//  EHExam
//
//  ViewModel for managing questions and exam state
//

import Foundation
import SwiftUI

// 答案结果枚举
enum AnswerResult {
    case correct
    case wrong(correctAnswer: String)
    
    var isCorrect: Bool {
        if case .correct = self {
            return true
        }
        return false
    }
}

// 学习类型：错题 | 默认题 | 导入的题 | 收藏题
enum LearningMode: String, CaseIterable {
    case `default` = "默认的题"
    case wrong = "错题"
    case imported = "导入的题"
    case favorite = "收藏题"
    
    var icon: String {
        switch self {
        case .default: return "book.fill"
        case .wrong: return "exclamationmark.triangle.fill"
        case .imported: return "square.and.arrow.down.fill"
        case .favorite: return "star.fill"
        }
    }
}

// 选项映射结构：记录原始选项到新选项的映射
struct OptionMapping {
    let originalToNew: [String: String] // 原始选项 -> 新选项 (如 "A" -> "C")
    let newToOriginal: [String: String] // 新选项 -> 原始选项 (如 "C" -> "A")
    let shuffledOptions: [String: String] // 乱序后的选项字典
    let shuffledKeys: [String] // 乱序后的选项键顺序 (如 ["C", "A", "D", "B"])
}

class QuestionViewModel: ObservableObject {
    @Published var questions: [Question] = [] // 原始题目列表（已乱序）
    @Published var currentQuestionIndex: Int = 0
    @Published var selectedAnswer: String? = nil
    @Published var showAnswer: Bool = false
    @Published var answerResult: AnswerResult? = nil // 新增：答案结果
    @Published var translatedQuestion: String? = nil // 翻译后的原题
    @Published var translatedOptions: [String: String] = [:] // 翻译后的选项
    @Published var isTranslating: Bool = false // 翻译中状态
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil
    @Published var learningMode: LearningMode = .default
    
    // 存储每个题目的选项映射关系
    private var optionMappings: [Int: OptionMapping] = [:]
    
    // 记录已统计的题目ID，避免重复计数
    private var countedQuestionIds: Set<Int> = []
    
    // 是否启用乱序功能（通过设置服务动态控制）
    private var isShuffleEnabled: Bool {
        return SettingsService.shared.isShuffleEnabled
    }
    
    private let storageService = StorageService.shared
    
    var currentQuestion: Question? {
        guard currentQuestionIndex >= 0 && currentQuestionIndex < questions.count else {
            return nil
        }
        return questions[currentQuestionIndex]
    }
    
    // 获取当前题目的乱序选项键（用于显示）
    var currentShuffledOptionKeys: [String] {
        guard let question = currentQuestion,
              let mapping = optionMappings[question.id] else {
            return ["A", "B", "C", "D"] // 默认顺序
        }
        return mapping.shuffledKeys
    }
    
    // 获取当前题目的乱序选项（用于显示）
    var currentShuffledOptions: [String: String] {
        guard let question = currentQuestion,
              let mapping = optionMappings[question.id] else {
            return currentQuestion?.options ?? [:]
        }
        return mapping.shuffledOptions
    }
    
    // 获取当前题目的正确选项（乱序后的）
    var currentCorrectAnswer: String? {
        guard let question = currentQuestion,
              let mapping = optionMappings[question.id] else {
            return currentQuestion?.correctAnswer
        }
        // 将原始正确答案转换为乱序后的选项
        return mapping.originalToNew[question.correctAnswer]
    }
    
    var canGoPrevious: Bool {
        return currentQuestionIndex > 0
    }
    
    var canGoNext: Bool {
        return currentQuestionIndex < questions.count - 1
    }
    
    var isFavorite: Bool {
        guard let question = currentQuestion else { return false }
        return storageService.isFavorite(question.id)
    }
    
    init() {
        questions = []
        optionMappings = [:]
        loadQuestions()
    }
    
    func setLearningMode(_ mode: LearningMode) {
        learningMode = mode
    }
    
    func loadQuestions() {
        loadQuestions(mode: learningMode)
    }
    
    func loadQuestions(mode: LearningMode) {
        learningMode = mode
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // 1) 默认题库：Bundle part.txt 或开发环境 resources
            var baseContent: String?
            if let path = Bundle.main.path(forResource: "part", ofType: "txt") {
                baseContent = try? String(contentsOfFile: path, encoding: .utf8)
            }
            if baseContent == nil {
                let resourcesPath = FileManager.default.currentDirectoryPath + "/resources/part.txt"
                if FileManager.default.fileExists(atPath: resourcesPath) {
                    baseContent = try? String(contentsOfFile: resourcesPath, encoding: .utf8)
                }
            }
            if baseContent == nil {
                let absolutePath = "/Users/yuhuahuan/code/EHExam/resources/part.txt"
                if FileManager.default.fileExists(atPath: absolutePath) {
                    baseContent = try? String(contentsOfFile: absolutePath, encoding: .utf8)
                }
            }
            
            // 2) 导入题目：Documents/imported_questions.txt（iPhone 上持久化）
            var importedContent: String?
            let importedPath = Self.importedQuestionsFilePath
            if FileManager.default.fileExists(atPath: importedPath) {
                importedContent = try? String(contentsOfFile: importedPath, encoding: .utf8)
            }
            
            // 3) 合并：默认题库 + 导入题目
            var content = baseContent ?? ""
            if let imp = importedContent, !imp.isEmpty {
                if !content.isEmpty { content += "\n\n" }
                content += imp
            }
            
            if !content.isEmpty {
                var parsedQuestions = QuestionParser.parseQuestions(from: content)
                
                var mappings: [Int: OptionMapping] = [:]
                
                // 根据配置决定是否乱序
                if self.isShuffleEnabled {
                    // 1. 对题目列表进行乱序
                    parsedQuestions.shuffle()
                    print("✅ 题目已乱序，共 \(parsedQuestions.count) 道题")
                    
                    // 2. 对每个题目的选项进行乱序，并创建映射关系
                    for question in parsedQuestions {
                        let mapping = self.shuffleOptions(for: question)
                        mappings[question.id] = mapping
                        // 调试：打印第一题的乱序结果
                        if question.id == parsedQuestions.first?.id {
                            print("✅ 题目 \(question.id) 选项已乱序: \(mapping.shuffledKeys)")
                            print("   原始答案: \(question.correctAnswer) -> 乱序后答案: \(mapping.originalToNew[question.correctAnswer] ?? "未知")")
                        }
                    }
                } else {
                    // 正序模式：不乱序，创建空的映射（使用原始顺序）
                    print("✅ 正序模式，共 \(parsedQuestions.count) 道题")
                    for question in parsedQuestions {
                        // 创建保持原始顺序的映射
                        let mapping = self.createIdentityMapping(for: question)
                        mappings[question.id] = mapping
                    }
                }
                
                // 按学习类型筛选
                var filtered = parsedQuestions
                switch self.learningMode {
                case .wrong:
                    let wrongIds = Set(self.storageService.getWrongAnswers())
                    filtered = parsedQuestions.filter { wrongIds.contains($0.id) }
                case .favorite:
                    let favIds = Set(self.storageService.getFavorites())
                    filtered = parsedQuestions.filter { favIds.contains($0.id) }
                case .imported:
                    let importedIds = Set(self.storageService.getImportedQuestionIds())
                    filtered = parsedQuestions.filter { importedIds.contains($0.id) }
                case .default:
                    break
                }
                
                DispatchQueue.main.async {
                    self.questions = filtered
                    self.optionMappings = mappings
                    self.isLoading = false
                    if filtered.isEmpty {
                        switch self.learningMode {
                        case .wrong: self.errorMessage = "暂无错题，去做题吧"
                        case .favorite: self.errorMessage = "暂无收藏，点击题目右上角⭐收藏"
                        case .imported: self.errorMessage = "暂无导入的题，请在「我们」中上传试卷"
                        case .default: self.errorMessage = "未能解析到题目，请检查文件格式"
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "无法读取题目文件，请确保part.txt在Resources文件夹中"
                }
            }
        }
    }
    
    func selectAnswer(_ answer: String) {
        selectedAnswer = answer
        
        // 立即显示对错结果（但不记录统计，等提交时再记录）
        if let question = currentQuestion {
            // 使用乱序后的正确答案进行比较
            let correctAnswer = currentCorrectAnswer ?? question.correctAnswer
            
            if answer == correctAnswer {
                answerResult = .correct
            } else {
                // 显示乱序后的正确答案
                answerResult = .wrong(correctAnswer: correctAnswer)
                // 如果答错了，加入错题本（但不记录统计，等提交时再记录）
                storageService.addWrongAnswer(question.id)
                // 确保保存
                UserDefaults.standard.synchronize()
            }
            
            // 选择答案后立即翻译（显示译文）
            translateCurrentQuestion()
        }
    }
    
    func submitAnswer() {
        guard let question = currentQuestion,
              let selected = selectedAnswer else { return }
        
        showAnswer = true
        
        // 如果还没有显示结果，现在显示
        if answerResult == nil {
            let correctAnswer = currentCorrectAnswer ?? question.correctAnswer
            
            if selected == correctAnswer {
                answerResult = .correct
            } else {
                answerResult = .wrong(correctAnswer: correctAnswer)
                storageService.addWrongAnswer(question.id)
            }
        }
        
        // 记录统计（只记录一次，避免重复计数）
        if !countedQuestionIds.contains(question.id) {
            let correctAnswer = currentCorrectAnswer ?? question.correctAnswer
            if selected == correctAnswer {
                storageService.addCorrectAnswer()
                storageService.addCorrectForQuestion(question.id)
            } else {
                storageService.addWrongAnswerCount()
                storageService.addWrongForQuestion(question.id)
            }
            countedQuestionIds.insert(question.id)
        }
    }
    
    func showAnswerDirectly() {
        showAnswer = true
        translateCurrentQuestion()
    }
    
    // 翻译当前题目
    func translateCurrentQuestion() {
        guard let question = currentQuestion else { return }
        
        // 如果已经在翻译中，不重复翻译
        if isTranslating {
            return
        }
        
        isTranslating = true
        translatedQuestion = nil
        translatedOptions = [:]
        
        // 翻译原题
        TranslationService.shared.translate(question.questionText, from: "en", to: "zh-Hans") { [weak self] translated in
            guard let self = self else { return }
            // 解码URL编码的字符
            var decodedTranslated: String?
            if let translated = translated {
                decodedTranslated = self.decodeURLEncoding(translated)
                // 检查翻译结果是否为中文，如果不是中文（可能是英文），使用原始译文
                if let decoded = decodedTranslated, self.isEnglishText(decoded) {
                    decodedTranslated = nil // 翻译失败，使用原始译文
                }
            }
            // 如果翻译失败或返回英文，使用原始译文
            let finalTranslation = decodedTranslated ?? self.decodeURLEncoding(question.translation)
            DispatchQueue.main.async {
                self.translatedQuestion = finalTranslation
            }
        }
        
        // 翻译所有选项 - 使用乱序后的选项键
        let optionKeys = currentShuffledOptionKeys // 使用乱序后的选项键
        var translatedOpts: [String: String] = [:]
        let group = DispatchGroup()
        let lock = NSLock() // 线程安全锁
        
        for key in optionKeys {
            guard let value = currentShuffledOptions[key] else { continue }
            group.enter()
            TranslationService.shared.translate(value, from: "en", to: "zh-Hans") { [weak self] translated in
                lock.lock()
                translatedOpts[key] = translated ?? value
                lock.unlock()
                
                // 实时更新UI，让用户看到翻译进度
                // 解码URL编码的字符
                var decodedTranslated: String?
                if let translated = translated {
                    decodedTranslated = self?.decodeURLEncoding(translated)
                    // 检查翻译结果是否为中文，如果不是中文，不更新（避免显示错误的翻译）
                    if let decoded = decodedTranslated, let self = self, self.isEnglishText(decoded) {
                        decodedTranslated = nil // 翻译失败，不显示
                    }
                }
                if let decoded = decodedTranslated {
                    DispatchQueue.main.async {
                        self?.translatedOptions[key] = decoded
                    }
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.isTranslating = false
        }
    }
    
    func toggleFavorite() {
        guard let question = currentQuestion else { return }
        
        if isFavorite {
            storageService.removeFavorite(question.id)
        } else {
            storageService.addFavorite(question.id)
        }
    }
    
    func goToPrevious() {
        if canGoPrevious {
            currentQuestionIndex -= 1
            resetQuestionState()
        }
    }
    
    func goToNext() {
        if canGoNext {
            currentQuestionIndex += 1
            resetQuestionState()
        }
    }
    
    func goToQuestion(at index: Int) {
        guard index >= 0 && index < questions.count else { return }
        currentQuestionIndex = index
        resetQuestionState()
    }
    
    private func resetQuestionState() {
        selectedAnswer = nil
        showAnswer = false
        answerResult = nil
        translatedQuestion = nil
        translatedOptions = [:]
        isTranslating = false
        // 注意：不重置 countedQuestionIds，因为同一题目只应该统计一次
    }
    
    func getWrongAnswerQuestions() -> [Question] {
        let wrongAnswerIds = storageService.getWrongAnswers()
        return questions.filter { wrongAnswerIds.contains($0.id) }
    }
    
    func getFavoriteQuestions() -> [Question] {
        let favoriteIds = storageService.getFavorites()
        return questions.filter { favoriteIds.contains($0.id) }
    }
    
    // MARK: - 添加题目到题库
    
    func addQuestionsToBank(_ questions: [Question]) {
        let newQuestions = questions
        StorageService.shared.addImportedQuestionIds(newQuestions.map(\.id))
        DispatchQueue.main.async {
            self.questions.append(contentsOf: newQuestions)
            self.loadQuestions()
        }
        saveQuestionsToFile(newQuestions)
    }
    
    /// 导入题目保存到 App Documents 目录（iPhone 上 Bundle 只读，必须写这里才能持久化）
    private static var importedQuestionsFilePath: String {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent("imported_questions.txt").path
    }
    
    private func saveQuestionsToFile(_ questions: [Question]) {
        DispatchQueue.global(qos: .utility).async {
            let path = Self.importedQuestionsFilePath
            let fileManager = FileManager.default
            
            // 读取已有导入内容（若存在）
            var existingContent = ""
            if fileManager.fileExists(atPath: path),
               let content = try? String(contentsOfFile: path, encoding: .utf8) {
                existingContent = content
            }
            
            var newContent = existingContent
            if !newContent.isEmpty && !newContent.hasSuffix("\n\n") {
                newContent += "\n\n"
            }
            for question in questions {
                newContent += QuestionFormatter.format(question)
                newContent += "\n\n"
            }
            
            do {
                try newContent.write(toFile: path, atomically: true, encoding: .utf8)
                print("✅ 成功保存 \(questions.count) 道题目到 Documents/imported_questions.txt")
            } catch {
                print("❌ 保存题目失败: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - URL解码辅助方法
    
    // 解码URL编码的辅助函数（处理所有可能的编码格式）
    private func decodeURLEncoding(_ text: String) -> String {
        var decoded = text
        // 多次解码，处理嵌套编码
        for _ in 0..<3 {
            if let decodedText = decoded.removingPercentEncoding, decodedText != decoded {
                decoded = decodedText
            } else {
                break
            }
        }
        // 处理 %20 这种格式（带空格的情况）
        decoded = decoded.replacingOccurrences(of: "% 20", with: " ")
        decoded = decoded.replacingOccurrences(of: "%20", with: " ")
        decoded = decoded.replacingOccurrences(of: "%2C", with: ",")
        decoded = decoded.replacingOccurrences(of: "%2E", with: ".")
        decoded = decoded.replacingOccurrences(of: "%3F", with: "?")
        decoded = decoded.replacingOccurrences(of: "%21", with: "!")
        return decoded
    }
    
    // 检查文本是否为英文（简单判断）
    private func isEnglishText(_ text: String) -> Bool {
        // 如果文本包含大量英文字母且中文字符很少，认为是英文
        let englishChars = text.filter { $0.isASCII && $0.isLetter }.count
        let chineseChars = text.filter { isCJKCharacter($0) }.count
        return englishChars > chineseChars * 2 && chineseChars < 3
    }
    
    // 检查字符是否为中日韩字符
    private func isCJKCharacter(_ char: Character) -> Bool {
        guard let scalar = char.unicodeScalars.first else { return false }
        // CJK统一汉字范围
        return (0x4E00...0x9FFF).contains(scalar.value) ||
               (0x3400...0x4DBF).contains(scalar.value) || // 扩展A
               (0x20000...0x2A6DF).contains(scalar.value) || // 扩展B
               (0x3040...0x309F).contains(scalar.value) || // 平假名
               (0x30A0...0x30FF).contains(scalar.value) || // 片假名
               (0xAC00...0xD7AF).contains(scalar.value) // 韩文
    }
    
    // MARK: - 选项乱序方法
    
    /// 对题目的选项进行乱序，并返回映射关系
    private func shuffleOptions(for question: Question) -> OptionMapping {
        let originalKeys = ["A", "B", "C", "D"]
        let shuffledKeys = originalKeys.shuffled() // 随机打乱顺序
        
        // 创建映射关系
        var originalToNew: [String: String] = [:]
        var newToOriginal: [String: String] = [:]
        var shuffledOptions: [String: String] = [:]
        
        for (index, originalKey) in originalKeys.enumerated() {
            let newKey = shuffledKeys[index]
            originalToNew[originalKey] = newKey
            newToOriginal[newKey] = originalKey
            
            // 将原始选项内容映射到新的键
            if let optionText = question.options[originalKey] {
                shuffledOptions[newKey] = optionText
            }
        }
        
        return OptionMapping(
            originalToNew: originalToNew,
            newToOriginal: newToOriginal,
            shuffledOptions: shuffledOptions,
            shuffledKeys: shuffledKeys
        )
    }
    
    /// 创建保持原始顺序的映射（正序模式）
    private func createIdentityMapping(for question: Question) -> OptionMapping {
        let originalKeys = ["A", "B", "C", "D"]
        var options: [String: String] = [:]
        
        for key in originalKeys {
            if let optionText = question.options[key] {
                options[key] = optionText
            }
        }
        
        // 创建恒等映射（A->A, B->B, C->C, D->D）
        var originalToNew: [String: String] = [:]
        var newToOriginal: [String: String] = [:]
        for key in originalKeys {
            originalToNew[key] = key
            newToOriginal[key] = key
        }
        
        return OptionMapping(
            originalToNew: originalToNew,
            newToOriginal: newToOriginal,
            shuffledOptions: options,
            shuffledKeys: originalKeys
        )
    }
}

// MARK: - 题目格式化器

struct QuestionFormatter {
    static func format(_ question: Question) -> String {
        var result = "\(question.questionNumber)\n\n"
        result += "原题：\(question.questionText)\n\n"
        result += "选项：\n"
        
        for key in ["A", "B", "C", "D"] {
            if let option = question.options[key] {
                result += "\(key))\(option)\n"
            }
        }
        
        result += "你的答案：\(question.correctAnswer)\n"
        result += "核对结果：正确\n"
        result += "译文：\(question.translation)\n\n"
        result += "【考点·高效记忆】\n\(question.keyPoint)\n\n"
        result += "【解析·秒选思路】\n\(question.analysis)\n\n"
        
        if !question.coreWords.isEmpty {
            result += "核心词（音标+拆解记忆）\n\n"
            for word in question.coreWords {
                result += "• \(word.word) \(word.phonetic)：\(word.explanation)\n"
            }
        }
        
        return result
    }
}
