//
//  SettingsView.swift
//  EHExam
//
//  Settings view for app configuration
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var settings = SettingsService.shared
    @ObservedObject private var processing = ProcessingService.shared
    @State private var apiKey: String = ""
    @State private var showAPIKeyAlert = false
    @State private var showFilePicker = false
    @State private var showWordParseFilePicker = false
    @EnvironmentObject var viewModel: QuestionViewModel
    
    var body: some View {
        NavigationView {
            Form {
                // 正确率统计：对xx题 / 错xx题 + 重新计算
                Section(header: Text("学习统计")) {
                    let correctCount = StorageService.shared.getCorrectCount()
                    let wrongCount = StorageService.shared.getWrongCount()
                    let totalCount = StorageService.shared.getTotalCount()
                    let accuracyRate = StorageService.shared.getAccuracyRate()
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("对")
                                    .font(.body)
                                Spacer()
                                Text("\(correctCount) 题")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.green)
                            }
                            
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                Text("错")
                                    .font(.body)
                                Spacer()
                                Text("\(wrongCount) 题")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.red)
                            }
                            
                            Divider()
                            
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                    .foregroundColor(.blue)
                                Text("正确率")
                                    .font(.body)
                                Spacer()
                                if totalCount > 0 {
                                    Text(String(format: "%.1f%%", accuracyRate))
                                        .font(.body)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.blue)
                                } else {
                                    Text("暂无数据")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            if totalCount > 0 {
                                Text("共答题 \(totalCount) 次")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    
                    Button(action: {
                        StorageService.shared.resetStatistics()
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("重新计算")
                        }
                        .foregroundColor(.orange)
                    }
                }
                
                // 正序/乱序模式切换
                Section(header: Text("考试模式")) {
                    Toggle(isOn: Binding(
                        get: { settings.isShuffleEnabled },
                        set: { newValue in
                            settings.isShuffleEnabled = newValue
                            // 重新加载题目以应用新设置
                            viewModel.loadQuestions()
                        }
                    )) {
                        HStack {
                            Image(systemName: settings.isShuffleEnabled ? "shuffle" : "list.number")
                                .foregroundColor(.blue)
                            Text(settings.isShuffleEnabled ? "乱序模式" : "正序模式")
                        }
                    }
                    
                    Text(settings.isShuffleEnabled ? "题目和选项将随机打乱" : "题目和选项按原始顺序显示")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // DeepSeek API Key设置
                Section(header: Text("DeepSeek API配置")) {
                    SecureField("输入DeepSeek API Key", text: $apiKey)
                        .textContentType(.password)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    
                    if settings.hasDeepSeekAPIKey {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("API Key已配置")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: {
                        settings.deepSeekAPIKey = apiKey.isEmpty ? nil : apiKey
                        showAPIKeyAlert = true
                    }) {
                        HStack {
                            Image(systemName: "key.fill")
                            Text("保存API Key")
                        }
                    }
                    .disabled(apiKey.isEmpty && !settings.hasDeepSeekAPIKey)
                }
                
                // 上传试卷功能
                Section(header: Text("试卷管理")) {
                    Button(action: {
                        showFilePicker = true
                    }) {
                        HStack {
                            Image(systemName: "doc.badge.plus")
                                .foregroundColor(.blue)
                            Text("上传试卷并解析")
                        }
                    }
                    .disabled(!settings.hasDeepSeekAPIKey || processing.isProcessing)
                    
                    Button(action: {
                        showWordParseFilePicker = true
                    }) {
                        HStack {
                            Image(systemName: "text.magnifyingglass")
                                .foregroundColor(.purple)
                            Text("解析单词")
                        }
                    }
                    .disabled(!settings.hasDeepSeekAPIKey || processing.isProcessing)
                    
                    if processing.isProcessing {
                        HStack {
                            ProgressView()
                            Text(processing.message)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("设置")
            .onAppear {
                apiKey = settings.deepSeekAPIKey ?? ""
            }
            .fileImporter(
                isPresented: $showFilePicker,
                allowedContentTypes: [.plainText, .text],
                allowsMultipleSelection: false
            ) { result in
                handleFileSelection(result)
            }
            .fileImporter(
                isPresented: $showWordParseFilePicker,
                allowedContentTypes: [.plainText, .text],
                allowsMultipleSelection: false
            ) { result in
                handleWordParseFileSelection(result)
            }
            .alert("API Key已保存", isPresented: $showAPIKeyAlert) {
                Button("确定", role: .cancel) { }
            }
        }
    }
    
    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                processExamFile(url: url)
            }
        case .failure(let error):
            ProcessingService.shared.finishWithError("文件选择失败: \(error.localizedDescription)")
        }
    }
    
    private func processExamFile(url: URL) {
        ProcessingService.shared.startProcessing(initialMessage: "正在读取文件...", animateMessage: false)
        
        let hasAccess = url.startAccessingSecurityScopedResource()
        
        DispatchQueue.global(qos: .userInitiated).async {
            defer { if hasAccess { url.stopAccessingSecurityScopedResource() } }
            do {
                // 读取文件内容（仅支持 UTF-8 纯文本；Word .doc/.docx 为二进制，会失败）
                let fileContent = try String(contentsOf: url, encoding: .utf8)
                guard !fileContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    DispatchQueue.main.async {
                        ProcessingService.shared.finishWithError("文件为空，请选择有内容的 TXT 文件")
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    ProcessingService.shared.updateMessage("正在解析试卷...")
                }
                
                // 调用解析服务
                ExamParserService.shared.parseExam(
                    content: fileContent,
                    apiKey: SettingsService.shared.deepSeekAPIKey ?? "",
                    onProgress: { msg in
                        DispatchQueue.main.async {
                            ProcessingService.shared.updateMessage(msg)
                        }
                    }
                ) { questions, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            ProcessingService.shared.finishWithError(error.localizedDescription)
                            return
                        }
                        
                        if let questions = questions, !questions.isEmpty {
                            self.addQuestionsToBank(questions)
                            ProcessingService.shared.finishWithSuccess("解析完成", message: "已解析 \(questions.count) 道题并加入题库")
                        } else {
                            ProcessingService.shared.finishWithSuccess("解析完成", message: "未能解析出题目，请检查文件格式")
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    ProcessingService.shared.finishWithError("无法读取为文本。请使用 TXT 格式")
                }
            }
        }
    }
    
    private func addQuestionsToBank(_ questions: [Question]) {
        viewModel.addQuestionsToBank(questions)
    }
    
    private func handleWordParseFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                processWordParseFile(url: url)
            }
        case .failure(let error):
            ProcessingService.shared.finishWithError("文件选择失败: \(error.localizedDescription)")
        }
    }
    
    private func processWordParseFile(url: URL) {
        ProcessingService.shared.startProcessing(initialMessage: "正在读取文件...", animateMessage: false)
        
        let hasAccess = url.startAccessingSecurityScopedResource()
        
        DispatchQueue.global(qos: .userInitiated).async {
            defer { if hasAccess { url.stopAccessingSecurityScopedResource() } }
            do {
                let fileContent = try String(contentsOf: url, encoding: .utf8)
                guard !fileContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    DispatchQueue.main.async {
                        ProcessingService.shared.finishWithError("文件为空，请选择有内容的 TXT 文件")
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    ProcessingService.shared.updateMessage("正在解析超纲词...")
                    ProcessingService.shared.startMessageAnimation()
                }
                
                DeepSeekParseService.shared.parseWordsFromExam(
                    content: fileContent,
                    apiKey: SettingsService.shared.deepSeekAPIKey ?? "",
                    onProgress: { msg in
                        DispatchQueue.main.async {
                            ProcessingService.shared.updateMessage(msg)
                        }
                    }
                ) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let words):
                            if !words.isEmpty {
                                StorageService.shared.addParsedWords(words)
                                ProcessingService.shared.finishWithSuccess("解析完成", message: "已解析 \(words.count) 个超纲词，已加入自定义单词本")
                            } else {
                                ProcessingService.shared.finishWithSuccess("解析完成", message: "未发现超出初中范围的单词")
                            }
                        case .failure(let error):
                            ProcessingService.shared.finishWithError(error.localizedDescription)
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    ProcessingService.shared.finishWithError("无法读取文件，请使用 TXT 格式")
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(QuestionViewModel())
}
