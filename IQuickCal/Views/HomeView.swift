//
//  HomeView.swift
//  IQuickCal
//
//  Created by sunyuan on 2025/6/4.
//

import SwiftUI
import SwiftData

// 导航目标结构
struct PracticeDestination: Hashable {
    let questionType: QuestionType
    let questionCount: Int
}

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userPreferences: [UserPreferences]
    @State private var navigationPath = NavigationPath()
    
    var questionsPerSet: Int {
        userPreferences.first?.questionsPerSet ?? 20
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(spacing: 20) {
                    // 快速开始卡片
                    quickStartCard
                    
                    // 题型选择
                    questionTypesSection
                }
                .padding()        }
        .navigationTitle("速算练习")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: PracticeDestination.self) { destination in
            PracticeView(
                questionType: destination.questionType,
                questionCount: destination.questionCount,
                navigationPath: $navigationPath
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ReturnToHome"))) { _ in
            // 收到返回首页的通知，清空导航路径
            navigationPath = NavigationPath()
        }
        }
        .onAppear {
            initializeUserPreferences()
        }
    }
    
    private var quickStartCard: some View {
        Button(action: {
            let mixedType = QuestionType.mixed
            navigationPath.append(PracticeDestination(questionType: mixedType, questionCount: questionsPerSet))
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("快速开始")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("混合练习 · \(questionsPerSet)题 · \(QuestionType.mixed.formattedTime(for: questionsPerSet))")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "play.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }
            .padding(20)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var questionTypesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("题型练习")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                ForEach(QuestionType.allCases.filter { $0 != .mixed }, id: \.self) { questionType in
                    QuestionTypeCard(
                        questionType: questionType,
                        questionsPerSet: questionsPerSet,
                        navigationPath: $navigationPath
                    )
                }
            }
        }
    }
    
    private func initializeUserPreferences() {
        if userPreferences.isEmpty {
            let preferences = UserPreferences()
            modelContext.insert(preferences)
            try? modelContext.save()
        }
    }
}

struct QuestionTypeCard: View {
    let questionType: QuestionType
    let questionsPerSet: Int
    @Binding var navigationPath: NavigationPath
    @State private var showingDetails = false
    
    var body: some View {
        Button(action: {
            navigationPath.append(PracticeDestination(questionType: questionType, questionCount: questionsPerSet))
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // 图标和标题行
                HStack {
                    Image(systemName: questionType.icon)
                        .font(.title2)
                        .foregroundColor(colorForType(questionType.color))
                        .frame(width: 32, height: 32)
                        .background(colorForType(questionType.color).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    
                    Spacer()
                    
                    // 题量标识
                    Text("\(questionsPerSet)题")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(colorForType(questionType.color))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(colorForType(questionType.color).opacity(0.1))
                        .clipShape(Capsule())
                }
                
                // 标题
                Text(questionType.rawValue)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                // 示例
                Text(questionType.example)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                // 练习信息
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "clock")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(questionType.formattedTime(for: questionsPerSet))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Image(systemName: "brain.head.profile")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(questionType.practiceMethodDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    // 详细说明区域 - 固定高度
                    detailedDescriptionView
                }
                
                Spacer(minLength: 0) // 确保卡片底部对齐
            }
            .frame(maxWidth: .infinity, minHeight: 160, alignment: .leading) // 设置固定最小高度
            .padding(16)
            .background(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(ScaleButtonStyle())
        .sheet(isPresented: $showingDetails) {
            QuestionTypeDetailView(questionType: questionType)
        }
    }
    
    @ViewBuilder
    private var detailedDescriptionView: some View {
        if let detailedDescription = questionType.detailedDescription {
            HStack(alignment: .top, spacing: 4) {
                Text(detailedDescription)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                // 详情按钮
                Button(action: {
                    showingDetails = true
                }) {
                    Image(systemName: "info.circle")
                        .font(.caption2)
                        .foregroundColor(colorForType(questionType.color))
                        .padding(4) // 增加点击区域
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle()) // 确保整个区域可点击
                .allowsHitTesting(true) // 确保按钮可以接收点击事件
            }
            .frame(height: 16) // 固定详细说明区域高度
        } else {
            // 为没有详细说明的卡片保留相同的空间
            Spacer()
                .frame(height: 16)
        }
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

// 题型详细信息视图
struct QuestionTypeDetailView: View {
    let questionType: QuestionType
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 头部信息
                    HStack {
                        Image(systemName: questionType.icon)
                            .font(.largeTitle)
                            .foregroundColor(colorForType(questionType.color))
                            .frame(width: 60, height: 60)
                            .background(colorForType(questionType.color).opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(questionType.rawValue)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(questionType.example)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    Divider()
                    
                    // 练习参数
                    VStack(alignment: .leading, spacing: 16) {
                        Text("练习参数")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            DetailRow(
                                icon: "number.circle",
                                title: "推荐题量",
                                value: "\(questionType.recommendedQuestionCount)题",
                                color: colorForType(questionType.color)
                            )
                            
                            DetailRow(
                                icon: "clock",
                                title: "推荐时间",
                                value: questionType.formattedTime,
                                color: colorForType(questionType.color)
                            )
                            
                            DetailRow(
                                icon: "brain.head.profile",
                                title: "练习方式",
                                value: questionType.practiceMethodDescription,
                                color: colorForType(questionType.color)
                            )
                        }
                    }
                    
                    // 详细说明
                    if let detailedDescription = questionType.detailedDescription {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("详细说明")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text(detailedDescription)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .lineSpacing(4)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("题型详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
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

// 详情行组件
struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(color)
                .frame(width: 24, height: 24)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}



#Preview {
    HomeView()
        .modelContainer(for: [UserPreferences.self], inMemory: true)
}
