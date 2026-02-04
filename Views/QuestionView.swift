//
//  QuestionView.swift
//  EHExam
//
//  Main question view for exam
//

import SwiftUI

// MARK: - Scroll Offset Preference Key

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - URL解码辅助函数

// 解码URL编码的辅助函数（处理所有可能的编码格式）
private func decodeURLEncoding(_ text: String) -> String {
    var decoded = text
    // 多次解码，处理嵌套编码
    for _ in 0..<3 {
        if let decodedText = decoded.removingPercentEncoding, decodedText != decoded {
            decoded = decodedText
        } else {
            break
        }
    }
    // 处理 %20 这种格式（带空格的情况）
    decoded = decoded.replacingOccurrences(of: "% 20", with: " ")
    decoded = decoded.replacingOccurrences(of: "%20", with: " ")
    decoded = decoded.replacingOccurrences(of: "%2C", with: ",")
    decoded = decoded.replacingOccurrences(of: "%2E", with: ".")
    decoded = decoded.replacingOccurrences(of: "%3F", with: "?")
    decoded = decoded.replacingOccurrences(of: "%21", with: "!")
    return decoded
}

// 检查字符是否为中日韩字符
private func isCJKCharacter(_ char: Character) -> Bool {
    guard let scalar = char.unicodeScalars.first else { return false }
    // CJK统一汉字范围
    return (0x4E00...0x9FFF).contains(scalar.value) ||
           (0x3400...0x4DBF).contains(scalar.value) || // 扩展A
           (0x20000...0x2A6DF).contains(scalar.value) || // 扩展B
           (0x3040...0x309F).contains(scalar.value) || // 平假名
           (0x30A0...0x30FF).contains(scalar.value) || // 片假名
           (0xAC00...0xD7AF).contains(scalar.value) // 韩文
}

// 检查文本是否为英文（简单判断）
private func isEnglishText(_ text: String) -> Bool {
    // 如果文本包含大量英文字母且中文字符很少，认为是英文
    let englishChars = text.filter { $0.isASCII && $0.isLetter }.count
    let chineseChars = text.filter { isCJKCharacter($0) }.count
    return englishChars > chineseChars * 2 && chineseChars < 3
}

struct QuestionView: View {
    @EnvironmentObject var viewModel: QuestionViewModel
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var settings = SettingsService.shared
    /// 是否以全屏 cover 呈现（从首页进入练习），有返回/导入按钮
    var isPresentedInCover: Bool = false
    @State private var showAnswerSheet = false
    @State private var showSmartParseSheet = false
    @State private var smartParseContent: String = ""
    @State private var isLoadingSmartParse = false
    @State private var isScrolledToTop = true
    
