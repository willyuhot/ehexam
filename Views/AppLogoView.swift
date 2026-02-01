//
//  AppLogoView.swift
//  EHExam
//
//  Exam paper style logo for the app
//

import SwiftUI

struct AppLogoView: View {
    var size: CGFloat = 60
    
    var body: some View {
        ZStack {
            // 试卷背景（白色）
            RoundedRectangle(cornerRadius: size * 0.1)
                .fill(Color.white)
                .frame(width: size * 0.9, height: size * 0.85)
                .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
            
            // 试卷上的横线（模拟答题纸）
            VStack(spacing: size * 0.08) {
                ForEach(0..<4) { _ in
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: size * 0.7, height: 1)
                }
            }
            
            // 试卷左上角的装订孔
            HStack(spacing: size * 0.15) {
                ForEach(0..<2) { _ in
                    Circle()
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: size * 0.08, height: size * 0.08)
                }
            }
            .offset(x: -size * 0.3, y: -size * 0.35)
            
            // 试卷上的字母 "EH"
            Text("EH")
                .font(.system(size: size * 0.3, weight: .bold, design: .rounded))
                .foregroundColor(.blue)
                .offset(y: size * 0.05)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 30) {
        AppLogoView(size: 60)
        AppLogoView(size: 80)
        AppLogoView(size: 100)
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
