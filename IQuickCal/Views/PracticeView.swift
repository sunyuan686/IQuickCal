//
//  PracticeView.swift
//  IQuickCal
//
//  Created by sunyuan on 2025/6/4.
//

import SwiftUI
import SwiftData

struct PracticeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let questionType: QuestionType
    let questionCount: Int
    @Binding var navigationPath: NavigationPath
    
    @State private var practiceManager: PracticeManager?
    @State private var currentAnswer = ""
    @State private var showingResult = false
    @State private var showCorrectAnimation = false
    @State private var showWrongAnimation = false
    @State private var navigateToResult = false
    
    // 计时相关状态
    @State private var sessionElapsedTime: TimeInterval = 0
    @State private var questionElapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 0) {
            if let manager = practiceManager, !manager.isCompleted {
                // 顶部进度区域
                progressSection
                
                // 题目显示区域 - 灵活高度，占据主要空间
                questionSection
                    .frame(minHeight: 200)
                    .layoutPriority(1)
                
                // 答案输入区域 - 固定合理高度
                answerSection
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                
                // 数字键盘 - 紧凑布局
                numberPad
                    .background(Color(.systemGray6))
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            setupPracticeManager()
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ReturnToHome"))) { _ in
            // 收到返回首页的通知，清空导航路径返回到根视图
            navigationPath = NavigationPath()
        }
        .navigationDestination(isPresented: $navigateToResult) {
            if let session = practiceManager?.currentSession {
                ResultView(session: session, navigationPath: $navigationPath)
            }
        }
    }
    
    @ViewBuilder
    private var progressSection: some View {
        if let manager = practiceManager {
            VStack(spacing: 0) {
                // 导航栏样式的顶部区域
                HStack {
                    // 退出按钮
                    Button("退出") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                    .font(.system(size: 17))
                    
                    Spacer()
                    
                    // 中央标题和进度
                    VStack(spacing: 2) {
                        Text(questionType.rawValue)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primary)
                        Text("第 \(manager.currentQuestionIndex + 1) 题 / 共 \(manager.questions.count) 题")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // 暂停按钮
                    Button(action: {
                        manager.togglePause()
                    }) {
                        Image(systemName: manager.isPaused ? "play.fill" : "pause.fill")
                            .font(.system(size: 17))
                            .foregroundColor(manager.isPaused ? .green : .gray)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                
                // 进度条
                ProgressView(value: manager.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .frame(height: 4)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                    .background(Color(.systemBackground))
                
                // 统计信息行
                HStack {
                    // 总用时
                    VStack(spacing: 2) {
                        Text(formatTime(sessionElapsedTime))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.blue)
                        Text("总用时")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // 答对数
                    VStack(spacing: 2) {
                        Text("\(manager.correctCount)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.green)
                        Text("答对")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // 答错数
                    VStack(spacing: 2) {
                        Text("\(manager.wrongCount)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.red)
                        Text("答错")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // 本题用时
                    VStack(spacing: 2) {
                        Text(formatTime(questionElapsedTime))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                        Text("本题用时")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                
                // 分隔线
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(Color(.separator))
            }
        }
    }
    
    @ViewBuilder
    private var questionSection: some View {
        if let manager = practiceManager, let question = manager.currentQuestion {
            // 题目显示区域 - 居中布局，充分利用空间
            VStack {
                Spacer(minLength: 40)
                
                VStack(spacing: 16) {
                    // 题目表达式
                    Text(question.expression)
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    // 等号
                    Text("=")
                        .font(.system(size: 36, weight: .light))
                        .foregroundColor(.secondary)
                    
                    // 答案输入显示
                    Text(currentAnswer.isEmpty ? "?" : currentAnswer)
                        .font(.system(size: 36, weight: .semibold, design: .monospaced))
                        .foregroundColor(currentAnswer.isEmpty ? .secondary : .primary)
                        .frame(minWidth: 180)
                        .padding(.bottom, 2)
                        .overlay(
                            Rectangle()
                                .frame(height: 2)
                                .foregroundColor(.blue),
                            alignment: .bottom
                        )
                }
                
                Spacer(minLength: 40)
            }
            .frame(maxWidth: .infinity)
            .background(
                Color(.systemBackground)
                    .overlay(
                        Rectangle()
                            .fill(showCorrectAnimation ? Color.green.opacity(0.1) : 
                                  showWrongAnimation ? Color.red.opacity(0.1) : Color.clear)
                    )
            )
            .animation(.easeInOut(duration: 0.3), value: showCorrectAnimation)
            .animation(.easeInOut(duration: 0.3), value: showWrongAnimation)
        }
    }
    
    @ViewBuilder
    private var answerSection: some View {
        if let manager = practiceManager, let question = manager.currentQuestion {
            // 只显示选择题选项，输入框已移到题目区域
            if question.isMultipleChoice, let options = question.options {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                    ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                        Button(action: {
                            selectOption(option)
                        }) {
                            Text(option)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(currentAnswer == option ? .white : .primary)
                                .frame(height: 44)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(currentAnswer == option ? Color.blue : Color(.systemGray6))
                                )
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
                .padding(.bottom, 12)
            }
        }
    }
    
    @ViewBuilder
    private var numberPad: some View {
        if let manager = practiceManager, let question = manager.currentQuestion, !question.isMultipleChoice {
            VStack(spacing: 12) {
                // 数字按钮 1-9
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                    ForEach(1...9, id: \.self) { number in
                        NumberButton(number: "\(number)") {
                            appendToAnswer("\(number)")
                        }
                    }
                }
                
                // 底部行：退格、0、确认
                HStack(spacing: 12) {
                    Button(action: deleteLastCharacter) {
                        Image(systemName: "delete.left.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray5))
                            )
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    NumberButton(number: "0") {
                        appendToAnswer("0")
                    }
                    
                    Button(action: submitAnswer) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(currentAnswer.isEmpty ? Color(.systemGray4) : Color(.systemBlue))
                            )
                    }
                    .disabled(currentAnswer.isEmpty)
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
    }
    
    private func setupPracticeManager() {
        practiceManager = PracticeManager(modelContext: modelContext)
        practiceManager?.startPractice(type: questionType, questionCount: questionCount)
    }
    
    // 开始计时器
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            updateElapsedTime()
        }
    }
    
    // 停止计时器
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // 更新经过的时间
    private func updateElapsedTime() {
        guard let manager = practiceManager,
              !manager.isCompleted else { return }
        
        // 使用管理器中的计算属性来获取正确的时间
        sessionElapsedTime = manager.currentSessionElapsedTime
        questionElapsedTime = manager.currentQuestionElapsedTime
    }
    
    // 格式化时间显示
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        // 确保时间不为负数
        let safeTimeInterval = max(0, timeInterval)
        let minutes = Int(safeTimeInterval) / 60
        let seconds = Int(safeTimeInterval) % 60
        let deciseconds = Int((safeTimeInterval * 10).truncatingRemainder(dividingBy: 10))
        
        if minutes > 0 {
            return String(format: "%d:%02d.%d", minutes, seconds, deciseconds)
        } else {
            return String(format: "%d.%d", seconds, deciseconds)
        }
    }
    
    private func selectOption(_ option: String) {
        currentAnswer = option
    }
    
    private func appendToAnswer(_ digit: String) {
        // 防止重复小数点
        if digit == "." && currentAnswer.contains(".") {
            return
        }
        currentAnswer += digit
    }
    
    private func deleteLastCharacter() {
        if !currentAnswer.isEmpty {
            currentAnswer.removeLast()
        }
    }
    
    private func submitAnswer() {
        guard let manager = practiceManager else { return }
        
        // 更新管理器的当前答案
        manager.currentAnswer = currentAnswer
        
        // 检查答案是否正确
        let isCorrect = currentAnswer == manager.currentQuestion?.correctAnswer
        
        // 显示动画反馈
        if isCorrect {
            showCorrectAnimation = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showCorrectAnimation = false
            }
        } else {
            showWrongAnimation = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showWrongAnimation = false
            }
        }
        
        // 提交答案
        manager.submitAnswer()
        
        // 重置输入
        currentAnswer = ""
        
        // 如果练习完成，延迟显示结果
        if manager.isCompleted {
            stopTimer()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                navigateToResult = true
            }
        }
    }
}

struct NumberButton: View {
    let number: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(number)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}



#Preview {
    @State var navigationPath = NavigationPath()
    return PracticeView(questionType: .twoDigitAddition, questionCount: 5, navigationPath: $navigationPath)
        .modelContainer(for: [PracticeSession.self, Answer.self, WrongAnswer.self], inMemory: true)
}
