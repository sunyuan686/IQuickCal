//
//  Answer.swift
//  IQuickCal
//
//  Created by sunyuan on 2025/6/4.
//

import Foundation
import SwiftData

@Model
class Answer {
    var id: UUID
    var questionExpression: String
    var correctAnswer: String
    var userAnswer: String
    var isCorrect: Bool
    var timeSpent: TimeInterval
    var answeredAt: Date
    var questionType: QuestionType
    
    // 关联练习会话
    var session: PracticeSession?
    
    init(questionExpression: String, correctAnswer: String, userAnswer: String, timeSpent: TimeInterval, questionType: QuestionType) {
        self.id = UUID()
        self.questionExpression = questionExpression
        self.correctAnswer = correctAnswer
        self.userAnswer = userAnswer
        self.isCorrect = userAnswer == correctAnswer
        self.timeSpent = timeSpent
        self.answeredAt = Date()
        self.questionType = questionType
    }
}
