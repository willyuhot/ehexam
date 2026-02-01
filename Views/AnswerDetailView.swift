//
//  AnswerDetailView.swift
//
//  Shared view for displaying answer details
//

import SwiftUI

struct AnswerDetailView: View {
    let question: Question
    let correctAnswer: String // 乱序后的正确答案
    var onSmartParseWord: ((String, String?) -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppLayout.spacingM) {
            HStack {
                Text("正确答案：")
                    .font(AppFont.headline)
                Text(correctAnswer)
                    .font(AppFont.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            
            Divider()
                .padding(.vertical, AppLayout.spacingXS)
            
            VStack(alignment: .leading, spacing: AppLayout.spacingS) {
                Text("译文")
                    .font(AppFont.headline)
                    .foregroundColor(.accentColor)
                SelectableTextWithMenu(text: question.translation, language: "zh-Hans")
                    .font(AppFont.body)
                    .padding(AppLayout.spacingM)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(AppLayout.cornerRadiusCard)
            }
            
            if !question.keyPoint.isEmpty {
                VStack(alignment: .leading, spacing: AppLayout.spacingS) {
                    Text("【考点·高效记忆】")
                        .font(AppFont.headline)
                        .foregroundColor(.purple)
                    SelectableTextWithMenu(text: question.keyPoint, language: "zh-Hans")
                        .font(AppFont.body)
                        .padding(AppLayout.spacingM)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(AppLayout.cornerRadiusCard)
                }
            }
            
            if !question.analysis.isEmpty {
                VStack(alignment: .leading, spacing: AppLayout.spacingS) {
                    Text("【解析·秒选思路】")
                        .font(AppFont.headline)
                        .foregroundColor(.orange)
                    SelectableTextWithMenu(text: question.analysis, language: "zh-Hans")
                        .font(AppFont.body)
                        .padding(AppLayout.spacingM)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(AppLayout.cornerRadiusCard)
                }
            }
            
            if !question.coreWords.isEmpty {
                VStack(alignment: .leading, spacing: AppLayout.spacingS) {
                    Text("核心词")
                        .font(AppFont.headline)
                        .foregroundColor(.accentColor)
                    
                    ForEach(question.coreWords.indices, id: \.self) { index in
                        let word = question.coreWords[index]
                        HStack(alignment: .top, spacing: AppLayout.spacingS) {
                            VStack(alignment: .leading, spacing: AppLayout.spacingXS) {
                                HStack {
                                    Text(word.word)
                                        .font(AppFont.headline)
                                    if !word.phonetic.isEmpty {
                                        Text(word.phonetic)
                                            .font(AppFont.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                SelectableTextWithMenu(text: word.explanation, language: "zh-Hans")
                                    .font(AppFont.caption)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            if let onParse = onSmartParseWord {
                                Button { onParse(word.word, question.questionText) } label: {
                                    Image(systemName: "sparkles")
                                        .font(AppFont.subheadline)
                                        .foregroundColor(.accentColor)
                                }
                                .frame(minWidth: AppLayout.minTouchTarget, minHeight: AppLayout.minTouchTarget)
                            }
                        }
                        .padding(.vertical, AppLayout.spacingXS)
                    }
                    .padding(AppLayout.spacingM)
                    .background(Color(.systemGray6))
                    .cornerRadius(AppLayout.cornerRadiusCard)
                }
            }
        }
        .padding(AppLayout.spacingM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(AppLayout.cornerRadiusCard)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}
