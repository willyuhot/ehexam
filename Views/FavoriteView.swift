//
//  FavoriteView.swift
//  EHExam
//
//  View for favorite questions
//

import SwiftUI

struct FavoriteView: View {
    @EnvironmentObject var viewModel: QuestionViewModel
    
    var favoriteQuestions: [Question] {
        viewModel.getFavoriteQuestions()
    }
    
    var body: some View {
        NavigationView {
            List {
                if favoriteQuestions.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "star")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("还没有收藏")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("点击题目右上角的⭐来收藏")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 100)
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(favoriteQuestions) { question in
                        NavigationLink(destination: QuestionDetailView(question: question)
                            .environmentObject(viewModel)) {
                            FavoriteRow(question: question)
                        }
                    }
                }
            }
            .navigationTitle("收藏")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct FavoriteRow: View {
    let question: Question
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(question.questionNumber)
                    .font(.headline)
                    .foregroundColor(.orange)
                
                Text(question.questionText)
                    .font(.body)
                    .lineLimit(2)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
        }
        .padding(.vertical, 4)
    }
}
