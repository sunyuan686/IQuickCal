//
//  ResultView.swift
//  IQuickCal
//
//  Created by sunyuan on 2025/6/4.
//

import SwiftUI
import SwiftData

struct ResultView: View {
    @Environment(\.dismiss) private var dismiss
    
    let session: PracticeSession
    @Binding var navigationPath: NavigationPath
    
    @State private var showingAllWrongAnswers = false
    @State private var shouldNavigateToNewPractice = false
    
    init(session: PracticeSession, navigationPath: Binding<NavigationPath>) {
        self.session = session
        self._navigationPath = navigationPath
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 顶部成绩卡片
                resultCard
                
                // 统计数据
                statisticsSection
                
                // 错题快速查看
                if !wrongAnswers.isEmpty {
                    wrongAnswersSection
                }
                
                // 操作按钮
                actionButtons
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("练习结果")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    returnToHome()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "house.fill")
                            .font(.caption)
                        Text("完成")
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.1))
                    )
                }
            }
        }
        .sheet(isPresented: $showingAllWrongAnswers) {
            AllWrongAnswersView(wrongAnswers: wrongAnswers)
        }
        .navigationDestination(isPresented: $shouldNavigateToNewPractice) {
            PracticeView(questionType: session.type, questionCount: session.totalQuestions, navigationPath: $navigationPath)
        }
    }
    
    private var resultCard: some View {
        VStack(spacing: 16) {
            // 正确率圆环 - 重新设计更美观
            ZStack {
                // 外层阴影圆环
                Circle()
                    .stroke(Color.gray.opacity(0.08), lineWidth: 3)
                    .frame(width: 120, height: 120)
                
                // 背景圆环
                Circle()
                    .stroke(Color.gray.opacity(0.12), lineWidth: 8)
                    .frame(width: 110, height: 110)
                
                // 进度圆环 - 多层渐变效果
                Circle()
                    .trim(from: 0, to: session.correctRate)
                    .stroke(
                        AngularGradient(
                            colors: getProgressColors(),
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270 * session.correctRate - 90)
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 110, height: 110)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 1.5, dampingFraction: 0.8), value: session.correctRate)
                
                // 圆环端点的小圆点
                if session.correctRate > 0 {
                    Circle()
                        .fill(getProgressColors().last ?? .blue)
                        .frame(width: 12, height: 12)
                        .offset(y: -55)
                        .rotationEffect(.degrees(360 * session.correctRate - 90))
                        .animation(.spring(response: 1.5, dampingFraction: 0.8).delay(0.3), value: session.correctRate)
                        .shadow(color: getProgressColors().last?.opacity(0.5) ?? .blue.opacity(0.5), radius: 3, x: 0, y: 1)
                }
                
                // 中心内容
                VStack(spacing: 2) {
                    Text("\(Int(session.correctRate * 100))")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: getProgressColors(),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("%")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .offset(y: -2)
                    
                    Text("正确率")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .offset(y: -2)
                }
                .scaleEffect(session.correctRate > 0 ? 1 : 0.8)
                .animation(.spring(response: 1.2, dampingFraction: 0.8).delay(0.5), value: session.correctRate)
            }
            
            // 完成提示 - 更紧凑
            Text(getResultMessage())
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineSpacing(1)
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color(.systemBackground), location: 0),
                            .init(color: getProgressColors().first?.opacity(0.02) ?? .blue.opacity(0.02), location: 1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            LinearGradient(
                                colors: [getProgressColors().first?.opacity(0.1) ?? .blue.opacity(0.1), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
    }
    
    // 根据正确率返回不同的渐变色
    private func getProgressColors() -> [Color] {
        let rate = session.correctRate
        switch rate {
        case 0.9...1.0:
            return [.green, .mint, .cyan]
        case 0.8..<0.9:
            return [.blue, .cyan, .teal]
        case 0.7..<0.8:
            return [.orange, .yellow, .mint]
        default:
            return [.red, .orange, .yellow]
        }
    }
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("详细统计")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatCard(
                    title: "总题数",
                    value: "\(session.totalQuestions)",
                    icon: "list.number",
                    color: .blue
                )
                
                StatCard(
                    title: "正确题数",
                    value: "\(session.correctAnswers)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StatCard(
                    title: "错误题数",
                    value: "\(session.wrongAnswers)",
                    icon: "xmark.circle.fill",
                    color: .red
                )
                
                StatCard(
                    title: "总用时",
                    value: formatTime(session.totalTime),
                    icon: "stopwatch.fill",
                    color: .purple
                )
                
                StatCard(
                    title: "平均用时",
                    value: formatTime(session.averageTime),
                    icon: "clock.fill",
                    color: .orange
                )
                
                StatCard(
                    title: "完成度",
                    value: session.isCompleted ? "100%" : "进行中",
                    icon: "chart.pie.fill",
                    color: .cyan
                )
            }
        }
        .padding(16)
        .background(
            Color(.systemBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
        )
    }
    
    private var wrongAnswers: [Answer] {
        session.answers.filter { !$0.isCorrect }
    }
    
    private var wrongAnswersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("错题回顾")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(wrongAnswers.count)题")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            LazyVStack(spacing: 8) {
                ForEach(wrongAnswers.prefix(3), id: \.id) { answer in
                    WrongAnswerRow(answer: answer)
                }
                
                if wrongAnswers.count > 3 {
                    Button("查看全部错题") {
                        showingAllWrongAnswers = true
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.top, 6)
                }
            }
        }
        .padding(16)
        .background(
            Color(.systemBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
        )
    }
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            // 再练一组按钮 - 主要操作按钮，更加突出
            Button(action: {
                startNewPracticeSession()
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("再练一组")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(ScaleButtonStyle())
            
            // 提示文本区域
            VStack(spacing: 4) {
                Text("点击左上角\"完成\"按钮返回首页")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Text("或者继续练习提高你的速算能力！")
                    .font(.caption2)
                    .foregroundColor(.secondary.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private func getResultMessage() -> String {
        let rate = session.correctRate
        switch rate {
        case 0.9...1.0:
            return "太棒了！\n速算高手！"
        case 0.8..<0.9:
            return "很不错！\n继续加油！"
        case 0.7..<0.8:
            return "还不错！\n再接再厉！"
        default:
            return "继续练习！\n熟能生巧！"
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let seconds = Int(timeInterval)
        if seconds < 60 {
            return "\(seconds)秒"
        } else {
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            return "\(minutes)分\(remainingSeconds)秒"
        }
    }
    
    // 开始新的练习会话
    private func startNewPracticeSession() {
        // 确保重置其他状态
        showingAllWrongAnswers = false
        
        // 延迟一下，确保状态正确设置
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            shouldNavigateToNewPractice = true
        }
    }
    
    // 返回首页
    private func returnToHome() {
        // 重置导航状态，防止意外触发新练习
        shouldNavigateToNewPractice = false
        
        // 发送通知给父视图（这是备用方案）
        NotificationCenter.default.post(name: NSNotification.Name("ReturnToHome"), object: nil)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(color)
                .frame(width: 20, height: 20)
            
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(color.opacity(0.15), lineWidth: 1)
                )
        )
        .shadow(color: color.opacity(0.08), radius: 2, x: 0, y: 1)
    }
}

struct WrongAnswerRow: View {
    let answer: Answer
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(answer.questionExpression)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                HStack(spacing: 10) {
                    Label("\(answer.userAnswer)", systemImage: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                    
                    Label("\(answer.correctAnswer)", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.red.opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - AllWrongAnswersView
struct AllWrongAnswersView: View {
    @Environment(\.dismiss) private var dismiss
    let wrongAnswers: [Answer]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(wrongAnswers, id: \.id) { answer in
                        WrongAnswerDetailRow(answer: answer)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("错题详情")
            .navigationBarTitleDisplayMode(.large)
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

// MARK: - WrongAnswerDetailRow
struct WrongAnswerDetailRow: View {
    let answer: Answer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 题目显示
            Text(answer.questionExpression)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            // 答案对比
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("你的答案")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                        Text("\(answer.userAnswer)")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("正确答案")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("\(answer.correctAnswer)")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                }
            }
            
            // 用时显示（如果有的话）
            if answer.timeSpent > 0 {
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.orange)
                    Text("用时: \(String(format: "%.1f", answer.timeSpent))秒")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(20)
        .background(
            Color(.systemBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var navigationPath = NavigationPath()
        
        var body: some View {
            let session = PracticeSession(type: .twoDigitAddition, totalQuestions: 10)
            session.correctAnswers = 8
            session.totalTime = 120
            session.averageTime = 12
            session.endTime = Date()
            session.isCompleted = true
            
            return NavigationView {
                ResultView(session: session, navigationPath: $navigationPath)
            }
        }
    }
    
    return PreviewWrapper()
}
