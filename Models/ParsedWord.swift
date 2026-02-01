//
//  ParsedWord.swift
//  EHExam
//
//  试卷解析出的超纲词（超出初中范围）
//

import Foundation

struct ParsedWord: Identifiable, Codable, Equatable {
    let id: String
    let word: String
    let phonetic: String
    let meaningWithRoot: String      // 如 "太阳（词根：sun=太阳）"
    let originalSentence: String    // 原文（试卷中出现的句子）
    let translation: String         // 译文
    let memoryTips: String          // 记忆要点
    
    init(
        id: String? = nil,
        word: String,
        phonetic: String = "",
        meaningWithRoot: String,
        originalSentence: String,
        translation: String,
        memoryTips: String
    ) {
        self.id = id ?? UUID().uuidString
        self.word = word
        self.phonetic = phonetic
        self.meaningWithRoot = meaningWithRoot
        self.originalSentence = originalSentence
        self.translation = translation
        self.memoryTips = memoryTips
    }
}
