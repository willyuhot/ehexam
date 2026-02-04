//
//  AppNavCoordinator.swift
//  EHExam
//
//  全局导航协调：如从「导入的题」空状态跳转到设置导入
//

import Foundation
import SwiftUI

/// 从练习页「导入的题」空状态触发：切换到我的 tab，打开设置，并自动弹出试卷导入
final class AppNavCoordinator: ObservableObject {
    static let shared = AppNavCoordinator()
    
    /// 为 true 时：切换到我的 tab
    @Published var openSettingsAndImportExam: Bool = false
    
    /// 为 true 时：SettingsView onAppear 时触发试卷导入（一次性）
    @Published var openExamImportOnNextSettingsAppear: Bool = false
    
    private init() {}
    
    func triggerImportExam() {
        openSettingsAndImportExam = true
        openExamImportOnNextSettingsAppear = true
    }
    
    func consumeImportExamTrigger() -> Bool {
        let v = openSettingsAndImportExam
        openSettingsAndImportExam = false
        return v
    }
    
    func consumeExamImportOnAppear() -> Bool {
        let v = openExamImportOnNextSettingsAppear
        openExamImportOnNextSettingsAppear = false
        return v
    }
}
