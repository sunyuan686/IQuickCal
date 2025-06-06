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
            navigationPath.append(PracticeDestination(questionType: .mixed, questionCount: questionsPerSet))
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("快速开始")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("混合练习 · \(questionsPerSet)题")
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
    
    var body: some View {
        Button(action: {
            navigationPath.append(PracticeDestination(questionType: questionType, questionCount: questionsPerSet))
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // 图标
                Image(systemName: questionType.icon)
                    .font(.title2)
                    .foregroundColor(colorForType(questionType.color))
                    .frame(width: 40, height: 40)
                    .background(colorForType(questionType.color).opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                // 标题
                Text(questionType.rawValue)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                // 示例
                Text(questionType.example)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(ScaleButtonStyle())
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



#Preview {
    HomeView()
        .modelContainer(for: [UserPreferences.self], inMemory: true)
}
