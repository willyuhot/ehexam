//
//  ContentView.swift
//  EHExam
//
//  Main content view with tab navigation
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = QuestionViewModel()
    @ObservedObject private var processing = ProcessingService.shared
    
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
                
                NavigationView {
                    List {
                        NavigationLink(destination: WordBookView().environmentObject(viewModel)) {
                            Label("单词本", systemImage: "book.closed.fill")
                        }
                        NavigationLink(destination: CustomWordBookView().environmentObject(viewModel)) {
                            Label("自定义单词本", systemImage: "text.book.closed.fill")
                        }
                        NavigationLink(destination: SettingsView().environmentObject(viewModel)) {
                            Label("设置", systemImage: "gearshape.fill")
                        }
                    }
                    .navigationTitle("我的")
                    .navigationBarTitleDisplayMode(.large)
                }
                .environmentObject(viewModel)
                .tabItem {
                    Label("我的", systemImage: "person.fill")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accentColor(.blue)
            
            // 全局解析进度条：切到其他页面仍显示，任务在后台继续
            if processing.isProcessing {
                VStack {
                    HStack(spacing: AppLayout.spacingS) {
                        ProgressView()
                        Text(processing.message)
                            .font(AppFont.subheadline)
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, AppLayout.spacingL)
                    .padding(.vertical, AppLayout.spacingM)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(AppLayout.cornerRadiusCard)
                    .shadow(color: .black.opacity(0.1), radius: 8)
                    Spacer()
                }
                .padding(.top, 60)
                .allowsHitTesting(false)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert(processing.completionTitle, isPresented: $processing.showCompletionAlert) {
            Button("确定") {
                processing.dismissCompletionAlert()
            }
        } message: {
            Text(processing.completionMessage)
        }
    }
}
