//
//  WordBookView.swift
//  EHExam
//
//  单词本：所有题目核心词 + 收藏的单词，单行可朗读
//

import SwiftUI

struct WordBookView: View {
    @EnvironmentObject var viewModel: QuestionViewModel
    
    /// 核心词去重（题目里的 coreWords）+ 用户收藏的单词
    private var allWords: [(String, String, String, Bool)] {
        var seen = Set<String>()
        var list: [(String, String, String, Bool)] = []
        for q in viewModel.questions {
            for c in q.coreWords {
                let w = c.word.lowercased()
                if !seen.contains(w) {
                    seen.insert(w)
                    list.append((c.word, c.phonetic, c.explanation, false))
                }
            }
        }
        for w in StorageService.shared.getVocabularyWords() where !seen.contains(w) {
            seen.insert(w)
            list.append((w, "", "", true))
        }
        return list.sorted { $0.0.lowercased() < $1.0.lowercased() }
    }
    
    var body: some View {
        NavigationView {
            List {
                if allWords.isEmpty {
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
                    ForEach(Array(allWords.enumerated()), id: \.offset) { _, item in
                        WordBookRow(
                            word: item.0,
                            phonetic: item.1,
                            explanation: item.2,
                            isFromVocab: item.3
                        )
                    }
                }
            }
            .navigationTitle("单词本")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct WordBookRow: View {
    let word: String
    let phonetic: String
    let explanation: String
    let isFromVocab: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: AppLayout.spacingM) {
            VStack(alignment: .leading, spacing: AppLayout.spacingXS) {
                HStack(spacing: AppLayout.spacingS) {
                    Text(word)
                        .font(AppFont.headline)
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
}
