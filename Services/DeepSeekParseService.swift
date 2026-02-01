//
//  DeepSeekParseService.swift
//  EHExam
//
//  智能解析：调用 DeepSeek API，返回题目翻译、选项翻译、词根词缀、解题心法等
//

import Foundation

class DeepSeekParseService {
    static let shared = DeepSeekParseService()
    private let apiURL = "https://api.deepseek.com/v1/chat/completions"
    
    private init() {}
    
    /// 请求单题智能解析（题目+选项翻译、词根词缀、解题心法、完形/阅读技巧）
    func requestQuestionParse(
        question: Question,
        apiKey: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard !apiKey.isEmpty else {
            completion(.failure(NSError(domain: "DeepSeekParseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "API Key未配置"])))
            return
        }
        
        let prompt = buildQuestionParsePrompt(question: question)
        
        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "model": "deepseek-chat",
            "messages": [
                ["role": "system", "content": systemPromptForParse],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.3,
            "max_tokens": 4000
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let first = choices.first,
                  let msg = first["message"] as? [String: Any],
                  let content = msg["content"] as? String, !content.isEmpty else {
                completion(.failure(NSError(domain: "DeepSeekParseService", code: -2, userInfo: [NSLocalizedDescriptionKey: "API 返回格式错误"])))
                return
            }
            completion(.success(content))
        }.resume()
    }
    
    /// 请求单词智能解析（词根词缀、视觉化联想）
    func requestWordParse(
        word: String,
        context: String?,
        apiKey: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard !apiKey.isEmpty else {
            completion(.failure(NSError(domain: "DeepSeekParseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "API Key未配置"])))
            return
        }
        
        var userContent = "请对单词「\(word)」做智能解析：\n"
        if let ctx = context, !ctx.isEmpty {
            userContent += "所在句子/语境：\(ctx)\n"
        }
        userContent += "\n要求：\n1. 词根词缀拆解（像汉字偏旁部首，如 pre- + dict → 预测）\n2. 视觉化/联想记忆（谐音或画面，如 ambitious→俺必胜）\n3. 同根词拓展（如 dict → dictionary, contradict, dictate）"
        
        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "model": "deepseek-chat",
            "messages": [
                ["role": "system", "content": "你是英语词汇与解题专家，擅长词根词缀和记忆法。"],
                ["role": "user", "content": userContent]
            ],
            "temperature": 0.3,
            "max_tokens": 1500
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let first = choices.first,
                  let msg = first["message"] as? [String: Any],
                  let content = msg["content"] as? String, !content.isEmpty else {
                completion(.failure(NSError(domain: "DeepSeekParseService", code: -2, userInfo: [NSLocalizedDescriptionKey: "API 返回格式错误"])))
                return
            }
            completion(.success(content))
        }.resume()
    }
    
    private var systemPromptForParse: String {
        """
        你是英语考试解题专家。请针对题目给出「一看就会选」的解析，包含：
        1. 题目翻译、选项翻译
        2. 核心词：词根词缀拆解（如 pre- + dict → 预测）、视觉化/联想记忆
        3. 场景题/词汇题解题心法：
           - 第一步：看搭配（如 depend __ → on）
           - 第二步：析语境，辨近义（如 glance vs stare）
           - 第三步：挖逻辑（转折、并列、解释）
        4. 若是完形填空：逐句说明为何选该项、线索在哪
        5. 若是阅读理解：抓信息要点，不逐句翻译
        输出简洁、条理清晰，便于学生秒选正确答案。
        """
    }
    
    /// 解析试卷中的超纲词（超出初中范围），返回结构化单词列表
    func parseWordsFromExam(
        content: String,
        apiKey: String,
        onProgress: ((String) -> Void)? = nil,
        completion: @escaping (Result<[ParsedWord], Error>) -> Void
    ) {
        guard !apiKey.isEmpty else {
            completion(.failure(NSError(domain: "DeepSeekParseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "API Key未配置"])))
            return
        }
        
        onProgress?("正在分析试卷中的超纲词...")
        
        let systemPrompt = """
        你是英语词汇专家，熟悉初中（约1600词）与高中、四级词汇范围。
        请分析试卷文本，找出所有「超出初中词汇范围」的单词。
        对每个超纲词，输出如下 JSON 数组格式，不要输出任何其他文字：
        [{"word":"单词","phonetic":"/音标/","meaningWithRoot":"释义（词根：xxx）","originalSentence":"试卷中出现的原文句子","translation":"原文的中文译文","memoryTips":"记忆要点"}]
        要求：word 必填；phonetic 可空；meaningWithRoot 包含释义和词根信息；originalSentence 必须是试卷原文；translation 对原文的翻译；memoryTips 简洁记忆法。
        """
        
        let userPrompt = "请分析以下试卷内容，提取所有超出初中词汇范围的单词，按上述 JSON 格式输出：\n\n\(content.prefix(12000))"
        
        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "model": "deepseek-chat",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
            ],
            "temperature": 0.2,
            "max_tokens": 8000
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data,
                  let raw = String(data: data, encoding: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let first = choices.first,
                  let msg = first["message"] as? [String: Any],
                  let contentStr = msg["content"] as? String, !contentStr.isEmpty else {
                completion(.failure(NSError(domain: "DeepSeekParseService", code: -2, userInfo: [NSLocalizedDescriptionKey: "API 返回格式错误"])))
                return
            }
            
            let cleaned = contentStr
                .replacingOccurrences(of: "```json", with: "")
                .replacingOccurrences(of: "```", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard let jsonData = cleaned.data(using: .utf8),
                  let arr = try? JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] else {
                completion(.failure(NSError(domain: "DeepSeekParseService", code: -3, userInfo: [NSLocalizedDescriptionKey: "无法解析单词列表"])))
                return
            }
            
            var words: [ParsedWord] = []
            for (i, item) in arr.enumerated() {
                guard let word = item["word"] as? String, !word.isEmpty else { continue }
                let pw = ParsedWord(
                    id: "\(word)_\(i)",
                    word: word,
                    phonetic: (item["phonetic"] as? String) ?? "",
                    meaningWithRoot: (item["meaningWithRoot"] as? String) ?? (item["meaning"] as? String) ?? "",
                    originalSentence: (item["originalSentence"] as? String) ?? "",
                    translation: (item["translation"] as? String) ?? "",
                    memoryTips: (item["memoryTips"] as? String) ?? ""
                )
                words.append(pw)
            }
            completion(.success(words))
        }.resume()
    }
    
    private func buildQuestionParsePrompt(question: Question) -> String {
        var s = "题目：\(question.questionText)\n\n选项：\n"
        for (k, v) in question.options.sorted(by: { $0.key < $1.key }) {
            s += "\(k)) \(v)\n"
        }
        s += "\n正确答案：\(question.correctAnswer)\n"
        if !question.translation.isEmpty { s += "已有译文：\(question.translation)\n" }
        if !question.keyPoint.isEmpty { s += "已有考点：\(question.keyPoint)\n" }
        if !question.analysis.isEmpty { s += "已有解析：\(question.analysis)\n" }
        s += "\n请按系统提示格式，补充/优化上述内容的智能解析（题目翻译、选项翻译、词根词缀、解题心法、完形/阅读技巧）。"
        return s
    }
}