    var body: some View {
        GeometryReader { geometry in
            let horizontalPad = AppLayout.horizontalPadding(width: geometry.size.width)
            let isWide = geometry.size.width >= 400
            
            ZStack {
                // 背景色填充整个屏幕（包括安全区域外）
                Color(.systemBackground)
                    .ignoresSafeArea(.all, edges: .all)
                
                NavigationView {
                    ZStack {
                        // 内容背景（透明，让外层背景显示）
                        Color.clear
                        
                        Group {
                            if viewModel.isLoading {
                                ProgressView("加载题目中...")
                                    .font(AppFont.title2)
                            } else if let error = viewModel.errorMessage {
                                VStack(spacing: AppLayout.spacingL) {
                                    Image(systemName: "exclamationmark.triangle")
                                        .font(AppFont.largeTitle)
                                        .foregroundColor(.orange)
                                    Text(error)
                                        .font(AppFont.headline)
                                        .multilineTextAlignment(.center)
                                        .padding(AppLayout.spacingM)
                                    if isPresentedInCover {
                                        HStack(spacing: AppLayout.spacingM) {
                                            Button {
                                                dismiss()
                                            } label: {
                                                HStack(spacing: 6) {
                                                    Image(systemName: "chevron.left")
                                                    Text("返回")
                                                }
                                                .frame(maxWidth: .infinity)
                                                .frame(minHeight: AppLayout.minTouchTarget)
                                                .background(Color(.systemGray5))
                                                .foregroundColor(.primary)
                                                .cornerRadius(AppLayout.cornerRadiusCard)
                                            }
                                            if viewModel.learningMode == .imported {
                                                Button {
                                                    dismiss()
                                                    AppNavCoordinator.shared.triggerImportExam()
                                                } label: {
                                                    HStack(spacing: 6) {
                                                        Image(systemName: "square.and.arrow.down")
                                                        Text("导入")
                                                    }
                                                    .frame(maxWidth: .infinity)
                                                    .frame(minHeight: AppLayout.minTouchTarget)
                                                    .background(Color.accentColor)
                                                    .foregroundColor(.white)
                                                    .cornerRadius(AppLayout.cornerRadiusCard)
                                                }
                                            }
                                        }
                                        .padding(.horizontal, AppLayout.spacingL)
                                    } else {
                                        Button("重新加载") {
                                            viewModel.loadQuestions()
                                        }
                                        .buttonStyle(.borderedProminent)
                                    }
                                }
                                .padding(AppLayout.spacingM)
                            } else if let question = viewModel.currentQuestion {
                                ScrollViewReader { proxy in
                                    ScrollView(.vertical, showsIndicators: false) {
                                        VStack(alignment: .leading, spacing: isWide ? AppLayout.spacingXL : AppLayout.spacingL) {
                                            // 顶部检测视图
                                            GeometryReader { geometry in
                                                Color.clear
                                                    .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).minY)
                                            }
                                            .frame(height: 0)
                                            .id("top")
                                            
                                            // 答案结果提示（选择答案后立即显示）
                                            if let result = viewModel.answerResult {
                                                AnswerResultView(result: result)
                                                    .padding(.horizontal, horizontalPad)
                                                    .transition(.move(edge: .top).combined(with: .opacity))
                                            }
                                        
                                        // 原题（可选文本 + 长按 收藏/朗读/翻译）
                                        VStack(alignment: .leading, spacing: AppLayout.spacingM) {
                                            HStack {
                                                // 左边：上一题图标 + 第xx题
                                                HStack(spacing: AppLayout.spacingS) {
                                                    Button(action: { viewModel.goToPrevious() }) {
                                                        Image(systemName: "chevron.left")
                                                            .font(AppFont.headline)
                                                            .foregroundColor(viewModel.canGoPrevious ? .accentColor : .secondary)
                                                    }
                                                    .frame(minWidth: AppLayout.minTouchTarget, minHeight: AppLayout.minTouchTarget)
                                                    .disabled(!viewModel.canGoPrevious)
                                                    
                                                    Text(question.questionNumber)
                                                        .font(AppFont.headline)
                                                        .foregroundColor(.accentColor)
                                                }
                                                
                                                Spacer()
                                                
                                                // 右边：小喇叭 + 解析 + 收藏 + 下一题
                                                HStack(spacing: 4) {
                                                    if viewModel.showAnswer && viewModel.isTranslating {
                                                        ProgressView()
                                                            .scaleEffect(0.8)
                                                    }
                                                    Button {
                                                        SpeechService.shared.speak(decodeURLEncoding(question.questionText), language: "en-US")
                                                    } label: {
                                                        Image(systemName: "speaker.wave.2")
                                                            .font(.title3)
                                                            .foregroundColor(.accentColor)
                                                    }
                                                    .frame(minWidth: AppLayout.minTouchTarget, minHeight: AppLayout.minTouchTarget)
                                                    .accessibilityLabel("朗读")
                                                    Button {
                                                        let key = SettingsService.shared.deepSeekAPIKey ?? ""
                                                        guard !key.isEmpty else {
                                                            smartParseContent = "请在「设置」中配置 DeepSeek API Key"
                                                            showSmartParseSheet = true
                                                            return
                                                        }
                                                        isLoadingSmartParse = true
                                                        DeepSeekParseService.shared.requestQuestionParse(
                                                            question: question,
                                                            apiKey: key
                                                        ) { result in
                                                            DispatchQueue.main.async {
                                                                isLoadingSmartParse = false
                                                                switch result {
                                                                case .success(let text):
                                                                    smartParseContent = text
                                                                    showSmartParseSheet = true
                                                                case .failure:
                                                                    smartParseContent = "解析失败，请检查 API Key"
                                                                    showSmartParseSheet = true
                                                                }
                                                            }
                                                        }
                                                    } label: {
                                                        if isLoadingSmartParse {
                                                            ProgressView()
                                                                .scaleEffect(0.8)
                                                        } else {
                                                            Image(systemName: "sparkles")
                                                                .font(.title3)
                                                                .foregroundColor(.accentColor)
                                                        }
                                                    }
                                                    .frame(minWidth: AppLayout.minTouchTarget, minHeight: AppLayout.minTouchTarget)
                                                    .disabled(isLoadingSmartParse)
                                                    Button(action: { viewModel.toggleFavorite() }) {
                                                        Image(systemName: viewModel.isFavorite ? "star.fill" : "star")
                                                            .foregroundColor(viewModel.isFavorite ? .yellow : .secondary)
                                                            .font(.title3)
                                                    }
                                                    .frame(minWidth: AppLayout.minTouchTarget, minHeight: AppLayout.minTouchTarget)
                                                    Button(action: { viewModel.goToNext() }) {
                                                        Image(systemName: "chevron.right")
                                                            .font(AppFont.headline)
                                                            .foregroundColor(viewModel.canGoNext ? .accentColor : .secondary)
                                                    }
                                                    .frame(minWidth: AppLayout.minTouchTarget, minHeight: AppLayout.minTouchTarget)
                                                    .disabled(!viewModel.canGoNext)
                                                }
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 12) {
                                                // 可选文本：长按弹出 收藏/朗读/翻译
                                                SelectableTextWithMenu(text: decodeURLEncoding(question.questionText), language: "en-US", showSpeaker: false)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                            .padding(AppLayout.spacingM)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color(.systemGray6))
                                            .cornerRadius(AppLayout.cornerRadiusCard)
                                        }
                                        .padding(.horizontal, horizontalPad)
                                        
                                        // 选项
                                        VStack(alignment: .leading, spacing: AppLayout.spacingM) {
                                            HStack {
                                                Text("选项")
                                                    .font(AppFont.headline)
                                                    .foregroundColor(.accentColor)
                                                Spacer()
                                                if viewModel.showAnswer && viewModel.isTranslating {
                                                    Text("翻译中...")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                            
                                            // 使用乱序后的选项键和选项内容
                                            ForEach(viewModel.currentShuffledOptionKeys, id: \.self) { key in
                                                if let optionText = viewModel.currentShuffledOptions[key] {
                                                    OptionButtonWithTranslation(
                                                        optionKey: key,
                                                        optionText: decodeURLEncoding(optionText),
                                                        translatedText: viewModel.translatedOptions[key],
                                                        isSelected: viewModel.selectedAnswer == key,
                                                        isCorrect: (viewModel.answerResult != nil || viewModel.showAnswer) && viewModel.currentCorrectAnswer == key,
                                                        isWrong: (viewModel.answerResult != nil || viewModel.showAnswer) && viewModel.selectedAnswer == key && viewModel.selectedAnswer != viewModel.currentCorrectAnswer,
                                                        showTranslation: viewModel.selectedAnswer != nil // 选择答案后立即显示翻译
                                                    ) {
                                                        viewModel.selectAnswer(key)
                                                    }
                                                }
                                            }
                                        }
                                        .padding(.horizontal, horizontalPad)
                                        
                                        // 本题统计（提交后）：对xx题/错xx题
                                        if viewModel.showAnswer, let q = viewModel.currentQuestion {
                                            let correctQ = StorageService.shared.getCorrectCount(forQuestionId: q.id)
                                            let wrongQ = StorageService.shared.getWrongCount(forQuestionId: q.id)
                                            HStack(spacing: AppLayout.spacingM) {
                                                HStack(spacing: AppLayout.spacingXS) {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(.green)
                                                    Text("本题：对 \(correctQ) 次")
                                                        .font(AppFont.subheadline)
                                                        .foregroundColor(.green)
                                                }
                                                HStack(spacing: AppLayout.spacingXS) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(.red)
                                                    Text("错 \(wrongQ) 次")
                                                        .font(AppFont.subheadline)
                                                        .foregroundColor(.red)
                                                }
                                                Spacer()
                                            }
                                            .padding(.horizontal, horizontalPad)
                                        }
                                        
                                        // 答案和解析（显示时）
                                        if viewModel.showAnswer {
                                            AnswerDetailView(
                                                question: question,
                                                correctAnswer: viewModel.currentCorrectAnswer ?? question.correctAnswer,
                                                onSmartParseWord: { word, context in
                                                    isLoadingSmartParse = true
                                                    DeepSeekParseService.shared.requestWordParse(
                                                        word: word,
                                                        context: context,
                                                        apiKey: SettingsService.shared.deepSeekAPIKey ?? ""
                                                    ) { result in
                                                        DispatchQueue.main.async {
                                                            isLoadingSmartParse = false
                                                            switch result {
                                                            case .success(let text):
                                                                smartParseContent = text
                                                                showSmartParseSheet = true
                                                            case .failure:
                                                                smartParseContent = "解析失败"
                                                                showSmartParseSheet = true
                                                            }
                                                        }
                                                    }
                                                }
                                            )
                                            .padding(.horizontal, horizontalPad)
                                        }
                                        
                                        // 按钮区域
                                        VStack(spacing: AppLayout.spacingM) {
                                            HStack(spacing: AppLayout.spacingM) {
                                                Button(action: { viewModel.goToPrevious() }) {
                                                    HStack(spacing: 6) {
                                                        Image(systemName: "chevron.left")
                                                            .font(AppFont.body)
                                                        Text("上一题")
                                                    }
                                                    .frame(maxWidth: .infinity)
                                                    .frame(minHeight: AppLayout.minTouchTarget)
                                                    .background(viewModel.canGoPrevious ? Color.accentColor : Color(.systemGray4))
                                                    .foregroundColor(viewModel.canGoPrevious ? .white : .secondary)
                                                    .cornerRadius(AppLayout.cornerRadiusCard)
                                                    .font(AppFont.body)
                                                }
                                                .disabled(!viewModel.canGoPrevious)
                                                
                                                Button(action: { viewModel.goToNext() }) {
                                                    HStack(spacing: 6) {
                                                        Text("下一题")
                                                        Image(systemName: "chevron.right")
                                                            .font(AppFont.body)
                                                    }
                                                    .frame(maxWidth: .infinity)
                                                    .frame(minHeight: AppLayout.minTouchTarget)
                                                    .background(viewModel.canGoNext ? Color.accentColor : Color(.systemGray4))
                                                    .foregroundColor(viewModel.canGoNext ? .white : .secondary)
                                                    .cornerRadius(AppLayout.cornerRadiusCard)
                                                    .font(AppFont.body)
                                                }
                                                .disabled(!viewModel.canGoNext)
                                            }
                                            
                                            HStack(spacing: AppLayout.spacingM) {
                                                Button(action: { viewModel.showAnswerDirectly() }) {
                                                    Text("看答案")
                                                        .frame(maxWidth: .infinity)
                                                        .frame(minHeight: AppLayout.minTouchTarget)
                                                        .background(Color.orange)
                                                        .foregroundColor(.white)
                                                        .cornerRadius(AppLayout.cornerRadiusCard)
                                                        .font(AppFont.body)
                                                }
                                                
                                                if viewModel.selectedAnswer == nil {
                                                    Button(action: {}) {
                                                        Text("提交")
                                                            .frame(maxWidth: .infinity)
                                                            .frame(minHeight: AppLayout.minTouchTarget)
                                                            .background(Color(.systemGray4))
                                                            .foregroundColor(.secondary)
                                                            .cornerRadius(AppLayout.cornerRadiusCard)
                                                            .font(AppFont.body)
                                                    }
                                                    .disabled(true)
                                                } else {
                                                    Button(action: { viewModel.submitAnswer() }) {
                                                        Text("查看解析")
                                                            .frame(maxWidth: .infinity)
                                                            .frame(minHeight: AppLayout.minTouchTarget)
                                                            .background(Color.green)
                                                            .foregroundColor(.white)
                                                            .cornerRadius(AppLayout.cornerRadiusCard)
                                                            .font(AppFont.body)
                                                    }
                                                }
                                            }
                                        }
                                        .padding(.horizontal, horizontalPad)
                                        .padding(.top, AppLayout.spacingS)
                                        .padding(.bottom, AppLayout.spacingXL)
                                    }
                                    .padding(.top, AppLayout.spacingS)
                                    .padding(.bottom, AppLayout.spacingL)
                                    .coordinateSpace(name: "scroll")
                                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                                        // 当滚动到顶部附近（小于10）时，认为在顶部
                                        isScrolledToTop = value <= 10
                                    }
                                    .onAppear {
                                        isScrolledToTop = true
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button {
                                    dismiss()
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "chevron.left")
                                        Text("返回")
                                    }
                                    .foregroundColor(.accentColor)
                                }
                                .opacity(isScrolledToTop ? 1 : 0)
                                .allowsHitTesting(isScrolledToTop)
                                .accessibilityHidden(!isScrolledToTop)
                            }
                        }
                        .sheet(isPresented: $showSmartParseSheet) {
                            NavigationView {
                                ScrollView {
                                    Text(smartParseContent)
                                        .font(.body)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .navigationTitle("智能解析")
                                .navigationBarTitleDisplayMode(.inline)
                                .toolbar {
                                    ToolbarItem(placement: .cancellationAction) {
                                        Button("关闭") { showSmartParseSheet = false }
                                    }
                                }
                            }
                        }
                    } else {
                        Text("暂无题目")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                        }
                    }
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
        .onAppear {
            viewModel.ensureLoaded()
            // 学习模式下自动显示答案
            if settings.isStudyMode, viewModel.currentQuestion != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    viewModel.autoShowAnswerIfStudyMode()
                }
            }
        }
        .onChange(of: viewModel.currentQuestionIndex) { _ in
            // 当题目索引变化时，学习模式下自动显示答案
            if settings.isStudyMode {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    viewModel.autoShowAnswerIfStudyMode()
                }
            }
        }
        .onChange(of: settings.isStudyMode) { isEnabled in
            // 当学习模式切换时，如果开启则自动显示答案
            if isEnabled, viewModel.currentQuestion != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    viewModel.autoShowAnswerIfStudyMode()
                }
            }
        }
    }

