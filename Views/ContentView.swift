//
//  ContentView.swift
//  EHExam
//
//  Main content view with tab navigation
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = QuestionViewModel()
    
    var body: some View {
        ZStack {
            // 背景色填充整个屏幕（包括安全区域外）
            Color(.systemBackground)
                .ignoresSafeArea(.all, edges: .all)
            
            // 内容在安全区域内
            TabView {
                QuestionView()
                    .environmentObject(viewModel)
                    .tabItem {
                        Label("考试", systemImage: "book.fill")
                    }
                
                WrongAnswerBookView()
                    .environmentObject(viewModel)
                    .tabItem {
                        Label("错题本", systemImage: "exclamationmark.triangle.fill")
                    }
                
                FavoriteView()
                    .environmentObject(viewModel)
                    .tabItem {
                        Label("收藏", systemImage: "star.fill")
                    }
                
                SettingsView()
                    .environmentObject(viewModel)
                    .tabItem {
                        Label("我们", systemImage: "person.2.fill")
                    }
            }
            .accentColor(.blue)
        }
    }
}
