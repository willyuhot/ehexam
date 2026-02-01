//
//  TranslationService.swift
//  EHExam
//
//  Free translation service using iOS built-in translation
//

import Foundation
import NaturalLanguage

class TranslationService {
    static let shared = TranslationService()
    
    private init() {}
    
    // 使用iOS内置的翻译功能（需要iOS 15+）
    // 如果内置翻译不可用，可以使用免费的在线翻译API
    func translate(_ text: String, from sourceLanguage: String = "en", to targetLanguage: String = "zh-Hans", completion: @escaping (String?) -> Void) {
        // 方法1: 尝试使用Apple的翻译框架（需要iOS 15+）
        if #available(iOS 15.0, *) {
            translateWithApple(text, from: sourceLanguage, to: targetLanguage, completion: completion)
        } else {
            // 降级方案：使用免费的在线翻译API
            translateWithFreeAPI(text, from: sourceLanguage, to: targetLanguage, completion: completion)
        }
    }
    
    @available(iOS 15.0, *)
    private func translateWithApple(_ text: String, from sourceLanguage: String, to targetLanguage: String, completion: @escaping (String?) -> Void) {
        // 使用NLLanguageRecognizer检测语言
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        
        // 尝试使用系统翻译（需要用户授权）
        // 注意：Apple的翻译框架需要用户交互，所以这里使用免费API作为主要方案
        translateWithFreeAPI(text, from: sourceLanguage, to: targetLanguage, completion: completion)
    }
    
    // 使用免费的翻译API（MyMemory Translation API - 免费，无需API key）
    private func translateWithFreeAPI(_ text: String, from sourceLanguage: String, to targetLanguage: String, completion: @escaping (String?) -> Void) {
        // 清理文本
        let cleanedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedText.isEmpty else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        // 转换语言代码
        let sourceLang = convertLanguageCode(sourceLanguage)
        let targetLang = convertLanguageCode(targetLanguage)
        
        // MyMemory Translation API (免费，每天100,000字符)
        guard let encodedText = cleanedText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.mymemory.translated.net/get?q=\(encodedText)&langpair=\(sourceLang)|\(targetLang)") else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 15
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data,
               error == nil,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let responseData = json["responseData"] as? [String: Any],
               let translatedText = responseData["translatedText"] as? String,
               !translatedText.isEmpty,
               translatedText != cleanedText { // 确保不是原文
                // 解码URL编码的字符（如%20 -> 空格）
                let decodedText = translatedText.removingPercentEncoding ?? translatedText
                DispatchQueue.main.async {
                    completion(decodedText)
                }
                return
            }
            
            // 如果API失败，尝试备用方案
            self.translateWithBackupAPI(text, from: sourceLang, to: targetLang, completion: completion)
        }.resume()
    }
    
    // 备用翻译方案：使用LibreTranslate（完全免费，开源）
    private func translateWithBackupAPI(_ text: String, from sourceLanguage: String, to targetLanguage: String, completion: @escaping (String?) -> Void) {
        let cleanedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedText.isEmpty else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        // 使用公共的LibreTranslate实例
        guard let url = URL(string: "https://libretranslate.de/translate") else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 15
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        let sourceLang = convertLanguageCode(sourceLanguage)
        let targetLang = convertLanguageCode(targetLanguage)
        
        let body: [String: Any] = [
            "q": cleanedText,
            "source": sourceLang,
            "target": targetLang,
            "format": "text"
        ]
        
        guard let bodyData = try? JSONSerialization.data(withJSONObject: body) else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        request.httpBody = bodyData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data,
               error == nil,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let translatedText = json["translatedText"] as? String,
               !translatedText.isEmpty {
                // 解码URL编码的字符（如%20 -> 空格）
                let decodedText = translatedText.removingPercentEncoding ?? translatedText
                DispatchQueue.main.async {
                    completion(decodedText)
                }
                return
            }
            
            // 如果都失败了，返回nil（不返回原文，让UI显示原文）
            DispatchQueue.main.async {
                completion(nil)
            }
        }.resume()
    }
    
    // 转换语言代码
    private func convertLanguageCode(_ code: String) -> String {
        let mapping: [String: String] = [
            "en": "en",
            "zh": "zh",
            "zh-Hans": "zh",
            "zh-Hant": "zh-TW",
            "es": "es",
            "fr": "fr",
            "de": "de",
            "ja": "ja",
            "ko": "ko"
        ]
        return mapping[code] ?? code
    }
    
    // 批量翻译
    func translateMultiple(_ texts: [String], from sourceLanguage: String = "en", to targetLanguage: String = "zh-Hans", completion: @escaping ([String?]) -> Void) {
        let group = DispatchGroup()
        var results: [String?] = Array(repeating: nil, count: texts.count)
        
        for (index, text) in texts.enumerated() {
            group.enter()
            translate(text, from: sourceLanguage, to: targetLanguage) { translated in
                results[index] = translated
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(results)
        }
    }
}
