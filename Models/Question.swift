//
//  Question.swift
//  EHExam
//
//  Question data model
//

import Foundation

struct Question: Identifiable, Codable {
    let id: Int
    let questionNumber: String
    let questionText: String
    let options: [String: String] // ["A": "for the sake of", "B": "but for", ...]
    let correctAnswer: String
    let translation: String
    let keyPoint: String // 【考点·高效记忆】
    let analysis: String // 【解析·秒选思路】
    let coreWords: [CoreWord] // 核心词
    
    struct CoreWord: Codable {
        let word: String
        let phonetic: String
        let explanation: String
    }
}
