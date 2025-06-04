//
//  PracticeSession.swift
//  IQuickCal
//
//  Created by sunyuan on 2025/6/4.
//

import Foundation
import SwiftData

@Model
class PracticeSession {
    var id: UUID
    var type: QuestionType
    var totalQuestions: Int
    var correctAnswers: Int
    var totalTime: TimeInterval
    var averageTime: TimeInterval
    var startTime: Date
    var endTime: Date?
    var isCompleted: Bool
    
    // 关联答题记录
    @Relationship(deleteRule: .cascade) var answers: [Answer] = []
    
    init(type: QuestionType, totalQuestions: Int) {
        self.id = UUID()
        self.type = type
        self.totalQuestions = totalQuestions
        self.correctAnswers = 0
        self.totalTime = 0
        self.averageTime = 0
        self.startTime = Date()
        self.isCompleted = false
    }
    
    var correctRate: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalQuestions)
    }
    
    var wrongAnswers: Int {
        return totalQuestions - correctAnswers
    }
}
