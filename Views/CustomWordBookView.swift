//
//  CustomWordBookView.swift
//  EHExam
//
//  自定义单词本：试卷解析出的超纲词，格式与单词本一致
//

import SwiftUI

struct CustomWordBookView: View {
    @EnvironmentObject var viewModel: QuestionViewModel
    @State private var refreshSeed = 0
    
    private var parsedWords: [ParsedWord] {
        let _ = refreshSeed
        return StorageService.shared.getParsedWords()
            .sorted { $0.word.lowercased() < $1.word.lowercased() }
    }
    
    var body: some View {
        NavigationView {
            List {
                if parsedWords.isEmpty {
                    VStack(spacing: AppLayout.spacingM) {
                        Image(systemName: "text.book.closed")
                            .font(AppFont.largeTitle)
                            .foregroundColor(.secondary)
                        Text("自定义单词本为空")
                            .font(AppFont.headline)
                        Text("在「设置 → 试卷管理 → 解析单词」中上传 TXT 试卷")
                            .font(AppFont.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppLayout.spacingXL * 2)
                    .listRowSeparator(.hidden)
                } else {
                    Section(header: Text("超纲词（超出初中范围）").font(AppFont.subheadline)) {
                        ForEach(parsedWords) { item in
                            CustomWordBookRow(parsedWord: item)
                        }
                        .onDelete(perform: deleteWords)
                    }
                }
            }
            .id(refreshSeed)
            .navigationTitle("自定义单词本")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func deleteWords(at offsets: IndexSet) {
        let words = parsedWords
        for index in offsets.sorted(by: >) {
            if index < words.count {
                StorageService.shared.removeParsedWord(id: words[index].id)
            }
        }
        refreshSeed += 1
    }
}

struct CustomWordBookRow: View {
    let parsedWord: ParsedWord
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppLayout.spacingS) {
            HStack(alignment: .top, spacing: AppLayout.spacingM) {
                VStack(alignment: .leading, spacing: AppLayout.spacingXS) {
                    HStack(spacing: AppLayout.spacingS) {
                        Text(parsedWord.word)
                            .font(AppFont.headline)
                            .foregroundColor(.primary)
                        if !parsedWord.phonetic.isEmpty {
                            Text(parsedWord.phonetic)
                                .font(AppFont.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button {
                            SpeechService.shared.speak(parsedWord.word, language: "en-US")
                        } label: {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(AppFont.title3)
                                .foregroundColor(.accentColor)
                                .frame(minWidth: AppLayout.minTouchTarget, minHeight: AppLayout.minTouchTarget)
                        }
                        .buttonStyle(.plain)
                    }
                    if !parsedWord.meaningWithRoot.isEmpty {
                        Text(parsedWord.meaningWithRoot)
                            .font(AppFont.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if !parsedWord.originalSentence.isEmpty {
                HStack(alignment: .top, spacing: AppLayout.spacingXS) {
                    Text("原文：")
                        .font(AppFont.caption)
                        .foregroundColor(.secondary)
                    Text(parsedWord.originalSentence)
                        .font(AppFont.caption)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    Button {
                        SpeechService.shared.speak(parsedWord.originalSentence, language: "en-US")
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(AppFont.caption)
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            if !parsedWord.translation.isEmpty {
                HStack(alignment: .top, spacing: AppLayout.spacingXS) {
                    Text("译文：")
                        .font(AppFont.caption)
                        .foregroundColor(.secondary)
                    Text(parsedWord.translation)
                        .font(AppFont.caption)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                }
            }
            
            if !parsedWord.memoryTips.isEmpty {
                VStack(alignment: .leading, spacing: AppLayout.spacingXS) {
                    Text("记忆要点：")
                        .font(AppFont.caption)
                        .foregroundColor(.secondary)
                    Text(parsedWord.memoryTips)
                        .font(AppFont.caption)
                        .foregroundColor(.primary)
                        .lineLimit(3)
                }
            }
        }
        .padding(.vertical, AppLayout.spacingS)
    }
}
