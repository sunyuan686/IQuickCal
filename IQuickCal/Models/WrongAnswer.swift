//
//  WrongAnswer.swift
//  IQuickCal
//
//  Created by sunyuan on 2025/6/4.
//

import Foundation
import SwiftData

@Model
class WrongAnswer {
    var id: UUID
    var questionExpression: String
    var correctAnswer: String
    var userAnswer: String
    var questionType: QuestionType
    var wrongCount: Int
    var firstWrongAt: Date
    var lastWrongAt: Date
    var isMastered: Bool
    
    init(questionExpression: String, correctAnswer: String, userAnswer: String, questionType: QuestionType) {
        self.id = UUID()
        self.questionExpression = questionExpression
        self.correctAnswer = correctAnswer
        self.userAnswer = userAnswer
        self.questionType = questionType
        self.wrongCount = 1
        self.firstWrongAt = Date()
        self.lastWrongAt = Date()
        self.isMastered = false
    }
    
    func addWrongAttempt(userAnswer: String) {
        self.wrongCount += 1
        self.userAnswer = userAnswer
        self.lastWrongAt = Date()
    }
    
    func markAsMastered() {
        self.isMastered = true
    }
}
