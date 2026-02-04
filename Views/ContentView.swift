//
//  ContentView.swift
//  EHExam
//
//  Main content view with tab navigation
//

import SwiftUI

/// 我的 tab：单词本、自定义单词本、设置；支持从「导入的题」空状态跳转并自动打开试卷导入
private struct MineTabView: View {
    @ObservedObject var viewModel: QuestionViewModel
    @Binding var selectedTab: Int
    @State private var navigateToSettingsWithImport = false
    @State private var refreshSeed = 0
    
    /// 单词本总数 = 题目核心词 + 收藏的单词（与 WordBookView 逻辑一致）
    private var wordBookCount: Int {
        let _ = refreshSeed
        var coreSet = Set<String>()
        for q in viewModel.questions {
            for c in q.coreWords {
                coreSet.insert(c.word.lowercased())
            }
        }
        let vocabWords = StorageService.shared.getVocabularyWords()
        let vocabOnly = vocabWords.filter { !coreSet.contains($0.lowercased()) }
        return coreSet.count + vocabOnly.count
    }
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: WordBookView().environmentObject(viewModel)) {
                    HStack {
                        Label("单词本", systemImage: "book.closed.fill")
                        Spacer()
                        Text("(\(wordBookCount))")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                }
                NavigationLink(destination: CustomWordBookView().environmentObject(viewModel)) {
                    HStack {
                        Label("自定义单词本", systemImage: "text.book.closed.fill")
                        Spacer()
                        Text("(\(StorageService.shared.getParsedWords().count))")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                }
                NavigationLink(
                    destination: SettingsView().environmentObject(viewModel),
                    isActive: $navigateToSettingsWithImport
                ) {
                    Label("设置", systemImage: "gearshape.fill")
                }
            }
            .navigationTitle("我的")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                refreshSeed += 1
                viewModel.ensureLoaded() // 确保题目已加载，以便正确统计核心词数量
                if AppNavCoordinator.shared.consumeImportExamTrigger() {
                    navigateToSettingsWithImport = true
                }
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = QuestionViewModel()
    @ObservedObject private var processing = ProcessingService.shared
    @ObservedObject private var navCoordinator = AppNavCoordinator.shared
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea(edges: .all)
            
            TabView(selection: $selectedTab) {
                HomeView()
                    .environmentObject(viewModel)
                    .tabItem {
                        Label("首页", systemImage: "house.fill")
                    }
                    .tag(0)
                
                Group {
                    if selectedTab == 1 {
                        QuestionView()
                            .environmentObject(viewModel)
                    } else {
                        Color(.systemGroupedBackground)
                    }
                }
                .tabItem {
                    Label("考试", systemImage: "book.fill")
                }
                .tag(1)
                
                WrongAnswerBookView()
                    .environmentObject(viewModel)
                    .tabItem {
                        Label("错题本", systemImage: "exclamationmark.triangle.fill")
                    }
                    .tag(2)
                
                FavoriteView()
                    .environmentObject(viewModel)
                    .tabItem {
                        Label("收藏", systemImage: "star.fill")
                    }
                    .tag(3)
                
                MineTabView(viewModel: viewModel, selectedTab: $selectedTab)
                .environmentObject(viewModel)
                .tabItem {
                    Label("我的", systemImage: "person.fill")
                }
                .tag(4)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accentColor(.blue)
            .onChange(of: navCoordinator.openSettingsAndImportExam) { newValue in
                if newValue { selectedTab = 4 }
            }
            
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
