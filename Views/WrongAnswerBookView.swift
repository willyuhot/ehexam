//
//  WrongAnswerBookView.swift
//  EHExam
//
//  View for wrong answer book
//

import SwiftUI

struct WrongAnswerBookView: View {
    @EnvironmentObject var viewModel: QuestionViewModel
    
    var wrongQuestions: [Question] {
        viewModel.getWrongAnswerQuestions()
    }
    
    var body: some View {
        NavigationView {
            List {
                if wrongQuestions.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        Text("太棒了！")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("目前没有错题")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 100)
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(wrongQuestions) { question in
                        NavigationLink(destination: QuestionDetailView(question: question)
                            .environmentObject(viewModel)) {
                            WrongAnswerRow(question: question)
                        }
                    }
                }
            }
            .navigationTitle("错题本")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct WrongAnswerRow: View {
    let question: Question
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(question.questionNumber)
                .font(.headline)
                .foregroundColor(.red)
            
            Text(question.questionText)
                .font(.body)
                .lineLimit(2)
                .foregroundColor(.primary)
            
            HStack {
                Text("正确答案：\(question.correctAnswer)")
                    .font(.caption)
                    .foregroundColor(.green)
                Spacer()
            }
        }
        .padding(.vertical, 4)
    }
}

struct QuestionDetailView: View {
    let question: Question
    @EnvironmentObject var viewModel: QuestionViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 题号
                Text(question.questionNumber)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                // 原题
                VStack(alignment: .leading, spacing: 12) {
                    Text("原题")
                        .font(.headline)
                        .foregroundColor(.blue)
                    Text(question.questionText)
                        .font(.body)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // 选项
                VStack(alignment: .leading, spacing: 12) {
                    Text("选项")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    ForEach(["A", "B", "C", "D"], id: \.self) { key in
                        if let optionText = question.options[key] {
                            HStack {
                                Text(key + ")")
                                    .font(.headline)
                                    .frame(width: 30)
                                    .foregroundColor(question.correctAnswer == key ? .green : .primary)
                                
                                Text(optionText)
                                    .font(.body)
                                
                                Spacer()
                                
                                if question.correctAnswer == key {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                            .padding()
                            .background(question.correctAnswer == key ? Color.green.opacity(0.1) : Color(.systemGray6))
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)
                
                // 答案详情（错题本显示原始答案）
                AnswerDetailView(question: question, correctAnswer: question.correctAnswer)
                    .padding(.horizontal)
                
                // 操作按钮
                HStack(spacing: 15) {
                    Button(action: {
                        viewModel.goToQuestion(at: viewModel.questions.firstIndex(where: { $0.id == question.id }) ?? 0)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("练习此题")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .padding(.top)
        }
        .navigationTitle("题目详情")
        .navigationBarTitleDisplayMode(.inline)
    }
}
