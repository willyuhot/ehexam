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
    
    static let shared = StorageService()
    
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
        UserDefaults.standard.synchronize()
    }
    
    func addWrongAnswerCount() {
        let currentCount = getWrongCount()
        UserDefaults.standard.set(currentCount + 1, forKey: wrongCountKey)
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
        UserDefaults.standard.synchronize()
    }
}
