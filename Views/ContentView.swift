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
            // 背景色必须在最外层，完全填充
            Color(.systemBackground)
                .ignoresSafeArea(.all, edges: .all)
            
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
        .ignoresSafeArea(.all, edges: .all)
    }
}
