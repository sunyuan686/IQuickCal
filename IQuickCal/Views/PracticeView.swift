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
                
                // 题目显示区域
                questionSection
                
                // 答案输入区域
                answerSection
                
                // 数字键盘
                numberPad
            }
        }
        .navigationTitle(questionType.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("退出") {
                    dismiss()
                }
            }
        }
        .onAppear {
            setupPracticeManager()
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .navigationDestination(isPresented: $navigateToResult) {
            if let session = practiceManager?.currentSession {
                ResultView(session: session)
            }
        }
    }
    
    @ViewBuilder
    private var progressSection: some View {
        if let manager = practiceManager {
            VStack(spacing: 12) {
                // 顶部时间和进度信息
                HStack {
                    // 总时间
                    VStack(alignment: .leading, spacing: 2) {
                        Text("总时间")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(formatTime(sessionElapsedTime))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    // 题目进度
                    Text("\(manager.currentQuestionIndex + 1) / \(manager.questions.count)")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    // 当前题时间
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("本题时间")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(formatTime(questionElapsedTime))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                }
                
                // 进度条
                ProgressView(value: manager.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .frame(height: 4)
                
                // 正确/错误统计
                HStack {
                    Spacer()
                    
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            Text("\(manager.correctCount)")
                                .fontWeight(.medium)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .font(.caption)
                            Text("\(manager.wrongCount)")
                                .fontWeight(.medium)
                        }
                    }
                    .font(.caption)
                    
                    Spacer()
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(Color(.separator)),
                alignment: .bottom
            )
        }
    }
    
    @ViewBuilder
    private var questionSection: some View {
        if let manager = practiceManager, let question = manager.currentQuestion {
            VStack(spacing: 32) {
                Spacer()
                
                // 题目表达式 - 更大更醒目
                Text(question.expression)
                    .font(.system(size: 48, weight: .medium, design: .monospaced))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text("=")
                    .font(.system(size: 32, weight: .light))
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 0)
                    .fill(showCorrectAnimation ? Color.green.opacity(0.1) : 
                          showWrongAnimation ? Color.red.opacity(0.1) : Color.clear)
            )
            .animation(.easeInOut(duration: 0.3), value: showCorrectAnimation)
            .animation(.easeInOut(duration: 0.3), value: showWrongAnimation)
        }
    }
    
    @ViewBuilder
    private var answerSection: some View {
        if let manager = practiceManager, let question = manager.currentQuestion {
            VStack(spacing: 16) {
                // 选择题选项
                if question.isMultipleChoice, let options = question.options {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                        ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                            Button(action: {
                                selectOption(option)
                            }) {
                                Text(option)
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundColor(currentAnswer == option ? .white : .primary)
                                    .frame(height: 50)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(currentAnswer == option ? Color.blue : Color(.systemGray6))
                                    )
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                } else {
                    // 答案输入框 - 占位符样式
                    Text(currentAnswer.isEmpty ? "答案" : currentAnswer)
                        .font(.system(size: 24, weight: .medium, design: .monospaced))
                        .foregroundColor(currentAnswer.isEmpty ? .secondary : .primary)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(.systemBackground))
                                )
                        )
                        .padding(.horizontal)
                }
                
                // 提交按钮
                Button(action: submitAnswer) {
                    Text("确认")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(currentAnswer.isEmpty ? Color(.systemGray4) : Color(.systemBlue))
                        )
                }
                .disabled(currentAnswer.isEmpty)
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal)
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private var numberPad: some View {
        if let manager = practiceManager, let question = manager.currentQuestion, !question.isMultipleChoice {
            VStack(spacing: 8) {
                // 数字按钮 1-9
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                    ForEach(1...9, id: \.self) { number in
                        NumberButton(number: "\(number)") {
                            appendToAnswer("\(number)")
                        }
                    }
                }
                
                // 底部行：小数点、0、删除
                HStack(spacing: 8) {
                    NumberButton(number: ".") {
                        appendToAnswer(".")
                    }
                    
                    NumberButton(number: "0") {
                        appendToAnswer("0")
                    }
                    
                    Button(action: deleteLastCharacter) {
                        Image(systemName: "delete.left.fill")
                            .font(.title3)
                            .foregroundColor(.primary)
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray6))
                            )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding()
            .background(Color(.systemBackground))
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
              !manager.isPaused,
              !manager.isCompleted else { return }
        
        if let sessionStart = manager.sessionStartTime {
            sessionElapsedTime = Date().timeIntervalSince(sessionStart)
        }
        
        if let questionStart = manager.questionStartTime {
            questionElapsedTime = Date().timeIntervalSince(questionStart)
        }
    }
    
    // 格式化时间显示
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        let deciseconds = Int((timeInterval * 10).truncatingRemainder(dividingBy: 10))
        
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
        
        // 重置当前题目计时
        questionElapsedTime = 0
        
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
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.primary)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray5), lineWidth: 0.5)
                        )
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}



#Preview {
    PracticeView(questionType: .twoDigitAddition, questionCount: 5)
        .modelContainer(for: [PracticeSession.self, Answer.self, WrongAnswer.self], inMemory: true)
}
