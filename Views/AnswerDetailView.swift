//
//  AnswerDetailView.swift
//
//  Shared view for displaying answer details
//

import SwiftUI

struct AnswerDetailView: View {
    let question: Question
    let correctAnswer: String // 乱序后的正确答案
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 正确答案（显示乱序后的选项）
            HStack {
                Text("正确答案：")
                    .font(.headline)
                Text(correctAnswer)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            
            Divider()
                .padding(.vertical, 4)
            
            // 译文
            VStack(alignment: .leading, spacing: 8) {
                Text("译文")
                    .font(.headline)
                    .foregroundColor(.accentColor)
                Text(question.translation)
                    .font(.body)
                    .padding(16)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
            
            // 考点
            if !question.keyPoint.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("【考点·高效记忆】")
                        .font(.headline)
                        .foregroundColor(.purple)
                    Text(question.keyPoint)
                        .font(.body)
                        .padding(16)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(12)
                }
            }
            
            // 解析
            if !question.analysis.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("【解析·秒选思路】")
                        .font(.headline)
                        .foregroundColor(.orange)
                    Text(question.analysis)
                        .font(.body)
                        .padding(16)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                }
            }
            
            // 核心词
            if !question.coreWords.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("核心词")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                    
                    ForEach(question.coreWords.indices, id: \.self) { index in
                        let word = question.coreWords[index]
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(word.word)
                                    .font(.headline)
                                if !word.phonetic.isEmpty {
                                    Text(word.phonetic)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Text(word.explanation)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .padding(16)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}
