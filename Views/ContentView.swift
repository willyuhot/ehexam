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
            Color(.systemBackground)
                .ignoresSafeArea(edges: .all)
            
            TabView {
                HomeView()
                    .environmentObject(viewModel)
                    .tabItem {
                        Label("首页", systemImage: "house.fill")
                    }
                
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
                
                WordBookView()
                    .environmentObject(viewModel)
                    .tabItem {
                        Label("单词本", systemImage: "book.closed.fill")
                    }
                
                SettingsView()
                    .environmentObject(viewModel)
                    .tabItem {
                        Label("我们", systemImage: "person.2.fill")
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accentColor(.blue)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
