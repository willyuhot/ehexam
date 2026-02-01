//
//  HomeView.swift
//  EHExam
//
//  Home 页：仪表盘、每日学习进度、按类型学习（错题/默认/导入/收藏）
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: QuestionViewModel
    @State private var showDayDetail: Bool = false
    @State private var selectedDayStats: StorageService.DailyStats?
    @State private var showPractice: Bool = false
    @State private var practiceMode: LearningMode = .default
    
    private var recentDays: [StorageService.DailyStats] {
        StorageService.shared.getRecentDaysWithStats(limit: 14)
    }
    
    private var todayStats: StorageService.DailyStats? {
        StorageService.shared.getDailyStats(for: Date())
    }
    
    var body: some View {
        GeometryReader { geometry in
            let horizontalPad = AppLayout.horizontalPadding(width: geometry.size.width)
            NavigationView {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: AppLayout.spacingL) {
                        todaySection
                        dashboardSection
                        learningTypeSection
                    }
                    .padding(.horizontal, horizontalPad)
                    .padding(.top, AppLayout.spacingM)
                    .padding(.bottom, AppLayout.spacingXL)
                    .frame(maxWidth: .infinity, minHeight: geometry.size.height)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
                .navigationTitle("首页")
                .navigationBarTitleDisplayMode(.large)
                .sheet(isPresented: $showDayDetail) {
                    if let stats = selectedDayStats {
                        DayDetailSheet(stats: stats)
                    }
                }
                .fullScreenCover(isPresented: $showPractice) {
                    QuestionView()
                        .environmentObject(viewModel)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - 今日概览
    
    private var todaySection: some View {
        VStack(alignment: .leading, spacing: AppLayout.spacingM) {
            HStack {
                Text("今日学习")
                    .font(AppFont.headline)
                Spacer()
                Text(formattedToday())
                    .font(AppFont.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if let stats = todayStats, stats.totalQuestions > 0 || stats.wordsLearned > 0 {
                HStack(spacing: AppLayout.spacingL) {
                    statChip(title: "做题", value: "\(stats.totalQuestions)", color: .blue)
                    statChip(title: "对", value: "\(stats.correct)", color: .green)
                    statChip(title: "错", value: "\(stats.wrong)", color: .red)
                    statChip(title: "学词", value: "\(stats.wordsLearned)", color: .purple)
                }
                .padding(AppLayout.spacingM)
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(AppLayout.cornerRadiusCard)
            } else {
                Text("今天还没有学习记录")
                    .font(AppFont.subheadline)
                    .foregroundColor(.secondary)
                    .padding(AppLayout.spacingM)
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(AppLayout.cornerRadiusCard)
            }
        }
        .padding(AppLayout.spacingM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(AppLayout.cornerRadiusSection)
    }
    
    // MARK: - 仪表盘（最近几天）
    
    private var dashboardSection: some View {
        VStack(alignment: .leading, spacing: AppLayout.spacingM) {
            Text("学习进度")
                .font(AppFont.headline)
            
            if recentDays.isEmpty {
                Text("暂无学习记录")
                    .font(AppFont.subheadline)
                    .foregroundColor(.secondary)
                    .padding(AppLayout.spacingM)
                    .frame(maxWidth: .infinity)
            } else {
                VStack(spacing: 0) {
                    ForEach(recentDays, id: \.dateString) { day in
                        DayRow(stats: day) {
                            selectedDayStats = day
                            showDayDetail = true
                        }
                        if day.dateString != recentDays.last?.dateString {
                            Divider()
                                .padding(.leading, AppLayout.spacingM)
                        }
                    }
                }
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(AppLayout.cornerRadiusCard)
            }
        }
        .padding(AppLayout.spacingM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(AppLayout.cornerRadiusSection)
    }
    
    // MARK: - 选择学习类型
    
    private var learningTypeSection: some View {
        VStack(alignment: .leading, spacing: AppLayout.spacingM) {
            Text("选择学习类型")
                .font(AppFont.headline)
            
            VStack(spacing: AppLayout.spacingM) {
                ForEach(LearningMode.allCases, id: \.rawValue) { mode in
                    Button {
                        practiceMode = mode
                        viewModel.setLearningMode(mode)
                        viewModel.loadQuestions()
                        showPractice = true
                    } label: {
                        HStack(spacing: AppLayout.spacingM) {
                            Image(systemName: mode.icon)
                                .font(AppFont.title2)
                                .foregroundColor(.accentColor)
                                .frame(minWidth: AppLayout.minTouchTarget, minHeight: AppLayout.minTouchTarget)
                                .background(Color.accentColor.opacity(0.12))
                                .cornerRadius(AppLayout.cornerRadiusCard)
                            
                            VStack(alignment: .leading, spacing: AppLayout.spacingXS) {
                                Text(mode.rawValue)
                                    .font(AppFont.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                Text(subtitle(for: mode))
                                    .font(AppFont.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(AppFont.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(AppLayout.spacingM)
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(AppLayout.cornerRadiusCard)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(AppLayout.spacingM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(AppLayout.cornerRadiusSection)
    }
    
    private func statChip(title: String, value: String, color: Color) -> some View {
        VStack(spacing: AppLayout.spacingXS) {
            Text(value)
                .font(AppFont.title2)
                .fontWeight(.semibold)
                .foregroundColor(color)
            Text(title)
                .font(AppFont.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func formattedToday() -> String {
        let f = DateFormatter()
        f.dateFormat = "M月d日"
        f.locale = Locale(identifier: "zh_CN")
        return f.string(from: Date())
    }
    
    private func subtitle(for mode: LearningMode) -> String {
        switch mode {
        case .default: return "全部题目"
        case .wrong: return "\(StorageService.shared.getWrongAnswers().count) 道错题"
        case .favorite: return "\(StorageService.shared.getFavorites().count) 道收藏"
        case .imported: return "\(StorageService.shared.getImportedQuestionIds().count) 道导入题"
        }
    }
}

// MARK: - 单日行（可点击看详情）

struct DayRow: View {
    let stats: StorageService.DailyStats
    let onTap: () -> Void
    
    private var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "zh_CN")
        guard let d = formatter.date(from: stats.dateString) else { return stats.dateString }
        let f = DateFormatter()
        f.dateFormat = "M月d日 EEEE"
        f.locale = Locale(identifier: "zh_CN")
        return f.string(from: d)
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: AppLayout.spacingXS) {
                    Text(displayDate)
                        .font(AppFont.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    HStack(spacing: AppLayout.spacingM) {
                        Label("\(stats.totalQuestions) 题", systemImage: "doc.text")
                            .font(AppFont.caption)
                            .foregroundColor(.secondary)
                        Label("对 \(stats.correct)", systemImage: "checkmark.circle")
                            .font(AppFont.caption)
                            .foregroundColor(.green)
                        Label("错 \(stats.wrong)", systemImage: "xmark.circle")
                            .font(AppFont.caption)
                            .foregroundColor(.red)
                        Label("\(stats.wordsLearned) 词", systemImage: "book")
                            .font(AppFont.caption)
                            .foregroundColor(.purple)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(AppFont.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, AppLayout.spacingM)
            .padding(.vertical, AppLayout.spacingM)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 某日详情 Sheet

struct DayDetailSheet: View {
    let stats: StorageService.DailyStats
    @Environment(\.dismiss) private var dismiss
    
    private var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "zh_CN")
        guard let d = formatter.date(from: stats.dateString) else { return stats.dateString }
        let f = DateFormatter()
        f.dateFormat = "yyyy年M月d日 EEEE"
        f.locale = Locale(identifier: "zh_CN")
        return f.string(from: d)
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: AppLayout.spacingL) {
                Text(displayDate)
                    .font(AppFont.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal, AppLayout.spacingM)
                
                VStack(spacing: AppLayout.spacingM) {
                    detailRow(title: "做题数", value: "\(stats.totalQuestions) 题", icon: "doc.text.fill")
                    detailRow(title: "答对", value: "\(stats.correct) 题", icon: "checkmark.circle.fill", color: .green)
                    detailRow(title: "答错", value: "\(stats.wrong) 题", icon: "xmark.circle.fill", color: .red)
                    detailRow(title: "学词数", value: "\(stats.wordsLearned) 个", icon: "book.fill", color: .purple)
                }
                .padding(AppLayout.spacingM)
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(AppLayout.cornerRadiusCard)
                .padding(.horizontal, AppLayout.spacingM)
                
                Spacer()
            }
            .padding(.top, AppLayout.spacingL)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .navigationTitle("当日详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                }
            }
        }
    }
    
    private func detailRow(title: String, value: String, icon: String, color: Color = .accentColor) -> some View {
        HStack {
            Image(systemName: icon)
                .font(AppFont.body)
                .foregroundColor(color)
                .frame(width: 28, alignment: .center)
            Text(title)
                .font(AppFont.body)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(AppFont.body)
                .fontWeight(.semibold)
        }
        .padding(.vertical, AppLayout.spacingXS)
    }
}
