//
//  HomeView.swift
//  EHExam
//
//  Home 页：仪表盘、每日学习进度、按类型学习（错题/默认/导入/收藏）
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: QuestionViewModel
    @State private var selectedDayStats: StorageService.DailyStats?
    @State private var showPractice: Bool = false
    @State private var practiceMode: LearningMode = .default
    @State private var isStartingPractice: Bool = false
    
    /// 今日起往前 7 天（今天 + 6 天前），每天都可选
    private var recentDays: [StorageService.DailyStats] {
        StorageService.shared.getLastDaysWithStats(days: 7)
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
                .fullScreenCover(isPresented: $showPractice) {
                    PracticeContainerView(viewModel: viewModel)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - 今日概览（快捷卡片）
    
    private var todaySection: some View {
        VStack(alignment: .leading, spacing: AppLayout.spacingM) {
            HStack {
                Text("今日概览")
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
    
    // MARK: - 学习数据（日历网格，点击日期在下方展示详情）
    
    private var dashboardSection: some View {
        VStack(alignment: .leading, spacing: AppLayout.spacingM) {
            Text("学习数据")
                .font(AppFont.headline)
            
            StudyDataCalendarView(
                recentDays: recentDays,
                selectedDateString: selectedDayStats?.dateString,
                onSelectDay: { stats in
                    if selectedDayStats?.dateString == stats.dateString {
                        selectedDayStats = nil
                    } else {
                        selectedDayStats = stats
                    }
                }
            )
            
            if let stats = selectedDayStats {
                DayDetailInline(stats: stats)
                    .transition(.opacity.combined(with: .move(edge: .top)))
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
                        guard !isStartingPractice else { return }
                        isStartingPractice = true
                        practiceMode = mode
                        viewModel.setLearningMode(mode)
                        viewModel.loadQuestions(mode: mode) { applied in
                            DispatchQueue.main.async {
                                isStartingPractice = false
                                if applied { showPractice = true }
                            }
                        }
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
                    .disabled(isStartingPractice)
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

// MARK: - 学习数据日历网格（日一二三四五六 + 日期，点击出详情）

struct StudyDataCalendarView: View {
    let recentDays: [StorageService.DailyStats]
    let selectedDateString: String?
    let onSelectDay: (StorageService.DailyStats) -> Void
    
    private let weekdayLabels = ["日", "一", "二", "三", "四", "五", "六"]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    
    private var todayString: String {
        StorageService.dateString(for: Date())
    }
    
    var body: some View {
        VStack(spacing: AppLayout.spacingS) {
            // 星期标题
            HStack(spacing: 0) {
                ForEach(weekdayLabels, id: \.self) { label in
                    Text(label)
                        .font(AppFont.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            if recentDays.isEmpty {
                Text("暂无学习记录")
                    .font(AppFont.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(AppLayout.spacingL)
            } else {
                // 日期网格（每行 7 天）
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(recentDays, id: \.dateString) { stats in
                        CalendarDayCell(
                            stats: stats,
                            isToday: stats.dateString == todayString,
                            isSelected: stats.dateString == selectedDateString,
                            onTap: { onSelectDay(stats) }
                        )
                    }
                }
            }
        }
        .padding(AppLayout.spacingM)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(AppLayout.cornerRadiusCard)
    }
}

struct CalendarDayCell: View {
    let stats: StorageService.DailyStats
    let isToday: Bool
    let isSelected: Bool
    let onTap: () -> Void
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "zh_CN")
        guard let d = formatter.date(from: stats.dateString) else { return "?" }
        let f = DateFormatter()
        f.dateFormat = "d"
        f.locale = Locale(identifier: "zh_CN")
        return f.string(from: d)
    }
    
    var body: some View {
        Button(action: onTap) {
            Text(dayNumber)
                .font(AppFont.subheadline)
                .fontWeight(isToday || isSelected ? .semibold : .regular)
                .foregroundColor(isToday || isSelected ? .white : .primary)
                .frame(minWidth: 36, minHeight: 36)
                .background(
                    Circle()
                        .fill(isToday ? Color.red : (isSelected ? Color.accentColor : Color.clear))
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 某日详情（日期下方内联展示）

struct DayDetailInline: View {
    let stats: StorageService.DailyStats
    
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
        VStack(alignment: .leading, spacing: AppLayout.spacingM) {
            Text(displayDate)
                .font(AppFont.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            VStack(spacing: AppLayout.spacingM) {
                detailRow(title: "做题数", value: "\(stats.totalQuestions) 题", icon: "doc.text.fill")
                detailRow(title: "答对", value: "\(stats.correct) 题", icon: "checkmark.circle.fill", color: .green)
                detailRow(title: "答错", value: "\(stats.wrong) 题", icon: "xmark.circle.fill", color: .red)
                detailRow(title: "学词数", value: "\(stats.wordsLearned) 个", icon: "book.fill", color: .purple)
            }
            .padding(AppLayout.spacingM)
            .frame(maxWidth: .infinity)
            .background(Color(.tertiarySystemGroupedBackground))
            .cornerRadius(AppLayout.cornerRadiusCard)
        }
        .padding(.top, AppLayout.spacingS)
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

// 练习页容器：显式传入 viewModel，避免 fullScreenCover 内 @EnvironmentObject 传递失败导致闪退
private struct PracticeContainerView: View {
    @ObservedObject var viewModel: QuestionViewModel
    
    var body: some View {
        QuestionView(isPresentedInCover: true)
            .environmentObject(viewModel)
    }
}
