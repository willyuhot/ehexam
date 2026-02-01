//
//  QuestionParser.swift
//  EHExam
//
//  Parse part.txt file into Question objects
//

import Foundation

class QuestionParser {
    static func parseQuestions(from content: String) -> [Question] {
        var questions: [Question] = []
        let lines = content.components(separatedBy: .newlines)
        
        var currentQuestion: QuestionBuilder?
        var currentSection: String = ""
        var currentCoreWords: [Question.CoreWord] = []
        
        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // 检测题号
            if trimmed.contains("第") && trimmed.contains("题") {
                // 保存上一题
                if let question = currentQuestion?.build() {
                    questions.append(question)
                }
                
                // 开始新题
                let questionNumber = trimmed
                let questionId = extractQuestionNumber(from: questionNumber)
                currentQuestion = QuestionBuilder(id: questionId, questionNumber: questionNumber)
                currentCoreWords = []
                currentSection = ""
                continue
            }
            
            guard var builder = currentQuestion else { continue }
            
            // 解析原题
            if trimmed.hasPrefix("原题：") {
                builder.questionText = String(trimmed.dropFirst(3))
                currentQuestion = builder
                continue
            }
            
            // 解析选项
            if trimmed == "选项：" {
                currentSection = "options"
                continue
            }
            
            if currentSection == "options" {
                if trimmed.matches(pattern: "^[A-D]\\)") {
                    let optionKey = String(trimmed.prefix(1))
                    let optionValue = String(trimmed.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                    builder.options[optionKey] = optionValue
                    currentQuestion = builder
                    continue
                } else if trimmed.hasPrefix("你的答案：") {
                    currentSection = ""
                    let answer = String(trimmed.dropFirst(5)).trimmingCharacters(in: .whitespaces)
                    builder.correctAnswer = answer
                    currentQuestion = builder
                    continue
                } else if !trimmed.isEmpty && !trimmed.hasPrefix("核对结果") {
                    // 继续读取选项（如果选项跨行）
                    continue
                }
            }
            
            // 解析译文
            if trimmed.hasPrefix("译文：") {
                builder.translation = String(trimmed.dropFirst(3))
                currentQuestion = builder
                continue
            }
            
            // 解析考点
            if trimmed == "【考点·高效记忆】" {
                currentSection = "keyPoint"
                continue
            }
            
            if currentSection == "keyPoint" {
                if trimmed.hasPrefix("【解析·秒选思路】") {
                    currentSection = "analysis"
                    continue
                }
                if !trimmed.isEmpty {
                    builder.keyPoint += (builder.keyPoint.isEmpty ? "" : "\n") + trimmed
                    currentQuestion = builder
                }
                continue
            }
            
            // 解析解析
            if currentSection == "analysis" {
                if trimmed.hasPrefix("核心词") {
                    currentSection = "coreWords"
                    continue
                }
                if !trimmed.isEmpty {
                    builder.analysis += (builder.analysis.isEmpty ? "" : "\n") + trimmed
                    currentQuestion = builder
                }
                continue
            }
            
            // 解析核心词
            if currentSection == "coreWords" {
                if trimmed.matches(pattern: "^第\\d+题") {
                    // 遇到下一题，保存当前题
                    if let question = currentQuestion?.build() {
                        questions.append(question)
                    }
                    let questionNumber = trimmed
                    let questionId = extractQuestionNumber(from: questionNumber)
                    currentQuestion = QuestionBuilder(id: questionId, questionNumber: questionNumber)
                    currentCoreWords = []
                    currentSection = ""
                    continue
                }
                
                if trimmed.hasPrefix("•") {
                    let wordLine = String(trimmed.dropFirst(1)).trimmingCharacters(in: .whitespaces)
                    if let coreWord = parseCoreWord(from: wordLine) {
                        currentCoreWords.append(coreWord)
                        builder.coreWords = currentCoreWords
                        currentQuestion = builder
                    }
                }
            }
        }
        
        // 保存最后一题
        if let question = currentQuestion?.build() {
            questions.append(question)
        }
        
        return questions
    }
    
    private static func extractQuestionNumber(from text: String) -> Int {
        let pattern = "第(\\d+)题"
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
           let range = Range(match.range(at: 1), in: text) {
            return Int(String(text[range])) ?? 0
        }
        return 0
    }
    
    private static func parseCoreWord(from line: String) -> Question.CoreWord? {
        // 格式：word /phonetic/：explanation
        let components = line.components(separatedBy: "：")
        guard components.count >= 2 else { return nil }
        
        let wordPart = components[0].trimmingCharacters(in: .whitespaces)
        let explanation = components[1].trimmingCharacters(in: .whitespaces)
        
        // 提取单词和音标
        let wordPhoneticPattern = "^(\\S+)\\s+(/[^/]+/)"
        if let regex = try? NSRegularExpression(pattern: wordPhoneticPattern),
           let match = regex.firstMatch(in: wordPart, range: NSRange(wordPart.startIndex..., in: wordPart)) {
            if let wordRange = Range(match.range(at: 1), in: wordPart),
               let phoneticRange = Range(match.range(at: 2), in: wordPart) {
                let word = String(wordPart[wordRange])
                let phonetic = String(wordPart[phoneticRange])
                return Question.CoreWord(word: word, phonetic: phonetic, explanation: explanation)
            }
        }
        
        // 如果没有音标，只提取单词
        let words = wordPart.components(separatedBy: .whitespaces)
        if let word = words.first {
            return Question.CoreWord(word: word, phonetic: "", explanation: explanation)
        }
        
        return nil
    }
}

// Helper class for building questions
private class QuestionBuilder {
    var id: Int
    var questionNumber: String
    var questionText: String = ""
    var options: [String: String] = [:]
    var correctAnswer: String = ""
    var translation: String = ""
    var keyPoint: String = ""
    var analysis: String = ""
    var coreWords: [Question.CoreWord] = []
    
    init(id: Int, questionNumber: String) {
        self.id = id
        self.questionNumber = questionNumber
    }
    
    func build() -> Question? {
        guard !questionText.isEmpty,
              !options.isEmpty,
              !correctAnswer.isEmpty else {
            return nil
        }
        return Question(
            id: id,
            questionNumber: questionNumber,
            questionText: questionText,
            options: options,
            correctAnswer: correctAnswer,
            translation: translation,
            keyPoint: keyPoint,
            analysis: analysis,
            coreWords: coreWords
        )
    }
}

extension String {
    func matches(pattern: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
        let range = NSRange(self.startIndex..., in: self)
        return regex.firstMatch(in: self, range: range) != nil
    }
}
