//
//  QuestionView.swift
//  EHExam
//
//  Main question view for exam
//

import SwiftUI

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
    @State private var showAnswerSheet = false
    
    var body: some View {
        GeometryReader { geometry in
            let isLargeScreen = geometry.size.width > 430 // iPhone Pro Max 宽度约 430pt
            
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
                                .font(.title2)
                    } else if let error = viewModel.errorMessage {
                        VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        Text(error)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button("重新加载") {
                            viewModel.loadQuestions()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else if let question = viewModel.currentQuestion {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: isLargeScreen ? 28 : 24) {
                            // Logo和题号区域
                            HStack(spacing: 16) {
                                // Logo
                                AppLogoView(size: isLargeScreen ? 70 : 60)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(question.questionNumber)
                                        .font(isLargeScreen ? .title2 : .title3)
                                        .fontWeight(.bold)
                                    Text("英语考试练习")
                                        .font(isLargeScreen ? .body : .subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                // 收藏按钮
                                Button(action: {
                                    viewModel.toggleFavorite()
                                }) {
                                    Image(systemName: viewModel.isFavorite ? "star.fill" : "star")
                                        .foregroundColor(viewModel.isFavorite ? .yellow : .secondary)
                                        .font(isLargeScreen ? .title2 : .title3)
                                        .frame(width: 44, height: 44) // iOS 标准触摸目标
                                }
                            }
                            .padding(.horizontal, isLargeScreen ? 24 : 16)
                            .padding(.top, isLargeScreen ? 20 : 16)
                            
                            // 答案结果提示（选择答案后立即显示）
                            if let result = viewModel.answerResult {
                                AnswerResultView(result: result)
                                    .padding(.horizontal, isLargeScreen ? 24 : 16)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                            }
                            
                            // 原题
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("原题")
                                        .font(isLargeScreen ? .title3 : .headline)
                                        .foregroundColor(.accentColor)
                                    Spacer()
                                    if viewModel.showAnswer && viewModel.isTranslating {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    // 英文原题（确保解码URL编码）
                                    Text(decodeURLEncoding(question.questionText))
                                        .font(isLargeScreen ? .title3 : .body)
                                        .lineSpacing(isLargeScreen ? 8 : 6)
                                        .foregroundColor(.primary)
                                    
                                    // 中文翻译（优先显示翻译结果，如果翻译失败则显示原始译文）
                                    if viewModel.showAnswer {
                                        Divider()
                                            .padding(.vertical, 4)
                                        let translationText: String = {
                                            // 优先使用翻译API的结果
                                            if let translated = viewModel.translatedQuestion,
                                               !translated.isEmpty {
                                                let decoded = decodeURLEncoding(translated)
                                                if !decoded.isEmpty,
                                                   decoded != question.questionText,
                                                   !isEnglishText(decoded) {
                                                    return decoded
                                                }
                                            }
                                            // 如果翻译失败或返回英文，使用原始译文
                                            return decodeURLEncoding(question.translation)
                                        }()
                                        
                                        Text(translationText)
                                            .font(isLargeScreen ? .body : .subheadline)
                                            .lineSpacing(isLargeScreen ? 6 : 4)
                                            .foregroundColor(.secondary)
                                            .padding(.top, 4)
                                    }
                                }
                                .padding(isLargeScreen ? 20 : 16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, isLargeScreen ? 24 : 16)
                            
                            // 选项
                            VStack(alignment: .leading, spacing: isLargeScreen ? 20 : 16) {
                                HStack {
                                    Text("选项")
                                        .font(isLargeScreen ? .title3 : .headline)
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
                            .padding(.horizontal, isLargeScreen ? 24 : 16)
                            
                            // 答案和解析（显示时）
                            if viewModel.showAnswer {
                                AnswerDetailView(
                                    question: question,
                                    correctAnswer: viewModel.currentCorrectAnswer ?? question.correctAnswer
                                )
                                    .padding(.horizontal, isLargeScreen ? 24 : 16)
                            }
                            
                            // 按钮区域 - 使用标准 iOS 按钮样式
                            VStack(spacing: isLargeScreen ? 16 : 12) {
                                // 导航按钮
                                HStack(spacing: 12) {
                                    // 上一题
                                    Button(action: {
                                        viewModel.goToPrevious()
                                    }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "chevron.left")
                                                .font(.system(size: 15, weight: .semibold))
                                            Text("上一题")
                                        }
                                        .frame(maxWidth: .infinity)
                                        .frame(minHeight: 44) // iOS 最小触摸目标
                                        .background(viewModel.canGoPrevious ? Color.accentColor : Color(.systemGray4))
                                        .foregroundColor(viewModel.canGoPrevious ? .white : .secondary)
                                        .cornerRadius(10)
                                        .font(.body)
                                    }
                                    .disabled(!viewModel.canGoPrevious)
                                    
                                    // 下一题
                                    Button(action: {
                                        viewModel.goToNext()
                                    }) {
                                        HStack(spacing: 6) {
                                            Text("下一题")
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 15, weight: .semibold))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .frame(minHeight: 44)
                                        .background(viewModel.canGoNext ? Color.accentColor : Color(.systemGray4))
                                        .foregroundColor(viewModel.canGoNext ? .white : .secondary)
                                        .cornerRadius(10)
                                        .font(.body)
                                    }
                                    .disabled(!viewModel.canGoNext)
                                }
                                
                                // 操作按钮
                                HStack(spacing: 12) {
                                    // 看答案
                                    Button(action: {
                                        viewModel.showAnswerDirectly()
                                    }) {
                                        Text("看答案")
                                            .frame(maxWidth: .infinity)
                                            .frame(minHeight: 44)
                                            .background(Color.orange)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                            .font(.body)
                                    }
                                    
                                    // 提交（如果还没选择答案）
                                    if viewModel.selectedAnswer == nil {
                                        Button(action: {
                                            // 提示先选择答案
                                        }) {
                                            Text("提交")
                                                .frame(maxWidth: .infinity)
                                                .frame(minHeight: 44)
                                                .background(Color(.systemGray4))
                                                .foregroundColor(.secondary)
                                                .cornerRadius(10)
                                                .font(.body)
                                        }
                                        .disabled(true)
                                    } else {
                                        Button(action: {
                                            viewModel.submitAnswer()
                                        }) {
                                            Text("查看解析")
                                                .frame(maxWidth: .infinity)
                                                .frame(minHeight: 44)
                                                .background(Color.green)
                                                .foregroundColor(.white)
                                                .cornerRadius(10)
                                                .font(.body)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, isLargeScreen ? 24 : 16)
                            .padding(.top, 8)
                            .padding(.bottom, isLargeScreen ? 32 : 24)
                        }
                        .padding(.top, 8)
                        .padding(.bottom, isLargeScreen ? 28 : 20)
                    }
                    .frame(maxWidth: .infinity)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            HStack(spacing: 8) {
                                AppLogoView(size: 28)
                                Text("EHExam")
                                    .font(.headline)
                                    .foregroundColor(.primary)
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

