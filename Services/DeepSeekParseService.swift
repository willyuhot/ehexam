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
        request.timeoutInterval = 120 // 2分钟超时
        
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
                let nsError = error as NSError
                if nsError.code == NSURLErrorTimedOut {
                    completion(.failure(NSError(domain: "DeepSeekParseService", code: -3, userInfo: [NSLocalizedDescriptionKey: "请求超时，请稍后重试"])))
                    return
                }
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
        request.timeoutInterval = 60 // 1分钟超时
        
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
                let nsError = error as NSError
                if nsError.code == NSURLErrorTimedOut {
                    completion(.failure(NSError(domain: "DeepSeekParseService", code: -3, userInfo: [NSLocalizedDescriptionKey: "请求超时，请稍后重试"])))
                    return
                }
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
    
    /// 单次请求的文本块大小（字符），避免单次输出超过 max_tokens
    /// 减小块大小以提高响应速度和成功率
    private let chunkSize = 4000
    
    /// 解析试卷中的超纲词（超出初中范围），返回结构化单词列表
    /// 因 API max_tokens 限制（约 8000），将内容分块多次请求，再合并去重，覆盖所有超纲词
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
        
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            completion(.success([]))
            return
        }
        
        // 按段落或固定长度分块，保证每块在 chunkSize 内
        let chunks = splitIntoChunks(trimmed, maxChars: chunkSize)
        
        if chunks.count == 1 {
            onProgress?("正在分析试卷中的超纲词...")
            parseSingleChunk(content: chunks[0], apiKey: apiKey, chunkIndex: 0, totalChunks: 1, onProgress: onProgress) { result in
                completion(result)
            }
        } else {
            onProgress?("正在分块分析试卷（共 \(chunks.count) 块）...")
            parseChunksSequentially(chunks: chunks, apiKey: apiKey, onProgress: onProgress, completion: completion)
        }
    }
    
    /// 将文本按段落或固定长度分块
    private func splitIntoChunks(_ text: String, maxChars: Int) -> [String] {
        var chunks: [String] = []
        var remaining = text
        while !remaining.isEmpty {
            if remaining.count <= maxChars {
                chunks.append(remaining)
                break
            }
            let endIdx = remaining.index(remaining.startIndex, offsetBy: maxChars, limitedBy: remaining.endIndex) ?? remaining.endIndex
            var chunk = String(remaining[..<endIdx])
            remaining = String(remaining[endIdx...])
            // 尽量在段落边界截断，避免把句子拦腰截断
            if let lastNewline = chunk.lastIndex(of: "\n") {
                let lenToNewline = chunk.distance(from: chunk.startIndex, to: chunk.index(after: lastNewline))
                if lenToNewline > maxChars / 2 {
                    let afterNewline = chunk.index(after: lastNewline)
                    remaining = String(chunk[afterNewline...]) + remaining
                    chunk = String(chunk[..<afterNewline])
                }
            }
            chunks.append(chunk)
        }
        return chunks
    }
    
    /// 顺序请求多块，合并去重
    private func parseChunksSequentially(
        chunks: [String],
        apiKey: String,
        onProgress: ((String) -> Void)?,
        completion: @escaping (Result<[ParsedWord], Error>) -> Void
    ) {
        var allWords: [ParsedWord] = []
        var seenWords = Set<String>()
        let queue = DispatchQueue(label: "parse.chunks")
        var currentIndex = 0
        
        func processNext() {
            guard currentIndex < chunks.count else {
                queue.async {
                    completion(.success(allWords))
                }
                return
            }
            let idx = currentIndex
            currentIndex += 1
            let chunk = chunks[idx]
            
            DispatchQueue.main.async {
                onProgress?("正在分析第 \(idx + 1)/\(chunks.count) 块（共 \(chunks.count) 块，预计需要 \(chunks.count * 2) 分钟）...")
            }
            
            parseSingleChunk(content: chunk, apiKey: apiKey, chunkIndex: idx, totalChunks: chunks.count, onProgress: nil) { result in
                switch result {
                case .success(let words):
                    queue.async {
                        for w in words {
                            let key = w.word.lowercased()
                            if !seenWords.contains(key) {
                                seenWords.insert(key)
                                allWords.append(w)
                            }
                        }
                        processNext()
                    }
                case .failure(let err):
                    DispatchQueue.main.async {
                        completion(.failure(err))
                    }
                }
            }
        }
        
        processNext()
    }
    
    /// 单块解析（一次 API 调用）
    private func parseSingleChunk(
        content: String,
        apiKey: String,
        chunkIndex: Int,
        totalChunks: Int,
        onProgress: ((String) -> Void)?,
        completion: @escaping (Result<[ParsedWord], Error>) -> Void
    ) {
        let systemPrompt = """
        你是英语词汇专家，精通中国中小学、高中、大学英语及四六级考试词汇大纲。
        
        **任务**：分析以下英语试卷文本，提取所有「超出初中词汇范围」的单词。
        
        **初中词汇范围**（约1600词）：指中国初中英语教学大纲要求掌握的基础词汇，如 book, water, happy, important 等日常高频词。
        
        **需要提取的超纲词包括**：
        1. 高中词汇（如 appreciate, significant, consequence）
        2. 大学英语/四级词汇（如 sophisticated, elaborate, simultaneously）
        3. 六级及以上词汇（如 scrutinize, exacerbate, unprecedented）
        4. 学术词汇、专业术语
        5. 较难的动词短语、固定搭配中的核心词
        
        **不要遗漏**：即使是看似简单但实际超出初中范围的词也要提取。宁可多提取，不要遗漏。
        
        **输出格式**：仅输出 JSON 数组，不要输出任何解释文字：
        [{"word":"单词","phonetic":"/音标/","meaningWithRoot":"中文释义（词根：xxx=含义）","originalSentence":"试卷中出现该词的原文句子","translation":"原文句子的中文翻译","memoryTips":"记忆要点/联想记忆法"}]
        
        要求：word 必填；phonetic 国际音标；meaningWithRoot 包含词根词缀分析；originalSentence 必须是试卷原文完整句子；memoryTips 简洁实用。
        """
        
        let userPrompt = "请分析以下试卷内容片段，提取所有超出初中词汇范围的单词，按上述 JSON 格式输出：\n\n\(content)"
        
        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 180 // 3分钟超时，大块内容解析需要更长时间
        
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
                let nsError = error as NSError
                if nsError.code == NSURLErrorTimedOut {
                    DispatchQueue.main.async {
                        onProgress?("第 \(chunkIndex + 1)/\(totalChunks) 块解析超时，正在重试...")
                    }
                    completion(.failure(NSError(domain: "DeepSeekParseService", code: -4, userInfo: [NSLocalizedDescriptionKey: "解析超时，内容块可能过大，请尝试拆分文件"])))
                    return
                }
                completion(.failure(error))
                return
            }
            guard let data = data,
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
                    id: "chunk\(chunkIndex)_\(word)_\(i)",
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
