//
//  AppLayout.swift
//  EHExam
//
//  统一布局与字体规范：跟随系统 Dynamic Type，8pt 网格，适配各屏幕
//

import SwiftUI

/// 布局常量：8pt 网格，适配不同屏幕
enum AppLayout {
    /// 间距（pt）
    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 16
    static let spacingL: CGFloat = 24
    static let spacingXL: CGFloat = 32
    
    /// 圆角
    static let cornerRadiusCard: CGFloat = 12
    static let cornerRadiusSection: CGFloat = 16
    
    /// 最小触摸区域（iOS HIG 44pt）
    static let minTouchTarget: CGFloat = 44
    
    /// 水平边距：随屏幕宽度适当放大，最大不超过固定值
    static func horizontalPadding(width: CGFloat) -> CGFloat {
        if width >= 400 { return 24 }
        if width >= 375 { return 20 }
        return 16
    }
    
    /// 内容最大宽度（iPad 等大屏时限制阅读宽度）
    static let contentMaxWidth: CGFloat = 600
}

/// 语义字体：全部使用系统字体，自动跟随 Dynamic Type
enum AppFont {
    static let largeTitle = Font.largeTitle
    static let title = Font.title
    static let title2 = Font.title2
    static let title3 = Font.title3
    static let headline = Font.headline
    static let body = Font.body
    static let callout = Font.callout
    static let subheadline = Font.subheadline
    static let footnote = Font.footnote
    static let caption = Font.caption
    static let caption2 = Font.caption2
}
