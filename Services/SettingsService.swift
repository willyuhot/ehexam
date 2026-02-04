//
//  SettingsService.swift
//  EHExam
//
//  Manage app settings (shuffle mode, API keys)
//

import Foundation
import SwiftUI

class SettingsService: ObservableObject {
    private let shuffleModeKey = "shuffleMode" // true = 乱序, false = 正序
    private let deepSeekAPIKeyKey = "deepSeekAPIKey"
    private let studyModeKey = "studyMode" // true = 学习模式, false = 考试模式
    
    static let shared: SettingsService = {
        let service = SettingsService()
        return service
    }()
    
    @Published var isShuffleEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isShuffleEnabled, forKey: shuffleModeKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    @Published var isStudyMode: Bool {
        didSet {
            UserDefaults.standard.set(isStudyMode, forKey: studyModeKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    private init() {
        // 如果没有设置，默认使用编译时标志
        #if SHUFFLE_ENABLED
        let defaultValue = UserDefaults.standard.object(forKey: shuffleModeKey) as? Bool ?? true
        #else
        let defaultValue = UserDefaults.standard.object(forKey: shuffleModeKey) as? Bool ?? false
        #endif
        _isShuffleEnabled = Published(initialValue: defaultValue)
        
        // 学习模式默认关闭
        let studyModeValue = UserDefaults.standard.object(forKey: studyModeKey) as? Bool ?? false
        _isStudyMode = Published(initialValue: studyModeValue)
    }
    
    // MARK: - DeepSeek API Key
    
    var deepSeekAPIKey: String? {
        get {
            return UserDefaults.standard.string(forKey: deepSeekAPIKeyKey)
        }
        set {
            if let key = newValue, !key.isEmpty {
                UserDefaults.standard.set(key, forKey: deepSeekAPIKeyKey)
            } else {
                UserDefaults.standard.removeObject(forKey: deepSeekAPIKeyKey)
            }
            UserDefaults.standard.synchronize()
        }
    }
    
    var hasDeepSeekAPIKey: Bool {
        return deepSeekAPIKey != nil && !deepSeekAPIKey!.isEmpty
    }
}
