//
//  PracticeManager.swift
//  IQuickCal
//
//  Created by sunyuan on 2025/6/4.
//

import Foundation
import SwiftUI
import SwiftData

@Observable
class PracticeManager {
    private let questionGenerator: QuestionGenerator
    private let modelContext: ModelContext
    
    // 当前练习状态
    var currentSession: PracticeSession?
    var questions: [Question] = []
    var currentQuestionIndex: Int = 0
    var currentAnswer: String = ""
    var isCompleted: Bool = false
    var isPaused: Bool = false
    
    // 计时相关
    var sessionStartTime: Date?
    var questionStartTime: Date?
    var totalElapsedTime: TimeInterval = 0
    var totalPausedTime: TimeInterval = 0
    var pauseStartTime: Date?
    var questionElapsedTime: TimeInterval = 0
    var questionPausedTime: TimeInterval = 0
    
    // 统计信息
    var correctCount: Int = 0
    var wrongCount: Int = 0
    
    init(modelContext: ModelContext, questionGenerator: QuestionGenerator = DefaultQuestionGenerator()) {
        self.modelContext = modelContext
        self.questionGenerator = questionGenerator
    }
    
    // 开始练习
    func startPractice(type: QuestionType, questionCount: Int) {
        // 创建新的练习会话
        currentSession = PracticeSession(type: type, totalQuestions: questionCount)
        
        // 生成题目
        questions = questionGenerator.generateQuestions(type: type, count: questionCount)
        
        // 重置状态
        currentQuestionIndex = 0
        currentAnswer = ""
        correctCount = 0
        wrongCount = 0
        totalElapsedTime = 0
        totalPausedTime = 0
        pauseStartTime = nil
        questionElapsedTime = 0
        questionPausedTime = 0
        isCompleted = false
        isPaused = false
        
        // 开始计时
        sessionStartTime = Date()
        questionStartTime = Date()
        
        // 保存会话到数据库
        if let session = currentSession {
            modelContext.insert(session)
        }
    }
    
    // 提交答案
    func submitAnswer() {
        guard let currentQuestion = currentQuestion,
              let session = currentSession,
              questionStartTime != nil else { return }
        
        let timeSpent = currentQuestionElapsedTime
        let isCorrect = currentAnswer == currentQuestion.correctAnswer
        
        // 创建答题记录
        let answer = Answer(
            questionExpression: currentQuestion.expression,
            correctAnswer: currentQuestion.correctAnswer,
            userAnswer: currentAnswer,
            timeSpent: timeSpent,
            questionType: currentQuestion.type
        )
        answer.session = session
        
        // 更新统计
        if isCorrect {
            correctCount += 1
        } else {
            wrongCount += 1
            // 记录错题
            recordWrongAnswer(question: currentQuestion, userAnswer: currentAnswer)
        }
        
        // 保存答题记录
        modelContext.insert(answer)
        session.answers.append(answer)
        
        // 移动到下一题或完成练习
        if currentQuestionIndex < questions.count - 1 {
            moveToNextQuestion()
        } else {
            completePractice()
        }
    }
    
    // 移动到下一题
    private func moveToNextQuestion() {
        currentQuestionIndex += 1
        currentAnswer = ""
        questionStartTime = Date()
        questionElapsedTime = 0
        questionPausedTime = 0
        
        // 如果当前处于暂停状态，重置暂停开始时间为当前时间
        // 这样新题目的暂停时间计算才是正确的
        if isPaused {
            pauseStartTime = Date()
        }
    }
    
    // 完成练习
    private func completePractice() {
        guard let session = currentSession,
              sessionStartTime != nil else { return }
        
        isCompleted = true
        let totalTime = currentSessionElapsedTime
        
        // 更新会话信息
        session.correctAnswers = correctCount
        session.totalTime = totalTime
        session.averageTime = totalTime / Double(questions.count)
        session.endTime = Date()
        session.isCompleted = true
        
        // 保存到数据库
        try? modelContext.save()
    }
    
    // 记录错题
    private func recordWrongAnswer(question: Question, userAnswer: String) {
        // 查找是否已存在相同表达式的错题
        let expression = question.expression
        let descriptor = FetchDescriptor<WrongAnswer>(
            predicate: #Predicate<WrongAnswer> { wrongAnswer in
                wrongAnswer.questionExpression == expression
            }
        )
        
        if let existingWrong = try? modelContext.fetch(descriptor).first {
            // 增加错误次数
            existingWrong.addWrongAttempt(userAnswer: userAnswer)
        } else {
            // 创建新的错题记录
            let wrongAnswer = WrongAnswer(
                questionExpression: question.expression,
                correctAnswer: question.correctAnswer,
                userAnswer: userAnswer,
                questionType: question.type
            )
            modelContext.insert(wrongAnswer)
        }
    }
    
    // 暂停/恢复练习
    func togglePause() {
        isPaused.toggle()
        
        if isPaused {
            // 暂停时记录暂停开始时间
            pauseStartTime = Date()
        } else {
            // 恢复时累计暂停时间
            if let pauseStart = pauseStartTime {
                let pauseDuration = Date().timeIntervalSince(pauseStart)
                totalPausedTime += pauseDuration
                questionPausedTime += pauseDuration
                pauseStartTime = nil
            }
        }
    }
    
    // 获取当前题目
    var currentQuestion: Question? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    // 获取进度
    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentQuestionIndex) / Double(questions.count)
    }
    
    // 获取当前有效的总会话时间（不包括暂停时间）
    var currentSessionElapsedTime: TimeInterval {
        guard let sessionStart = sessionStartTime else { return 0 }
        let totalRawTime = Date().timeIntervalSince(sessionStart)
        let currentPausedTime = isPaused ? (pauseStartTime.map { Date().timeIntervalSince($0) } ?? 0) : 0
        return max(0, totalRawTime - totalPausedTime - currentPausedTime)
    }
    
    // 获取当前题目的有效用时（不包括暂停时间）
    var currentQuestionElapsedTime: TimeInterval {
        guard let questionStart = questionStartTime else { return 0 }
        let totalRawTime = Date().timeIntervalSince(questionStart)
        let currentPausedTime = isPaused ? (pauseStartTime.map { Date().timeIntervalSince($0) } ?? 0) : 0
        return max(0, totalRawTime - questionPausedTime - currentPausedTime)
    }
    
        // 重置练习
        func resetPractice() {
            currentSession = nil
            questions = []
            currentQuestionIndex = 0
            currentAnswer = ""
            isCompleted = false
            isPaused = false
            sessionStartTime = nil
            questionStartTime = nil
            totalElapsedTime = 0
            totalPausedTime = 0
            pauseStartTime = nil
            questionElapsedTime = 0
            questionPausedTime = 0
            correctCount = 0
            wrongCount = 0
        }
}
