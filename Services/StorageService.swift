//
//  StorageService.swift
//  EHExam
//
//  Manage wrong answers and favorites using UserDefaults
//

import Foundation

class StorageService {
    private let wrongAnswersKey = "wrongAnswers"
    private let favoritesKey = "favorites"
    private let correctCountKey = "correctCount"
    private let wrongCountKey = "wrongCount"
    private let vocabularyKey = "vocabularyWords"
    private let questionCorrectCountKey = "questionCorrectCount"
    private let questionWrongCountKey = "questionWrongCount"
    private let dailyStatsKey = "dailyStats"
    private let importedQuestionIdsKey = "importedQuestionIds"
    private let parsedWordsKey = "parsedWords"
    
    static let shared = StorageService()
    
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone.current
        return f
    }()
    
    static func dateString(for date: Date) -> String {
        dateFormatter.string(from: date)
    }
    
    private init() {}
    
    // MARK: - Wrong Answers
    
    func addWrongAnswer(_ questionId: Int) {
        var wrongAnswers = getWrongAnswers()
        if !wrongAnswers.contains(questionId) {
            wrongAnswers.append(questionId)
            saveWrongAnswers(wrongAnswers)
            // 确保立即保存
            UserDefaults.standard.synchronize()
            print("✅ 已添加错题: \(questionId), 当前错题数: \(wrongAnswers.count)")
        } else {
            print("⚠️ 题目 \(questionId) 已在错题本中")
        }
    }
    
    func removeWrongAnswer(_ questionId: Int) {
        var wrongAnswers = getWrongAnswers()
        wrongAnswers.removeAll { $0 == questionId }
        saveWrongAnswers(wrongAnswers)
    }
    
    func getWrongAnswers() -> [Int] {
        if let data = UserDefaults.standard.array(forKey: wrongAnswersKey) as? [Int] {
            return data
        }
        return []
    }
    
    func isWrongAnswer(_ questionId: Int) -> Bool {
        return getWrongAnswers().contains(questionId)
    }
    
    private func saveWrongAnswers(_ ids: [Int]) {
        UserDefaults.standard.set(ids, forKey: wrongAnswersKey)
    }
    
    // MARK: - Favorites
    
    func addFavorite(_ questionId: Int) {
        var favorites = getFavorites()
        if !favorites.contains(questionId) {
            favorites.append(questionId)
            saveFavorites(favorites)
        }
    }
    
    func removeFavorite(_ questionId: Int) {
        var favorites = getFavorites()
        favorites.removeAll { $0 == questionId }
        saveFavorites(favorites)
    }
    
    func getFavorites() -> [Int] {
        if let data = UserDefaults.standard.array(forKey: favoritesKey) as? [Int] {
            return data
        }
        return []
    }
    
    func isFavorite(_ questionId: Int) -> Bool {
        return getFavorites().contains(questionId)
    }
    
    private func saveFavorites(_ ids: [Int]) {
        UserDefaults.standard.set(ids, forKey: favoritesKey)
    }
    
    // MARK: - Statistics (正确率统计)
    
    func addCorrectAnswer() {
        let currentCount = getCorrectCount()
        UserDefaults.standard.set(currentCount + 1, forKey: correctCountKey)
        recordDailyAnswer(isCorrect: true)
        UserDefaults.standard.synchronize()
    }
    
    func addWrongAnswerCount() {
        let currentCount = getWrongCount()
        UserDefaults.standard.set(currentCount + 1, forKey: wrongCountKey)
        recordDailyAnswer(isCorrect: false)
        UserDefaults.standard.synchronize()
    }
    
    func getCorrectCount() -> Int {
        return UserDefaults.standard.integer(forKey: correctCountKey)
    }
    
    func getWrongCount() -> Int {
        return UserDefaults.standard.integer(forKey: wrongCountKey)
    }
    
    func getTotalCount() -> Int {
        return getCorrectCount() + getWrongCount()
    }
    
    func getAccuracyRate() -> Double {
        let total = getTotalCount()
        guard total > 0 else { return 0.0 }
        return Double(getCorrectCount()) / Double(total) * 100.0
    }
    
    func resetStatistics() {
        UserDefaults.standard.set(0, forKey: correctCountKey)
        UserDefaults.standard.set(0, forKey: wrongCountKey)
        UserDefaults.standard.removeObject(forKey: questionCorrectCountKey)
        UserDefaults.standard.removeObject(forKey: questionWrongCountKey)
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - Vocabulary (收藏的单词)
    
    func addVocabularyWord(_ word: String) {
        var words = getVocabularyWords()
        let normalized = word.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalized.isEmpty, !words.contains(normalized) else { return }
        words.append(normalized)
        UserDefaults.standard.set(words, forKey: vocabularyKey)
        recordDailyWordLearned()
        UserDefaults.standard.synchronize()
    }
    
    func removeVocabularyWord(_ word: String) {
        var words = getVocabularyWords()
        let normalized = word.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        words.removeAll { $0 == normalized }
        UserDefaults.standard.set(words, forKey: vocabularyKey)
        UserDefaults.standard.synchronize()
    }
    
    func getVocabularyWords() -> [String] {
        (UserDefaults.standard.array(forKey: vocabularyKey) as? [String]) ?? []
    }
    
    func isInVocabulary(_ word: String) -> Bool {
        getVocabularyWords().contains(word.trimmingCharacters(in: .whitespacesAndNewlines).lowercased())
    }
    
    // MARK: - Per-Question Statistics (单题对/错次数)
    
    private func getQuestionCorrectDict() -> [Int: Int] {
        guard let data = UserDefaults.standard.data(forKey: questionCorrectCountKey),
              let decoded = try? JSONDecoder().decode([String: Int].self, from: data) else {
            return [:]
        }
        return decoded.reduce(into: [:]) { $0[Int($1.key) ?? 0] = $1.value }
    }
    
    private func getQuestionWrongDict() -> [Int: Int] {
        guard let data = UserDefaults.standard.data(forKey: questionWrongCountKey),
              let decoded = try? JSONDecoder().decode([String: Int].self, from: data) else {
            return [:]
        }
        return decoded.reduce(into: [:]) { $0[Int($1.key) ?? 0] = $1.value }
    }
    
    private func saveQuestionCorrectDict(_ dict: [Int: Int]) {
        let enc: [String: Int] = dict.reduce(into: [:]) { $0["\($1.key)"] = $1.value }
        if let data = try? JSONEncoder().encode(enc) {
            UserDefaults.standard.set(data, forKey: questionCorrectCountKey)
        }
    }
    
    private func saveQuestionWrongDict(_ dict: [Int: Int]) {
        let enc: [String: Int] = dict.reduce(into: [:]) { $0["\($1.key)"] = $1.value }
        if let data = try? JSONEncoder().encode(enc) {
            UserDefaults.standard.set(data, forKey: questionWrongCountKey)
        }
    }
    
    func getCorrectCount(forQuestionId questionId: Int) -> Int {
        getQuestionCorrectDict()[questionId] ?? 0
    }
    
    func getWrongCount(forQuestionId questionId: Int) -> Int {
        getQuestionWrongDict()[questionId] ?? 0
    }
    
    func addCorrectForQuestion(_ questionId: Int) {
        var dict = getQuestionCorrectDict()
        dict[questionId, default: 0] += 1
        saveQuestionCorrectDict(dict)
        UserDefaults.standard.synchronize()
    }
    
    func addWrongForQuestion(_ questionId: Int) {
        var dict = getQuestionWrongDict()
        dict[questionId, default: 0] += 1
        saveQuestionWrongDict(dict)
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - Daily Stats (每日学习进度)
    
    struct DailyStats {
        let dateString: String
        var correct: Int
        var wrong: Int
        var wordsLearned: Int
        var totalQuestions: Int { correct + wrong }
    }
    
    private func getDailyStatsDict() -> [String: [String: Int]] {
        (UserDefaults.standard.dictionary(forKey: dailyStatsKey) as? [String: [String: Int]]) ?? [:]
    }
    
    private func saveDailyStatsDict(_ dict: [String: [String: Int]]) {
        UserDefaults.standard.set(dict, forKey: dailyStatsKey)
    }
    
    func recordDailyAnswer(isCorrect: Bool) {
        let key = Self.dateString(for: Date())
        var dict = getDailyStatsDict()
        var day = dict[key] ?? ["c": 0, "w": 0, "words": 0]
        if isCorrect {
            day["c", default: 0] += 1
        } else {
            day["w", default: 0] += 1
        }
        dict[key] = day
        saveDailyStatsDict(dict)
    }
    
    func recordDailyWordLearned() {
        let key = Self.dateString(for: Date())
        var dict = getDailyStatsDict()
        var day = dict[key] ?? ["c": 0, "w": 0, "words": 0]
        day["words", default: 0] += 1
        dict[key] = day
        saveDailyStatsDict(dict)
    }
    
    func getDailyStats(for date: Date) -> DailyStats? {
        let key = Self.dateString(for: date)
        let dict = getDailyStatsDict()
        guard let day = dict[key] else { return nil }
        return DailyStats(
            dateString: key,
            correct: day["c"] ?? 0,
            wrong: day["w"] ?? 0,
            wordsLearned: day["words"] ?? 0
        )
    }
    
    /// 最近有学习记录的日子（倒序，新的在前）
    func getRecentDaysWithStats(limit: Int = 14) -> [DailyStats] {
        let dict = getDailyStatsDict()
        let sortedKeys = dict.keys.sorted(by: >)
        return sortedKeys.prefix(limit).compactMap { key -> DailyStats? in
            guard let day = dict[key] else { return nil }
            let c = day["c"] ?? 0
            let w = day["w"] ?? 0
            if c == 0 && w == 0 && (day["words"] ?? 0) == 0 { return nil }
            return DailyStats(dateString: key, correct: c, wrong: w, wordsLearned: day["words"] ?? 0)
        }
    }
    
    /// 今日起往前 N 天（今天 + 前 N-1 天），每天都可选，无记录则显示 0
    func getLastDaysWithStats(days: Int) -> [DailyStats] {
        let dict = getDailyStatsDict()
        let cal = Calendar.current
        var result: [DailyStats] = []
        for offset in 0..<days {
            guard let date = cal.date(byAdding: .day, value: -offset, to: Date()) else { continue }
            let key = Self.dateString(for: date)
            let day = dict[key]
            let c = day?["c"] ?? 0
            let w = day?["w"] ?? 0
            let words = day?["words"] ?? 0
            result.append(DailyStats(dateString: key, correct: c, wrong: w, wordsLearned: words))
        }
        return result
    }
    
    // MARK: - Imported Questions (导入的题)
    
    func addImportedQuestionIds(_ ids: [Int]) {
        var set = Set(getImportedQuestionIds())
        set.formUnion(ids)
        UserDefaults.standard.set(Array(set), forKey: importedQuestionIdsKey)
        UserDefaults.standard.synchronize()
    }
    
    func getImportedQuestionIds() -> [Int] {
        (UserDefaults.standard.array(forKey: importedQuestionIdsKey) as? [Int]) ?? []
    }
    
    // MARK: - Parsed Words (自定义单词本：试卷解析出的超纲词)
    
    func getParsedWords() -> [ParsedWord] {
        guard let data = UserDefaults.standard.data(forKey: parsedWordsKey),
              let decoded = try? JSONDecoder().decode([ParsedWord].self, from: data) else {
            return []
        }
        return decoded
    }
    
    func addParsedWords(_ words: [ParsedWord]) {
        var current = getParsedWords()
        var existingIds = Set(current.map { $0.id })
        for w in words {
            if !existingIds.contains(w.id) {
                current.append(w)
                existingIds.insert(w.id)
            }
        }
        saveParsedWords(current)
    }
    
    func setParsedWords(_ words: [ParsedWord]) {
        saveParsedWords(words)
    }
    
    func removeParsedWord(id: String) {
        var current = getParsedWords()
        current.removeAll { $0.id == id }
        saveParsedWords(current)
    }
    
    private func saveParsedWords(_ words: [ParsedWord]) {
        if let data = try? JSONEncoder().encode(words) {
            UserDefaults.standard.set(data, forKey: parsedWordsKey)
            UserDefaults.standard.synchronize()
        }
    }
}
