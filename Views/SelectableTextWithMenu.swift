//
//  SelectableTextWithMenu.swift
//  EHExam
//
//  全屏可选文本 + 长按弹出「收藏 / 朗读 / 翻译」菜单（iOS 15 兼容）
//

import SwiftUI
import UIKit

/// 使用 UITextView 实现可选文本，长按选中后弹出自定义菜单：收藏、朗读、翻译
struct SelectableTextWithMenu: View {
    let text: String
    var language: String = "en-US"
    @State private var translationResult: String?
    @State private var showTranslationSheet = false
    
    var body: some View {
        SelectableTextViewRepresentable(
            text: text,
            language: language,
            onTranslate: { result in
                translationResult = result
                showTranslationSheet = true
            }
        )
        .sheet(isPresented: $showTranslationSheet) {
            if let t = translationResult {
                VStack(alignment: .leading, spacing: 16) {
                    Text("翻译")
                        .font(.headline)
                    Text(t)
                        .font(.body)
                    Spacer()
                }
                .padding()
            }
        }
    }
}

private final class SelectableTextViewRepresentable: UIViewRepresentable {
    let text: String
    let language: String
    let onTranslate: (String) -> Void
    
    init(text: String, language: String, onTranslate: @escaping (String) -> Void) {
        self.text = text
        self.language = language
        self.onTranslate = onTranslate
    }
    
    func makeUIView(context: Context) -> UITextView {
        let tv = UITextView()
        tv.text = text
        tv.font = .preferredFont(forTextStyle: .body)
        tv.adjustsFontForContentSizeCategory = true
        tv.isEditable = false
        tv.isSelectable = true
        tv.backgroundColor = .clear
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        tv.delegate = context.coordinator
        tv.addInteraction(UIContextMenuInteraction(delegate: context.coordinator))
        return tv
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, UITextViewDelegate, UIContextMenuInteractionDelegate {
        let parent: SelectableTextViewRepresentable
        
        init(_ parent: SelectableTextViewRepresentable) {
            self.parent = parent
        }
        
        func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
            guard let textView = interaction.view as? UITextView else { return nil }
            let word = wordAt(point: location, in: textView)
            guard !word.isEmpty else { return nil }
            
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                let addToVocab = UIAction(title: "加入单词本", image: UIImage(systemName: "star.circle")) { [weak self] _ in
                    StorageService.shared.addVocabularyWord(word)
                }
                let speak = UIAction(title: "朗读", image: UIImage(systemName: "speaker.wave.2")) { _ in
                    SpeechService.shared.speak(word, language: self.parent.language)
                }
                let translate = UIAction(title: "翻译", image: UIImage(systemName: "character.bubble")) { [weak self] _ in
                    TranslationService.shared.translate(word, from: "en", to: "zh-Hans") { result in
                        DispatchQueue.main.async {
                            self?.parent.onTranslate(result ?? word)
                        }
                    }
                }
                return UIMenu(title: word, children: [addToVocab, speak, translate])
            }
        }
        
        private func wordAt(point: CGPoint, in textView: UITextView) -> String {
            let layoutManager = textView.layoutManager
            let textContainer = textView.textContainer
            let textStorage = textView.textStorage
            var effectivePoint = point
            effectivePoint.x -= textView.textContainerInset.left
            effectivePoint.y -= textView.textContainerInset.top
            let charIndex = layoutManager.characterIndex(for: effectivePoint, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
            guard charIndex < textStorage.length else { return "" }
            let str = textStorage.string as NSString
            let alnum = CharacterSet.alphanumerics
            var start = charIndex
            while start > 0 {
                let idx = start - 1
                let ch = str.character(at: idx)
                if alnum.contains(UnicodeScalar(ch)!) { start -= 1 } else { break }
            }
            var end = charIndex
            while end < str.length {
                let ch = str.character(at: end)
                if alnum.contains(UnicodeScalar(ch)!) { end += 1 } else { break }
            }
            guard end > start else { return "" }
            return str.substring(with: NSRange(location: start, length: end - start)).trimmingCharacters(in: CharacterSet.punctuationCharacters)
        }
    }
}
