//
//  SettingsView.swift
//  EHExam
//
//  Settings view for app configuration
//

import SwiftUI

private enum FilePickMode {
    case none
    case exam
    case wordParse
}

struct SettingsView: View {
    @ObservedObject private var settings = SettingsService.shared
    @ObservedObject private var processing = ProcessingService.shared
    @State private var apiKey: String = ""
    @State private var showAPIKeyAlert = false
    @State private var showFilePicker = false
    @State private var filePickMode: FilePickMode = .none
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
                
                // 学习模式切换
                Section(header: Text("学习模式")) {
                    Toggle(isOn: $settings.isStudyMode) {
                        HStack {
                            Image(systemName: settings.isStudyMode ? "book.fill" : "book")
                                .foregroundColor(.purple)
                            Text("学习模式")
                        }
                    }
                    
                    Text(settings.isStudyMode ? "直接显示答案和解析，适合快速学习" : "需要选择答案后才能查看解析")
                        .font(.caption)
                        .foregroundColor(.secondary)
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
                
                // 试卷管理
                Section(header: Text("试卷管理")) {
                    Button(action: {
                        filePickMode = .exam
                        showFilePicker = true
                    }) {
                        HStack {
                            Image(systemName: "doc.badge.plus")
                                .foregroundColor(.blue)
                            Text("试卷解析考题")
                        }
                    }
                    .disabled(!settings.hasDeepSeekAPIKey || processing.isProcessing)
                    
                    Button(action: {
                        filePickMode = .wordParse
                        showFilePicker = true
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
                if AppNavCoordinator.shared.consumeExamImportOnAppear(),
                   settings.hasDeepSeekAPIKey, !processing.isProcessing {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        filePickMode = .exam
                        showFilePicker = true
                    }
                }
            }
            .fileImporter(
                isPresented: $showFilePicker,
                allowedContentTypes: [.plainText, .text],
                allowsMultipleSelection: true
            ) { result in
                let mode = filePickMode
                filePickMode = .none
                switch mode {
                case .exam:
                    handleFileSelection(result)
                case .wordParse:
                    handleWordParseFileSelection(result)
                case .none:
                    break
                }
            }
            .alert("API Key已保存", isPresented: $showAPIKeyAlert) {
                Button("确定", role: .cancel) { }
            }
        }
    }
    
    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            processExamFiles(urls: urls)
        case .failure(let error):
            ProcessingService.shared.finishWithError("文件选择失败: \(error.localizedDescription)")
        }
    }
    
    private func processExamFiles(urls: [URL]) {
        guard !urls.isEmpty else { return }
        
        ProcessingService.shared.startProcessing(initialMessage: "正在读取 \(urls.count) 个文件...", animateMessage: false)
        
        DispatchQueue.global(qos: .userInitiated).async {
            var mergedContent = ""
            var readErrors: [String] = []
            for url in urls {
                let hasAccess = url.startAccessingSecurityScopedResource()
                do {
                    let content = try String(contentsOf: url, encoding: .utf8)
                    let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty {
                        if !mergedContent.isEmpty { mergedContent += "\n\n" }
                        mergedContent += trimmed
                    }
                } catch {
                    readErrors.append("\(url.lastPathComponent): \(error.localizedDescription)")
                }
                if hasAccess { url.stopAccessingSecurityScopedResource() }
            }
            
            let finalContent = mergedContent.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !finalContent.isEmpty else {
                DispatchQueue.main.async {
                    let errMsg = readErrors.isEmpty ? "所选文件均为空" : readErrors.joined(separator: "; ")
                    ProcessingService.shared.finishWithError(errMsg)
                }
                return
            }
            
            DispatchQueue.main.async {
                ProcessingService.shared.updateMessage("正在解析试卷...")
            }
            
            ExamParserService.shared.parseExam(
                content: finalContent,
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
                        let fileHint = urls.count > 1 ? "（来自 \(urls.count) 个文件）" : ""
                        ProcessingService.shared.finishWithSuccess("解析完成", message: "已解析 \(questions.count) 道题并加入题库\(fileHint)")
                    } else {
                        ProcessingService.shared.finishWithSuccess("解析完成", message: "未能解析出题目，请检查文件格式")
                    }
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
            processWordParseFiles(urls: urls)
        case .failure(let error):
            ProcessingService.shared.finishWithError("文件选择失败: \(error.localizedDescription)")
        }
    }
    
    private func processWordParseFiles(urls: [URL]) {
        guard !urls.isEmpty else { return }
        
        ProcessingService.shared.startProcessing(initialMessage: "正在读取 \(urls.count) 个文件...", animateMessage: false)
        
        DispatchQueue.global(qos: .userInitiated).async {
            var mergedContent = ""
            var readErrors: [String] = []
            for (i, url) in urls.enumerated() {
                let hasAccess = url.startAccessingSecurityScopedResource()
                do {
                    let content = try String(contentsOf: url, encoding: .utf8)
                    let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty {
                        if !mergedContent.isEmpty { mergedContent += "\n\n" }
                        mergedContent += "=== 文件\(i + 1): \(url.lastPathComponent) ===\n\n\(trimmed)"
                    }
                } catch {
                    readErrors.append("\(url.lastPathComponent): \(error.localizedDescription)")
                }
                if hasAccess { url.stopAccessingSecurityScopedResource() }
            }
            
            let finalContent = mergedContent.trimmingCharacters(in: .whitespacesAndNewlines)
            if finalContent.isEmpty {
                DispatchQueue.main.async {
                    let errMsg = readErrors.isEmpty ? "所选文件均为空" : readErrors.joined(separator: "; ")
                    ProcessingService.shared.finishWithError(errMsg)
                }
                return
            }
            
            if !readErrors.isEmpty {
                DispatchQueue.main.async {
                    ProcessingService.shared.updateMessage("部分文件读取失败，继续解析已读取内容...")
                }
            }
            
            DispatchQueue.main.async {
                ProcessingService.shared.updateMessage("正在解析超纲词...")
                ProcessingService.shared.startMessageAnimation()
            }
            
            DeepSeekParseService.shared.parseWordsFromExam(
                content: finalContent,
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
                            ProcessingService.shared.finishWithSuccess("解析完成", message: "已解析 \(words.count) 个超纲词（来自 \(urls.count) 个文件），已加入自定义单词本")
                        } else {
                            ProcessingService.shared.finishWithSuccess("解析完成", message: "未发现超出初中范围的单词")
                        }
                    case .failure(let error):
                        ProcessingService.shared.finishWithError(error.localizedDescription)
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(QuestionViewModel())
}
