//
//  WordBookView.swift
//  EHExam
//
//  单词本：核心词 + 收藏词，单行可删、可点击调用 DeepSeek 智能解析（词根词缀拆解记忆）
//

import SwiftUI

struct WordBookView: View {
    @EnvironmentObject var viewModel: QuestionViewModel
    @State private var refreshSeed = 0
    @State private var showWordParseSheet = false
    @State private var selectedWord = ""
    @State private var selectedPhonetic = ""
    @State private var selectedContext: String?
    @State private var parseContent = ""
    @State private var isLoadingParse = false
    
    /// 题目核心词（不可删）
    private var coreWords: [(String, String, String)] {
        let _ = refreshSeed
        var seen = Set<String>()
        var list: [(String, String, String)] = []
        for q in viewModel.questions {
            for c in q.coreWords {
                let w = c.word.lowercased()
                if !seen.contains(w) {
                    seen.insert(w)
                    list.append((c.word, c.phonetic, c.explanation))
                }
            }
        }
        return list.sorted { $0.0.lowercased() < $1.0.lowercased() }
    }
    
    /// 用户收藏的单词（可单行删除）
    private var vocabWords: [(String, String, String)] {
        let _ = refreshSeed
        let coreSet = Set(coreWords.map { $0.0.lowercased() })
        return StorageService.shared.getVocabularyWords()
            .filter { !coreSet.contains($0.lowercased()) }
            .sorted { $0.lowercased() < $1.lowercased() }
            .map { ($0, "", "") }
    }
    
    var body: some View {
        NavigationView {
            List {
                if coreWords.isEmpty && vocabWords.isEmpty {
                    VStack(spacing: AppLayout.spacingM) {
                        Image(systemName: "book.closed")
                            .font(AppFont.largeTitle)
                            .foregroundColor(.secondary)
                        Text("单词本为空")
                            .font(AppFont.headline)
                        Text("做题或长按文本选择「加入单词本」")
                            .font(AppFont.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppLayout.spacingXL * 2)
                    .listRowSeparator(.hidden)
                } else {
                    if !vocabWords.isEmpty {
                        Section(header: Text("收藏的单词").font(AppFont.subheadline)) {
                            ForEach(vocabWords, id: \.0) { item in
                                wordRow(word: item.0, phonetic: item.1, explanation: item.2, isFromVocab: true)
                            }
                            .onDelete(perform: deleteVocabWords)
                        }
                    }
                    if !coreWords.isEmpty {
                        Section(header: Text("题目核心词").font(AppFont.subheadline)) {
                            ForEach(coreWords, id: \.0) { item in
                                wordRow(word: item.0, phonetic: item.1, explanation: item.2, isFromVocab: false)
                            }
                        }
                    }
                }
            }
            .id(refreshSeed)
            .navigationTitle("单词本")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showWordParseSheet) {
                WordParseSheet(
                    word: selectedWord,
                    phonetic: selectedPhonetic,
                    content: parseContent,
                    isLoading: isLoadingParse,
                    onDismiss: { showWordParseSheet = false }
                )
            }
        }
    }
    
    private func wordRow(word: String, phonetic: String, explanation: String, isFromVocab: Bool) -> some View {
        WordBookRow(
            word: word,
            phonetic: phonetic,
            explanation: explanation,
            isFromVocab: isFromVocab,
            onTap: {
                selectedWord = word
                selectedPhonetic = phonetic
                selectedContext = nil
                parseContent = ""
                showWordParseSheet = true
                requestWordParse(word: word, context: nil)
            }
        )
    }
    
    private func deleteVocabWords(at offsets: IndexSet) {
        let words = vocabWords
        for index in offsets.sorted(by: >) {
            if index < words.count {
                StorageService.shared.removeVocabularyWord(words[index].0)
            }
        }
        refreshSeed += 1
    }
    
    private func requestWordParse(word: String, context: String?) {
        let key = SettingsService.shared.deepSeekAPIKey ?? ""
        guard !key.isEmpty else {
            parseContent = "请在「设置」中配置 DeepSeek API Key 后使用智能解析"
            isLoadingParse = false
            return
        }
        isLoadingParse = true
        DeepSeekParseService.shared.requestWordParse(
            word: word,
            context: context,
            apiKey: key
        ) { result in
            DispatchQueue.main.async {
                isLoadingParse = false
                switch result {
                case .success(let text):
                    parseContent = text
                case .failure:
                    parseContent = "解析失败，请检查网络或 API Key"
                }
            }
        }
    }
}

struct WordBookRow: View {
    let word: String
    let phonetic: String
    let explanation: String
    let isFromVocab: Bool
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        Button(action: { onTap?() }) {
            HStack(alignment: .top, spacing: AppLayout.spacingM) {
                VStack(alignment: .leading, spacing: AppLayout.spacingXS) {
                    HStack(spacing: AppLayout.spacingS) {
                        Text(word)
                            .font(AppFont.headline)
                            .foregroundColor(.primary)
                        if !phonetic.isEmpty {
                            Text(phonetic)
                                .font(AppFont.subheadline)
                                .foregroundColor(.secondary)
                        }
                        if isFromVocab {
                            Image(systemName: "star.fill")
                                .font(AppFont.caption)
                                .foregroundColor(.yellow)
                        }
                    }
                    if !explanation.isEmpty {
                        Text(explanation)
                            .font(AppFont.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Button {
                    SpeechService.shared.speak(word, language: "en-US")
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(AppFont.title3)
                        .foregroundColor(.accentColor)
                        .frame(minWidth: AppLayout.minTouchTarget, minHeight: AppLayout.minTouchTarget)
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, AppLayout.spacingS)
        }
        .buttonStyle(.plain)
    }
}

/// 单词解析 Sheet：像咔咔背单词的拆解记忆界面
struct WordParseSheet: View {
    let word: String
    let phonetic: String
    let content: String
    let isLoading: Bool
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: AppLayout.spacingL) {
                    HStack(alignment: .top, spacing: AppLayout.spacingM) {
                        VStack(alignment: .leading, spacing: AppLayout.spacingXS) {
                            Text(word)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)
                            if !phonetic.isEmpty {
                                Text(phonetic)
                                    .font(AppFont.title3)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        Button {
                            SpeechService.shared.speak(word, language: "en-US")
                        } label: {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                                .frame(minWidth: AppLayout.minTouchTarget, minHeight: AppLayout.minTouchTarget)
                        }
                    }
                    .padding(AppLayout.spacingM)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(AppLayout.cornerRadiusCard)
                    
                    if isLoading {
                        HStack(spacing: AppLayout.spacingS) {
                            ProgressView()
                            Text("AI 解析中...")
                                .font(AppFont.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(AppLayout.spacingXL)
                    } else if !content.isEmpty {
                        VStack(alignment: .leading, spacing: AppLayout.spacingS) {
                            Label("词根词缀 · 拆解记忆", systemImage: "sparkles")
                                .font(AppFont.headline)
                                .foregroundColor(.accentColor)
                            Text(content)
                                .font(AppFont.body)
                                .lineSpacing(6)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(AppLayout.spacingM)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(AppLayout.cornerRadiusCard)
                    }
                }
                .padding(AppLayout.spacingM)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("智能解析")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { onDismiss() }
                }
            }
        }
    }
}
