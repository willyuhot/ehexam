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
                    }
                    .frame(minWidth: AppLayout.minTouchTarget, minHeight: AppLayout.minTouchTarget)
                    .buttonStyle(.plain)
                }
                if !parsedWord.meaningWithRoot.isEmpty {
                    SelectableTextWithMenu(text: parsedWord.meaningWithRoot, language: "zh-Hans", showSpeaker: false)
                        .font(AppFont.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            if !parsedWord.originalSentence.isEmpty {
                VStack(alignment: .leading, spacing: AppLayout.spacingXS) {
                    HStack {
                        Text("原文：")
                            .font(AppFont.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button {
                            SpeechService.shared.speak(parsedWord.originalSentence, language: "en-US")
                        } label: {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(AppFont.caption)
                                .foregroundColor(.accentColor)
                        }
                        .frame(minWidth: AppLayout.minTouchTarget, minHeight: AppLayout.minTouchTarget)
                        .buttonStyle(.plain)
                    }
                    SelectableTextWithMenu(text: parsedWord.originalSentence, language: "en-US", showSpeaker: false)
                        .font(AppFont.caption)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            if !parsedWord.translation.isEmpty {
                VStack(alignment: .leading, spacing: AppLayout.spacingXS) {
                    HStack {
                        Text("译文：")
                            .font(AppFont.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button {
                            SpeechService.shared.speak(parsedWord.translation, language: "zh-Hans")
                        } label: {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(AppFont.caption)
                                .foregroundColor(.accentColor)
                        }
                        .frame(minWidth: AppLayout.minTouchTarget, minHeight: AppLayout.minTouchTarget)
                        .buttonStyle(.plain)
                    }
                    SelectableTextWithMenu(text: parsedWord.translation, language: "zh-Hans", showSpeaker: false)
                        .font(AppFont.caption)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            if !parsedWord.memoryTips.isEmpty {
                VStack(alignment: .leading, spacing: AppLayout.spacingXS) {
                    Text("记忆要点：")
                        .font(AppFont.caption)
                        .foregroundColor(.secondary)
                    SelectableTextWithMenu(text: parsedWord.memoryTips, language: "zh-Hans", showSpeaker: false)
                        .font(AppFont.caption)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(.vertical, AppLayout.spacingS)
    }
}
