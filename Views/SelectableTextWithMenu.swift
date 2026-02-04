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
    /// 是否在右侧显示朗读按钮
    var showSpeaker: Bool = false
    @State private var translationResult: String?
    @State private var showTranslationSheet = false
    
    var body: some View {
        SizingTextViewRepresentable(
            text: text,
            language: language,
            onTranslate: { result in
                translationResult = result
                showTranslationSheet = true
            }
        )
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .topTrailing) {
            if showSpeaker && !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Button {
                    SpeechService.shared.speak(text, language: language)
                } label: {
                    Image(systemName: "speaker.wave.2")
                        .font(.body)
                        .foregroundColor(.accentColor)
                }
                .frame(minWidth: AppLayout.minTouchTarget, minHeight: AppLayout.minTouchTarget)
                .accessibilityLabel("朗读")
            }
        }
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

/// 自定义 UITextView，用 bounds 宽度确保 textContainer 正确，intrinsicContentSize 返回完整内容高度
private final class SizingTextView: UITextView {
    /// 确保文本排版使用足够宽度，避免截断
    private var effectiveWidth: CGFloat {
        let screenW = UIScreen.main.bounds.width
        let minW: CGFloat = 280
        return max(bounds.width, screenW - 96, minW)
    }
    
    override var intrinsicContentSize: CGSize {
        let w = effectiveWidth
        textContainer.size = CGSize(width: w, height: .greatestFiniteMagnitude)
        layoutManager.ensureLayout(for: textContainer)
        let used = layoutManager.usedRect(for: textContainer)
        return CGSize(width: UIView.noIntrinsicMetric, height: ceil(used.height))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let w = effectiveWidth
        if abs(textContainer.size.width - w) > 1 {
            textContainer.size = CGSize(width: w, height: .greatestFiniteMagnitude)
            invalidateIntrinsicContentSize()
        }
    }
}

/// 纯 UITextView：无嵌套滚动，内容完整展开，由主页面 ScrollView 滚动
private struct SizingTextViewRepresentable: UIViewRepresentable {
    let text: String
    let language: String
    let onTranslate: (String) -> Void
    
    func makeUIView(context: Context) -> SizingTextView {
        let tv = context.coordinator.textView as! SizingTextView
        tv.text = text
        tv.textContainer.widthTracksTextView = false
        tv.textContainer.size = CGSize(width: max(UIScreen.main.bounds.width - 96, 280), height: .greatestFiniteMagnitude)
        return tv
    }
    
    func updateUIView(_ uiView: SizingTextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        uiView.invalidateIntrinsicContentSize()
        uiView.setNeedsLayout()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    final class Coordinator: NSObject, UITextViewDelegate, UIContextMenuInteractionDelegate {
        let parent: SizingTextViewRepresentable
        let textView: UITextView
        
        init(parent: SizingTextViewRepresentable) {
            self.parent = parent
            self.textView = SizingTextView()
            super.init()
            textView.font = .preferredFont(forTextStyle: .body)
            textView.adjustsFontForContentSizeCategory = true
            textView.isEditable = false
            textView.isSelectable = true
            textView.isScrollEnabled = false
            textView.backgroundColor = .clear
            textView.textContainerInset = .zero
            textView.textContainer.lineFragmentPadding = 0
            textView.delegate = self
            textView.addInteraction(UIContextMenuInteraction(delegate: self))
        }
        
        func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
            let textView = self.textView
            let word = wordAt(point: location, in: textView)
            guard !word.isEmpty else { return nil }
            let lang = parent.language
            let onTrans = parent.onTranslate
            
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                let addToVocab = UIAction(title: "加入单词本", image: UIImage(systemName: "star.circle")) { _ in
                    StorageService.shared.addVocabularyWord(word)
                }
                let speak = UIAction(title: "朗读", image: UIImage(systemName: "speaker.wave.2")) { _ in
                    SpeechService.shared.speak(word, language: lang)
                }
                let translate = UIAction(title: "翻译", image: UIImage(systemName: "character.bubble")) { _ in
                    TranslationService.shared.translate(word, from: "en", to: "zh-Hans") { result in
                        DispatchQueue.main.async {
                            onTrans(result ?? word)
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
