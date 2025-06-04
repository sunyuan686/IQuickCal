//
//  HistoryView.swift
//  IQuickCal
//
//  Created by sunyuan on 2025/6/4.
//

import SwiftUI
import SwiftData
import Charts

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PracticeSession.startTime, order: .reverse) private var sessions: [PracticeSession]
    
    @State private var selectedTimeFilter: TimeFilter = .week
    @State private var selectedQuestionType: QuestionType?
    
    enum TimeFilter: String, CaseIterable {
        case day = "今天"
        case week = "本周"
        case month = "本月"
        case all = "全部"
    }
    
    var filteredSessions: [PracticeSession] {
        let calendar = Calendar.current
        let now = Date()
        
        var filtered = sessions.filter { $0.isCompleted }
        
        // 时间过滤
        switch selectedTimeFilter {
        case .day:
            filtered = filtered.filter { calendar.isDate($0.startTime, inSameDayAs: now) }
        case .week:
            let weekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
            filtered = filtered.filter { $0.startTime >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            filtered = filtered.filter { $0.startTime >= monthAgo }
        case .all:
            break
        }
        
        // 题型过滤
        if let questionType = selectedQuestionType {
            filtered = filtered.filter { $0.type == questionType }
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 时间过滤器
                    timeFilterSection
                    
                    // 题型过滤器
                    questionTypeFilterSection
                    
                    // 统计概览
                    if !filteredSessions.isEmpty {
                        statisticsOverview
                        
                        // 图表展示
                        chartsSection
                        
                        // 历史记录列表
                        historyListSection
                    } else {
                        emptyStateView
                    }
                }
                .padding()
            }
            .navigationTitle("练习历史")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var timeFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TimeFilter.allCases, id: \.self) { filter in
                    Button(action: {
                        selectedTimeFilter = filter
                    }) {
                        Text(filter.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedTimeFilter == filter ? Color.blue : Color(.systemGray5))
                            )
                            .foregroundColor(selectedTimeFilter == filter ? .white : .primary)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var questionTypeFilterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("题型筛选")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if selectedQuestionType != nil {
                    Button("清除") {
                        selectedQuestionType = nil
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(QuestionType.allCases, id: \.self) { type in
                        Button(action: {
                            selectedQuestionType = selectedQuestionType == type ? nil : type
                        }) {
                            Text(type.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedQuestionType == type ? Color.blue : Color(.systemGray6))
                                )
                                .foregroundColor(selectedQuestionType == type ? .white : .primary)
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var statisticsOverview: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
            OverviewCard(
                title: "练习次数",
                value: "\(filteredSessions.count)",
                icon: "chart.bar.fill",
                color: .blue
            )
            
            OverviewCard(
                title: "平均正确率",
                value: "\(Int(averageCorrectRate * 100))%",
                icon: "percent",
                color: .green
            )
            
            OverviewCard(
                title: "总练习时间",
                value: formatTotalTime(),
                icon: "clock.fill",
                color: .orange
            )
            
            OverviewCard(
                title: "总题数",
                value: "\(totalQuestions)",
                icon: "list.number",
                color: .purple
            )
        }
    }
    
    private var chartsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("数据图表")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 20) {
                // 正确率趋势图
                correctRateChart
                
                // 题型分布图
                questionTypeChart
            }
        }
    }
    
    @ViewBuilder
    private var correctRateChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("正确率趋势")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Chart(filteredSessions.suffix(10)) { session in
                LineMark(
                    x: .value("时间", session.startTime),
                    y: .value("正确率", session.correctRate * 100)
                )
                .foregroundStyle(.blue)
                .interpolationMethod(.catmullRom)
                
                PointMark(
                    x: .value("时间", session.startTime),
                    y: .value("正确率", session.correctRate * 100)
                )
                .foregroundStyle(.blue)
            }
            .frame(height: 150)
            .chartYScale(domain: 0...100)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    @ViewBuilder
    private var questionTypeChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("题型分布")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            let typeStats = getQuestionTypeStats()
            
            Chart(typeStats, id: \.type) { stat in
                BarMark(
                    x: .value("次数", stat.count),
                    y: .value("题型", stat.type.rawValue)
                )
                .foregroundStyle(by: .value("题型", stat.type.rawValue))
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var historyListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("练习记录")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVStack(spacing: 8) {
                ForEach(filteredSessions, id: \.id) { session in
                    HistoryRow(session: session)
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("暂无练习记录")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text("开始练习后，这里会显示你的练习历史")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    // 计算统计数据
    private var averageCorrectRate: Double {
        guard !filteredSessions.isEmpty else { return 0 }
        let total = filteredSessions.reduce(0.0) { $0 + $1.correctRate }
        return total / Double(filteredSessions.count)
    }
    
    private var totalQuestions: Int {
        filteredSessions.reduce(0) { $0 + $1.totalQuestions }
    }
    
    private func formatTotalTime() -> String {
        let total = filteredSessions.reduce(0.0) { $0 + $1.totalTime }
        let hours = Int(total) / 3600
        let minutes = (Int(total) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)小时\(minutes)分钟"
        } else {
            return "\(minutes)分钟"
        }
    }
    
    private func getQuestionTypeStats() -> [QuestionTypeStats] {
        var stats: [QuestionType: Int] = [:]
        
        for session in filteredSessions {
            stats[session.type, default: 0] += 1
        }
        
        return stats.map { QuestionTypeStats(type: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
}

struct OverviewCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
}

struct HistoryRow: View {
    let session: PracticeSession
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.type.rawValue)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(formatDate(session.startTime))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(session.correctRate * 100))%")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(session.correctRate >= 0.8 ? .green : .orange)
                
                Text("\(session.correctAnswers)/\(session.totalQuestions)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日 HH:mm"
        return formatter.string(from: date)
    }
}

struct QuestionTypeStats {
    let type: QuestionType
    let count: Int
}

#Preview {
    HistoryView()
        .modelContainer(for: [PracticeSession.self], inMemory: true)
}
