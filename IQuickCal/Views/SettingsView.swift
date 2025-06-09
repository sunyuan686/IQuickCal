//
//  SettingsView.swift
//  IQuickCal
//
//  Created by sunyuan on 2025/6/4.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userPreferences: [UserPreferences]
    
    @State private var questionsPerSet: Double = 20
    @State private var soundEnabled = true
    @State private var hapticFeedbackEnabled = true
    @State private var autoSubmitEnabled = true
    @State private var showingResetAlert = false
    @State private var showingAbout = false
    
    private var preferences: UserPreferences? {
        userPreferences.first
    }
    
    var body: some View {
        NavigationView {
            List {
                // 练习设置
                practiceSettingsSection
                
                // 交互设置
                interactionSettingsSection
                
                // 数据管理
                dataManagementSection
                
                // 关于应用
                aboutSection
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadSettings()
            }
            .onChange(of: questionsPerSet) { _, newValue in
                saveSettings()
            }
            .onChange(of: soundEnabled) { _, newValue in
                saveSettings()
            }
            .onChange(of: hapticFeedbackEnabled) { _, newValue in
                saveSettings()
            }
            .onChange(of: autoSubmitEnabled) { _, newValue in
                saveSettings()
            }
        }
        .alert("重置所有数据", isPresented: $showingResetAlert) {
            Button("取消", role: .cancel) { }
            Button("重置", role: .destructive, action: resetAllData)
        } message: {
            Text("此操作将删除所有练习记录、错题本和设置，无法恢复。")
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }
    
    private var practiceSettingsSection: some View {
        Section("练习设置") {
            HStack {
                Text("每组题目数量")
                    .font(.headline)
                
                Spacer()
                
                // 紧凑的题量选择器
                CompactQuestionCountPicker(selectedCount: Binding(
                    get: { Int(questionsPerSet) },
                    set: { questionsPerSet = Double($0) }
                ))
            }
            .padding(.vertical, 4)
        }
    }
    
    private var interactionSettingsSection: some View {
        Section("交互设置") {
            SettingToggleRow(
                title: "音效反馈",
                description: "答题时播放提示音",
                icon: "speaker.wave.2.fill",
                isOn: $soundEnabled
            )
            
            SettingToggleRow(
                title: "触觉反馈",
                description: "答题时震动反馈",
                icon: "iphone.radiowaves.left.and.right",
                isOn: $hapticFeedbackEnabled
            )
            
            SettingToggleRow(
                title: "自动提交",
                description: "输入答案后自动进入下一题",
                icon: "forward.fill",
                isOn: $autoSubmitEnabled
            )
        }
    }
    
    private var dataManagementSection: some View {
        Section("数据管理") {
            Button(action: exportData) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("导出数据")
                            .foregroundColor(.primary)
                        Text("导出练习记录和错题本")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
            
            Button(action: { showingResetAlert = true }) {
                HStack {
                    Image(systemName: "trash.fill")
                        .foregroundColor(.red)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("重置所有数据")
                            .foregroundColor(.red)
                        Text("删除所有记录和设置")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
        }
    }
    
    private var aboutSection: some View {
        Section("关于") {
            Button(action: { showingAbout = true }) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    Text("关于应用")
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.orange)
                    .frame(width: 24)
                
                Text("给我们评分")
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
    }
    
    private func loadSettings() {
        if let prefs = preferences {
            questionsPerSet = Double(prefs.questionsPerSet)
            soundEnabled = prefs.soundEnabled
            hapticFeedbackEnabled = prefs.hapticFeedbackEnabled
            autoSubmitEnabled = prefs.autoSubmitEnabled
        } else {
            // 创建默认设置
            let newPrefs = UserPreferences()
            modelContext.insert(newPrefs)
            try? modelContext.save()
        }
    }
    
    private func saveSettings() {
        if let prefs = preferences {
            prefs.updateSettings(
                questionsPerSet: Int(questionsPerSet),
                soundEnabled: soundEnabled,
                hapticFeedbackEnabled: hapticFeedbackEnabled,
                autoSubmitEnabled: autoSubmitEnabled
            )
            try? modelContext.save()
        }
    }
    
    private func exportData() {
        // TODO: 实现数据导出功能
        print("导出数据功能待实现")
    }
    
    private func resetAllData() {
        // 删除所有数据
        do {
            // 删除练习会话
            let sessions = try modelContext.fetch(FetchDescriptor<PracticeSession>())
            for session in sessions {
                modelContext.delete(session)
            }
            
            // 删除错题记录
            let wrongAnswers = try modelContext.fetch(FetchDescriptor<WrongAnswer>())
            for wrongAnswer in wrongAnswers {
                modelContext.delete(wrongAnswer)
            }
            
            // 重置用户设置
            if let prefs = preferences {
                modelContext.delete(prefs)
            }
            
            try modelContext.save()
            
            // 重新创建默认设置
            let newPrefs = UserPreferences()
            modelContext.insert(newPrefs)
            try modelContext.save()
            
            // 重新加载设置
            loadSettings()
            
        } catch {
            print("重置数据失败: \(error)")
        }
    }
}

struct SettingToggleRow: View {
    let title: String
    let description: String
    let icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 应用图标和名称
                    VStack(spacing: 16) {
                        Image(systemName: "calculator.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        VStack(spacing: 4) {
                            Text("公考速算练习")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("版本 1.0.0")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // 应用介绍
                    VStack(alignment: .leading, spacing: 16) {
                        Text("关于应用")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("公考速算练习是一款专为公务员考试设计的计算能力训练应用。通过科学的练习方法和详细的数据分析，帮助考生快速提升速算能力。")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineSpacing(2)
                    }
                    
                    // 功能特色
                    VStack(alignment: .leading, spacing: 16) {
                        Text("功能特色")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        LazyVStack(alignment: .leading, spacing: 12) {
                            FeatureRow(icon: "plus.circle.fill", title: "8种题型", description: "涵盖加减乘除各类计算")
                            FeatureRow(icon: "chart.bar.fill", title: "详细统计", description: "准确率、用时等多维度分析")
                            FeatureRow(icon: "book.fill", title: "错题本", description: "智能记录，针对性练习")
                            FeatureRow(icon: "clock.fill", title: "历史记录", description: "追踪进步轨迹")
                        }
                    }
                    
                    // 联系我们
                    VStack(alignment: .leading, spacing: 16) {
                        Text("联系我们")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("邮箱：support@iquickcal.com")
                                .font(.body)
                                .foregroundColor(.blue)
                            
                            Text("如有问题或建议，欢迎联系我们")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("关于")
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
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [UserPreferences.self], inMemory: true)
}
