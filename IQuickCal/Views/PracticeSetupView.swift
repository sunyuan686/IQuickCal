//
//  PracticeSetupView.swift
//  IQuickCal
//
//  Created by GitHub Copilot on 2025/6/4.
//

import SwiftUI
import SwiftData

struct PracticeSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var userPreferences: [UserPreferences]
    
    let questionType: QuestionType
    @Binding var navigationPath: NavigationPath
    
    @State private var useGlobalSetting = true
    @State private var customQuestionCount: Int
    @State private var showingCountPicker = false
    
    private var globalQuestionCount: Int {
        userPreferences.first?.questionsPerSet ?? 20
    }
    
    private var selectedQuestionCount: Int {
        useGlobalSetting ? globalQuestionCount : customQuestionCount
    }
    
    init(questionType: QuestionType, navigationPath: Binding<NavigationPath>) {
        self.questionType = questionType
        self._navigationPath = navigationPath
        self._customQuestionCount = State(initialValue: questionType.recommendedQuestionCount)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 题型信息卡片
                    questionTypeCard
                    
                    // 题目数量设置
                    questionCountSection
                    
                    // 练习参数预览
                    practicePreviewSection
                    
                    Spacer(minLength: 40)
                    
                    // 开始按钮
                    startButton
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("练习设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingCountPicker) {
            questionCountPickerSheet
        }
    }
    
    private var questionTypeCard: some View {
        VStack(spacing: 16) {
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
                    
                    if let description = questionType.detailedDescription {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var questionCountSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("题目数量")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                // 使用全局设置选项
                Button(action: {
                    useGlobalSetting = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: useGlobalSetting ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundColor(useGlobalSetting ? .blue : .gray)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("使用全局设置")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text("\(globalQuestionCount)题 · 可在设置中修改")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(useGlobalSetting ? Color.blue.opacity(0.05) : Color(.systemGray6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(useGlobalSetting ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
                
                // 自定义数量选项
                Button(action: {
                    useGlobalSetting = false
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: !useGlobalSetting ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundColor(!useGlobalSetting ? .blue : .gray)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("自定义数量")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text("\(customQuestionCount)题 · 推荐\(questionType.recommendedQuestionCount)题")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if !useGlobalSetting {
                            Button(action: {
                                showingCountPicker = true
                            }) {
                                Text("调整")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(!useGlobalSetting ? Color.blue.opacity(0.05) : Color(.systemGray6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(!useGlobalSetting ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var practicePreviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("练习预览")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                PreviewCard(
                    icon: "list.number",
                    title: "题目数量",
                    value: "\(selectedQuestionCount)题",
                    color: .blue
                )
                
                PreviewCard(
                    icon: "clock",
                    title: "建议时间",
                    value: formatEstimatedTime(),
                    color: .orange
                )
                
                PreviewCard(
                    icon: "brain.head.profile",
                    title: "练习方式",
                    value: questionType.practiceMethodDescription,
                    color: .purple
                )
                
                PreviewCard(
                    icon: "target",
                    title: "难度",
                    value: getDifficultyDescription(),
                    color: colorForType(questionType.color)
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var startButton: some View {
        Button(action: {
            startPractice()
        }) {
            HStack(spacing: 10) {
                Image(systemName: "play.fill")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text("开始练习")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(height: 56)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [colorForType(questionType.color), colorForType(questionType.color).opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: colorForType(questionType.color).opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var questionCountPickerSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("选择题目数量")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top)
                
                QuestionCountPicker(
                    selectedCount: $customQuestionCount,
                    showDefaultOption: true,
                    defaultCount: questionType.recommendedQuestionCount
                )
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                .padding()
                
                Spacer()
            }
            .navigationTitle("自定义数量")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        showingCountPicker = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("确定") {
                        showingCountPicker = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func startPractice() {
        dismiss()
        navigationPath.append(PracticeDestination(questionType: questionType, questionCount: selectedQuestionCount))
    }
    
    private func formatEstimatedTime() -> String {
        let totalMinutes = questionType.recommendedTimeInMinutes * Double(selectedQuestionCount) / Double(questionType.recommendedQuestionCount)
        let minutes = Int(totalMinutes)
        let seconds = Int((totalMinutes - Double(minutes)) * 60)
        
        if minutes > 0 {
            return seconds > 0 ? "\(minutes)分\(seconds)秒" : "\(minutes)分钟"
        } else {
            return "\(Int(totalMinutes * 60))秒"
        }
    }
    
    private func getDifficultyDescription() -> String {
        let ratio = Double(selectedQuestionCount) / Double(questionType.recommendedQuestionCount)
        
        switch ratio {
        case 0..<0.5:
            return "轻松"
        case 0.5..<0.8:
            return "简单"
        case 0.8..<1.2:
            return "标准"
        case 1.2..<1.5:
            return "挑战"
        default:
            return "困难"
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

struct PreviewCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .lineLimit(1)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    @State var navigationPath = NavigationPath()
    return PracticeSetupView(questionType: .twoDigitAddition, navigationPath: $navigationPath)
        .modelContainer(for: [UserPreferences.self], inMemory: true)
}