struct OptionButton: View {
        let optionKey: String
        let optionText: String
        let isSelected: Bool
        let isCorrect: Bool
        let isWrong: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack(spacing: 16) {
                    // 选项字母
                    Text(optionKey + ")")
                        .font(.body)
                        .fontWeight(.semibold)
                        .frame(width: 36, height: 36)
                        .foregroundColor(isCorrect ? .white : (isWrong ? .white : .accentColor))
                        .background(
                            Circle()
                                .fill(isCorrect ? Color.white.opacity(0.3) : (isWrong ? Color.white.opacity(0.3) : Color.accentColor.opacity(0.1)))
                        )
                    
                    // 选项文本
                    Text(optionText)
                        .font(.body)
                        .foregroundColor(isCorrect ? .white : (isWrong ? .white : .primary))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
                    // 状态图标
                    if isCorrect {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    } else if isWrong {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    } else if isSelected {
                        Image(systemName: "circle.fill")
                            .font(.body)
                            .foregroundColor(.accentColor)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .frame(minHeight: 56) // 确保足够的触摸目标
                .background(
                    isCorrect ? Color.green :
                        isWrong ? Color.red :
                        isSelected ? Color.accentColor.opacity(0.1) :
                        Color(.systemGray6)
                )
                .cornerRadius(12) // iOS 标准圆角
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected && !isCorrect && !isWrong ? Color.accentColor : Color.clear, lineWidth: 2)
                )
                .shadow(color: (isCorrect || isWrong) ? Color.black.opacity(0.08) : Color.clear, radius: 2, x: 0, y: 1)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // 带翻译的选项按钮
    struct OptionButtonWithTranslation: View {
        let optionKey: String
        let optionText: String
        let translatedText: String?
        let isSelected: Bool
        let isCorrect: Bool
        let isWrong: Bool
        let showTranslation: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack(spacing: 16) {
                    // 选项字母
                    Text(optionKey + ")")
                        .font(.body)
                        .fontWeight(.semibold)
                        .frame(width: 36, height: 36)
                        .foregroundColor(isCorrect ? .white : (isWrong ? .white : .accentColor))
                        .background(
                            Circle()
                                .fill(isCorrect ? Color.white.opacity(0.3) : (isWrong ? Color.white.opacity(0.3) : Color.accentColor.opacity(0.1)))
                        )
                    
                    // 选项内容
                    VStack(alignment: .leading, spacing: 6) {
                        // 英文选项
                        Text(optionText)
                            .font(.body)
                            .foregroundColor(isCorrect ? .white : (isWrong ? .white : .primary))
                            .multilineTextAlignment(.leading)
                        
                        // 中文翻译（如果已翻译）
                        if let translated = translatedText, !translated.isEmpty, translated != optionText {
                            // 解码URL编码并检查是否为中文
                            let decodedTranslated = decodeURLEncoding(translated)
                            // 如果翻译结果是英文，不显示（避免显示错误的翻译）
                            if !isEnglishText(decodedTranslated) {
                                Text(decodedTranslated)
                                    .font(.subheadline)
                                    .foregroundColor(isCorrect ? .white.opacity(0.9) : (isWrong ? .white.opacity(0.9) : .secondary))
                                    .multilineTextAlignment(.leading)
                                    .padding(.top, 2)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
                    // 状态图标
                    if isCorrect {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                    } else if isWrong {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                    } else if isSelected {
                        Image(systemName: "circle.fill")
                            .font(.body)
                            .foregroundColor(.accentColor)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .frame(minHeight: 56) // 确保足够的触摸目标
                .background(
                    isCorrect ? Color.green :
                        isWrong ? Color.red :
                        isSelected ? Color.accentColor.opacity(0.1) :
                        Color(.systemGray6)
                )
                .cornerRadius(12) // iOS 标准圆角
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected && !isCorrect && !isWrong ? Color.accentColor : Color.clear, lineWidth: 2)
                )
                .shadow(color: (isCorrect || isWrong) ? Color.black.opacity(0.08) : Color.clear, radius: 2, x: 0, y: 1)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // 答案结果提示视图
    struct AnswerResultView: View {
        let result: AnswerResult
        
        var body: some View {
            HStack(spacing: 12) {
                Image(systemName: result.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(result.isCorrect ? .green : .red)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.isCorrect ? "回答正确！" : "回答错误")
                        .font(.headline)
                        .foregroundColor(result.isCorrect ? .green : .red)
                    
                    if case .wrong(let correctAnswer) = result {
                        Text("正确答案是: \(correctAnswer)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(result.isCorrect ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(result.isCorrect ? Color.green.opacity(0.2) : Color.red.opacity(0.2), lineWidth: 1)
            )
        }
    }

