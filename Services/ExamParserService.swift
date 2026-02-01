//
//  ExamParserService.swift
//  EHExam
//
//  Service for parsing exam papers using DeepSeek API
//

import Foundation

class ExamParserService {
    static let shared = ExamParserService()
    
    private init() {}
    
    // DeepSeek API endpoint
    private let apiURL = "https://api.deepseek.com/v1/chat/completions"
    
    func parseExam(content: String, apiKey: String, completion: @escaping ([Question]?, Error?) -> Void) {
        guard !apiKey.isEmpty else {
            completion(nil, NSError(domain: "ExamParserService", code: -1, userInfo: [NSLocalizedDescriptionKey: "API Key未配置"]))
            return
        }
        
        // 构建prompt
        let prompt = buildPrompt(examContent: content)
        
        // 构建API请求
        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let requestBody: [String: Any] = [
            "model": "deepseek-chat",
            "messages": [
                [
                    "role": "system",
                    "content": "你是一位具有20年教学经验英语专业老师并且精通英语四级笔试考点和学位英语考点和押题。请根据试卷文档内容，指导一位初中水平的学生，对这个文档中除作文外的内容进行拆解高效记忆。并且每道题和结尾的答案进行匹配，输出纯文本格式。"
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "temperature": 0.3,
            "max_tokens": 8000
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        // 发送请求
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "ExamParserService", code: -2, userInfo: [NSLocalizedDescriptionKey: "未收到响应数据"]))
                return
            }
            
            // 解析响应
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    
                    // 解析返回的题目
                    let questions = self.parseQuestionsFromResponse(content)
                    
                    // 验证题目
                    let validatedQuestions = self.validateQuestions(questions)
                    
                    completion(validatedQuestions, nil)
                } else {
                    completion(nil, NSError(domain: "ExamParserService", code: -3, userInfo: [NSLocalizedDescriptionKey: "API响应格式错误"]))
                }
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
    
    private func buildPrompt(examContent: String) -> String {
        return """
        请根据以下试卷内容，解析出所有题目（除作文外），并按照以下格式输出：

        ## 格式要求：

        • 原题

        • 选项（分行，每个选项一行）

        • 你的答案

        • 核对结果

        • 译文

        • 【考点·高效记忆】（一句话：考什么 + 口诀/秒选法）

        • 【解析·秒选思路】（直接告诉你：看到什么词→用什么规则→选哪个）

        • 核心词（音标+词根拆解记忆）

        ## 选择项要求
        请把选择项拆分成多行，格式如下：
        A)xxx
        B)xxx
        C)xxx
        D)xxx

        试卷内容：
        \(examContent)

        请确保：
        1. 每道题都有完整的格式
        2. 答案与题目匹配
        3. 译文准确
        4. 考点和解析清晰
        5. 核心词包含音标和记忆方法
        """
    }
    
    private func parseQuestionsFromResponse(_ content: String) -> [Question] {
        // 使用QuestionParser解析返回的内容
        return QuestionParser.parseQuestions(from: content)
    }
    
    private func validateQuestions(_ questions: [Question]) -> [Question] {
        // 验证题目的完整性和正确性
        return questions.filter { question in
            // 检查必要字段
            guard !question.questionText.isEmpty,
                  question.options.count == 4,
                  !question.correctAnswer.isEmpty,
                  ["A", "B", "C", "D"].contains(question.correctAnswer) else {
                print("⚠️ 题目验证失败: \(question.questionNumber)")
                return false
            }
            
            // 检查答案是否在选项中
            guard question.options[question.correctAnswer] != nil else {
                print("⚠️ 答案不在选项中: \(question.questionNumber), 答案: \(question.correctAnswer)")
                return false
            }
            
            return true
        }
    }
}
