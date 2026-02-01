//
//  SettingsView.swift
//  EHExam
//
//  Settings view for app configuration
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var settings = SettingsService.shared
    @State private var apiKey: String = ""
    @State private var showAPIKeyAlert = false
    @State private var showFilePicker = false
    @State private var isProcessing = false
    @State private var processingMessage = ""
    @EnvironmentObject var viewModel: QuestionViewModel
    
    var body: some View {
        NavigationView {
            Form {
                // 正确率统计
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
                                Text("答对")
                                    .font(.body)
                                Spacer()
                                Text("\(correctCount) 次")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.green)
                            }
                            
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                Text("答错")
                                    .font(.body)
                                Spacer()
                                Text("\(wrongCount) 次")
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
                            Text("重置统计")
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
                    .disabled(!settings.hasDeepSeekAPIKey || isProcessing)
                    
                    if isProcessing {
                        HStack {
                            ProgressView()
                            Text(processingMessage)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("我们")
            .onAppear {
                apiKey = settings.deepSeekAPIKey ?? ""
            }
            .fileImporter(
                isPresented: $showFilePicker,
                allowedContentTypes: [.text, .plainText, .data],
                allowsMultipleSelection: false
            ) { result in
                handleFileSelection(result)
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
            processingMessage = "文件选择失败: \(error.localizedDescription)"
            isProcessing = false
        }
    }
    
    private func processExamFile(url: URL) {
        isProcessing = true
        processingMessage = "正在读取文件..."
        
        // 开始访问文件
        _ = url.startAccessingSecurityScopedResource()
        defer { url.stopAccessingSecurityScopedResource() }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // 读取文件内容
                let fileContent = try String(contentsOf: url, encoding: .utf8)
                
                DispatchQueue.main.async {
                    self.processingMessage = "正在解析试卷..."
                }
                
                // 调用解析服务
                ExamParserService.shared.parseExam(
                    content: fileContent,
                    apiKey: SettingsService.shared.deepSeekAPIKey ?? ""
                ) { questions, error in
                    DispatchQueue.main.async {
                        self.isProcessing = false
                        
                        if let error = error {
                            self.processingMessage = "解析失败: \(error.localizedDescription)"
                            return
                        }
                        
                        if let questions = questions, !questions.isEmpty {
                            // 将题目添加到题库
                            self.addQuestionsToBank(questions)
                            self.processingMessage = "成功解析 \(questions.count) 道题目并添加到题库"
                        } else {
                            self.processingMessage = "未能解析出题目，请检查文件格式"
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.processingMessage = "读取文件失败: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func addQuestionsToBank(_ questions: [Question]) {
        // 这里需要实现将题目添加到题库的逻辑
        // 可以追加到part.txt文件，或者使用其他存储方式
        viewModel.addQuestionsToBank(questions)
    }
}

#Preview {
    SettingsView()
        .environmentObject(QuestionViewModel())
}
