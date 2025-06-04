//
//  UserPreferences.swift
//  IQuickCal
//
//  Created by sunyuan on 2025/6/4.
//

import Foundation
import SwiftData

@Model
class UserPreferences {
    var id: UUID
    var questionsPerSet: Int
    var soundEnabled: Bool
    var hapticFeedbackEnabled: Bool
    var autoSubmitEnabled: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init() {
        self.id = UUID()
        self.questionsPerSet = 20 // 默认每类20题
        self.soundEnabled = true
        self.hapticFeedbackEnabled = true
        self.autoSubmitEnabled = true
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    func updateSettings(questionsPerSet: Int? = nil, soundEnabled: Bool? = nil, hapticFeedbackEnabled: Bool? = nil, autoSubmitEnabled: Bool? = nil) {
        if let questionsPerSet = questionsPerSet {
            self.questionsPerSet = questionsPerSet
        }
        if let soundEnabled = soundEnabled {
            self.soundEnabled = soundEnabled
        }
        if let hapticFeedbackEnabled = hapticFeedbackEnabled {
            self.hapticFeedbackEnabled = hapticFeedbackEnabled
        }
        if let autoSubmitEnabled = autoSubmitEnabled {
            self.autoSubmitEnabled = autoSubmitEnabled
        }
        self.updatedAt = Date()
    }
}
