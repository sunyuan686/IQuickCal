//
//  MistakesView.swift
//  IQuickCal
//
//  Created by sunyuan on 2025/6/4.
//

import SwiftUI
import SwiftData

struct MistakesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WrongAnswer.lastWrongAt, order: .reverse) private var allWrongAnswers: [WrongAnswer]
    
    @State private var selectedFilter: MistakeFilter = .all
    @State private var showingClearAlert = false
    @State private var selectedWrongAnswer: WrongAnswer?
    @State private var showingRetryPractice = false
    
    enum MistakeFilter: String, CaseIterable {
        case all = "全部"
        case notMastered = "未掌握"
        case mastered = "已掌握"
    }
    
    var filteredWrongAnswers: [WrongAnswer] {
        switch selectedFilter {
        case .all:
            return allWrongAnswers
        case .notMastered:
            return allWrongAnswers.filter { !$0.isMastered }
        case .mastered:
            return allWrongAnswers.filter { $0.isMastered }
        }
    }
    
    var groupedWrongAnswers: [QuestionType: [WrongAnswer]] {
        Dictionary(grouping: filteredWrongAnswers) { $0.questionType }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 筛选器
                filterSection
                
                if !filteredWrongAnswers.isEmpty {
                    // 错题列表
                    mistakesList
                } else {
                    emptyStateView
                }
            }
            .navigationTitle("错题本")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("清空已掌握", action: clearMasteredMistakes)
                        Button("清空全部", role: .destructive, action: { showingClearAlert = true })
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .alert("清空错题本", isPresented: $showingClearAlert) {
                Button("取消", role: .cancel) { }
                Button("清空", role: .destructive, action: clearAllMistakes)
            } message: {
                Text("此操作将删除所有错题记录，无法恢复。")
            }
        }
        .sheet(item: $selectedWrongAnswer) { wrongAnswer in
            RetryQuestionView(wrongAnswer: wrongAnswer)
        }
    }
    
    private var filterSection: some View {
        VStack(spacing: 12) {
            // 统计信息
            HStack {
                Spacer()
                
                VStack {
                    Text("\(allWrongAnswers.filter { !$0.isMastered }.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    Text("未掌握")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack {
                    Text("\(allWrongAnswers.filter { $0.isMastered }.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("已掌握")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
            
            // 过滤按钮
            HStack(spacing: 0) {
                ForEach(MistakeFilter.allCases, id: \.self) { filter in
                    Button(action: {
                        selectedFilter = filter
                    }) {
                        Text(filter.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(selectedFilter == filter ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedFilter == filter ? Color.blue : Color.clear)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6))
            )
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private var mistakesList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(QuestionType.allCases, id: \.self) { type in
                    if let mistakes = groupedWrongAnswers[type], !mistakes.isEmpty {
                        MistakeTypeSection(
                            questionType: type,
                            mistakes: mistakes,
                            onRetry: { wrongAnswer in
                                selectedWrongAnswer = wrongAnswer
                            },
                            onMarkMastered: markAsMastered
                        )
                    }
                }
            }
            .padding()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: selectedFilter == .all ? "book.fill" : 
                  selectedFilter == .mastered ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(getEmptyMessage())
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text(getEmptySubMessage())
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private func getEmptyMessage() -> String {
        switch selectedFilter {
        case .all:
            return "暂无错题"
        case .notMastered:
            return "暂无未掌握的错题"
        case .mastered:
            return "暂无已掌握的错题"
        }
    }
    
    private func getEmptySubMessage() -> String {
        switch selectedFilter {
        case .all:
            return "开始练习后，做错的题目会记录在这里"
        case .notMastered:
            return "继续练习，攻克难题！"
        case .mastered:
            return "掌握错题后会显示在这里"
        }
    }
    
    private func markAsMastered(_ wrongAnswer: WrongAnswer) {
        wrongAnswer.markAsMastered()
        try? modelContext.save()
    }
    
    private func clearMasteredMistakes() {
        let masteredAnswers = allWrongAnswers.filter { $0.isMastered }
        for answer in masteredAnswers {
            modelContext.delete(answer)
        }
        try? modelContext.save()
    }
    
    private func clearAllMistakes() {
        for answer in allWrongAnswers {
            modelContext.delete(answer)
        }
        try? modelContext.save()
    }
}

struct MistakeTypeSection: View {
    let questionType: QuestionType
    let mistakes: [WrongAnswer]
    let onRetry: (WrongAnswer) -> Void
    let onMarkMastered: (WrongAnswer) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 题型标题
            HStack {
                HStack {
                    Image(systemName: questionType.icon)
                        .foregroundColor(colorForType(questionType.color))
                    
                    Text(questionType.rawValue)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                Text("\(mistakes.count)题")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // 错题列表
            LazyVStack(spacing: 8) {
                ForEach(mistakes, id: \.id) { mistake in
                    MistakeRow(
                        mistake: mistake,
                        onRetry: { onRetry(mistake) },
                        onMarkMastered: { onMarkMastered(mistake) }
                    )
                }
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
    
    private func colorForType(_ colorName: String) -> Color {
        switch colorName {
        case "blue": return .blue
        case "red": return .red
        case "green": return .green
        case "orange": return .orange
        default: return .blue
        }
    }
}

struct MistakeRow: View {
    let mistake: WrongAnswer
    let onRetry: () -> Void
    let onMarkMastered: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            // 题目和答案
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(mistake.questionExpression)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text("你的答案: \(mistake.userAnswer)")
                            .foregroundColor(.red)
                        
                        Spacer()
                        
                        Text("正确答案: \(mistake.correctAnswer)")
                            .foregroundColor(.green)
                    }
                    .font(.caption)
                }
                
                Spacer()
            }
            
            // 错误信息和操作按钮
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("错误 \(mistake.wrongCount) 次")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(formatDate(mistake.lastWrongAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    if !mistake.isMastered {
                        Button("已掌握") {
                            onMarkMastered()
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.green)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                    
                    Button("重做") {
                        onRetry()
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(12)
        .background(mistake.isMastered ? Color.green.opacity(0.05) : Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日"
        return formatter.string(from: date)
    }
}

struct RetryQuestionView: View {
    @Environment(\.dismiss) private var dismiss
    let wrongAnswer: WrongAnswer
    
    @State private var userAnswer = ""
    @State private var showResult = false
    @State private var isCorrect = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                // 题目
                VStack(spacing: 16) {
                    Text(wrongAnswer.questionExpression)
                        .font(.system(size: 36, weight: .medium, design: .monospaced))
                        .foregroundColor(.primary)
                    
                    Text("=")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(.secondary)
                }
                
                // 答案输入
                TextField("答案", text: $userAnswer)
                    .font(.system(size: 32, weight: .medium, design: .monospaced))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(.center)
                    .keyboardType(.decimalPad)
                
                if showResult {
                    VStack(spacing: 8) {
                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(isCorrect ? .green : .red)
                        
                        Text(isCorrect ? "正确！" : "再试试看")
                            .font(.headline)
                            .foregroundColor(isCorrect ? .green : .red)
                        
                        if !isCorrect {
                            Text("正确答案: \(wrongAnswer.correctAnswer)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill((isCorrect ? Color.green : Color.red).opacity(0.1))
                    )
                }
                
                Spacer()
                
                // 提交按钮
                Button(action: checkAnswer) {
                    Text("提交")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(userAnswer.isEmpty ? Color(.systemGray4) : Color.blue)
                        )
                }
                .disabled(userAnswer.isEmpty || showResult)
                .padding(.bottom)
            }
            .padding()
            .navigationTitle("重做练习")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func checkAnswer() {
        isCorrect = userAnswer.trimmingCharacters(in: .whitespacesAndNewlines) == wrongAnswer.correctAnswer
        showResult = true
        
        if isCorrect {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
        }
    }
}

#Preview {
    MistakesView()
        .modelContainer(for: [WrongAnswer.self], inMemory: true)
}
