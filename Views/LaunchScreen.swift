//
//  LaunchScreen.swift
//  EHExam
//
//  Launch screen to prevent black bars
//

import SwiftUI

struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            // 背景色
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(.all)
            
            VStack(spacing: 20) {
                // Logo
                AppLogoView(size: 120)
                
                Text("EHExam")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                Text("英语考试练习")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.white.opacity(0.9))
            }
        }
    }
}

#Preview {
    LaunchScreenView()
}
