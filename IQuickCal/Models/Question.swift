//
//  Question.swift
//  IQuickCal
//
//  Created by sunyuan on 2025/6/4.
//

import Foundation
import SwiftData

@Model
class Question {
    var id: UUID
    var type: QuestionType
    var expression: String
    var correctAnswer: String
    var options: [String]? // 用于选择题（四位数除法）
    var isMultipleChoice: Bool
    var createdAt: Date
    
    init(type: QuestionType, expression: String, correctAnswer: String, options: [String]? = nil) {
        self.id = UUID()
        self.type = type
        self.expression = expression
        self.correctAnswer = correctAnswer
        self.options = options
        self.isMultipleChoice = options != nil
        self.createdAt = Date()
    }
}
