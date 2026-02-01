//
//  ProcessingService.swift
//  EHExam
//
//  全局解析任务状态：切到其他页面仍继续，完成后有提示
//

import Foundation
import SwiftUI

class ProcessingService: ObservableObject {
    static let shared = ProcessingService()
    
    @Published var isProcessing = false
    @Published var message = ""
    @Published var showCompletionAlert = false
    @Published var completionTitle = ""
    @Published var completionMessage = ""
    
    private var progressTimer: Timer?
    
    private init() {}
    
    /// - Parameter animateMessage: 若 API 无进度回调（如解析单词），则轮换提示语让用户知道任务在进行
    func startProcessing(initialMessage: String, animateMessage: Bool = false) {
        isProcessing = true
        message = initialMessage
        showCompletionAlert = false
        progressTimer?.invalidate()
        
        if animateMessage {
            startProgressAnimation()
        }
    }
    
    func updateMessage(_ msg: String) {
        message = msg
    }
    
    /// 开始轮换提示语（用于 API 无进度回调时，让用户知道任务在进行）
    func startMessageAnimation() {
        startProgressAnimation()
    }
    
    func finishWithSuccess(_ title: String, message: String) {
        progressTimer?.invalidate()
        progressTimer = nil
        isProcessing = false
        completionTitle = title
        completionMessage = message
        showCompletionAlert = true
    }
    
    func finishWithError(_ message: String) {
        progressTimer?.invalidate()
        progressTimer = nil
        isProcessing = false
        completionTitle = "解析失败"
        completionMessage = message
        showCompletionAlert = true
    }
    
    func dismissCompletionAlert() {
        showCompletionAlert = false
    }
    
    private func startProgressAnimation() {
        let messages: [String]
        if message.contains("超纲词") || message.contains("单词") {
            messages = [
                "正在分析试卷中的超纲词...",
                "AI 识别中...",
                "即将返回结果..."
            ]
        } else {
            messages = [
                "正在连接并解析试卷...",
                "AI 解析中...",
                "即将完成..."
            ]
        }
        var index = 0
        progressTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isProcessing else { return }
            index = (index + 1) % messages.count
            DispatchQueue.main.async {
                self.message = messages[index]
            }
        }
        RunLoop.main.add(progressTimer!, forMode: .common)
    }
}
