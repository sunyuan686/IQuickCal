//
//  QuestionType.swift
//  IQuickCal
//
//  Created by sunyuan on 2025/6/4.
//

import Foundation

enum QuestionType: String, CaseIterable, Codable {
    case mixed = "混合练习"
    case twoDigitAddition = "两位数加法"
    case twoDigitSubtraction = "两位数减法"
    case threeDigitAddition = "三位数加法"
    case threeDigitSubtraction = "三位数减法"
    case twoDigitMultiplication = "两位数乘法"
    case multiDigitDivisionTwo = "多位数除以两位数"
    case multiDigitDivisionThree = "多位数除以三位数"
    case fourDigitDivision = "四位数除法"
    
    var icon: String {
        switch self {
        case .mixed:
            return "shuffle"
        case .twoDigitAddition, .threeDigitAddition:
            return "plus"
        case .twoDigitSubtraction, .threeDigitSubtraction:
            return "minus"
        case .twoDigitMultiplication:
            return "multiply"
        case .multiDigitDivisionTwo, .multiDigitDivisionThree, .fourDigitDivision:
            return "divide"
        }
    }
    
    var color: String {
        switch self {
        case .mixed:
            return "blue"
        case .twoDigitAddition, .threeDigitAddition:
            return "blue"
        case .twoDigitSubtraction, .threeDigitSubtraction:
            return "red"
        case .twoDigitMultiplication:
            return "green"
        case .multiDigitDivisionTwo, .multiDigitDivisionThree, .fourDigitDivision:
            return "orange"
        }
    }
    
    var example: String {
        switch self {
        case .mixed:
            return "各种运算"
        case .twoDigitAddition:
            return "27 + 56"
        case .twoDigitSubtraction:
            return "89 - 34"
        case .threeDigitAddition:
            return "143 + 258"
        case .threeDigitSubtraction:
            return "726 - 319"
        case .twoDigitMultiplication:
            return "25 × 7"
        case .multiDigitDivisionTwo:
            return "86313 ÷ 41"
        case .multiDigitDivisionThree:
            return "86313 ÷ 411"
        case .fourDigitDivision:
            return "8631 ÷ 4112"
        }
    }
    
    // 推荐题量
    var recommendedQuestionCount: Int {
        switch self {
        case .mixed:
            return 20
        case .twoDigitAddition, .twoDigitSubtraction:
            return 20
        case .threeDigitAddition, .threeDigitSubtraction:
            return 20
        case .twoDigitMultiplication:
            return 40
        case .multiDigitDivisionTwo:
            return 20
        case .multiDigitDivisionThree:
            return 20
        case .fourDigitDivision:
            return 20
        }
    }
    
    // 推荐时间（分钟）
    var recommendedTimeInMinutes: Double {
        switch self {
        case .mixed:
            return 3.0
        case .twoDigitAddition, .twoDigitSubtraction:
            return 2.0
        case .threeDigitAddition, .threeDigitSubtraction:
            return 3.0
        case .twoDigitMultiplication:
            return 1.5
        case .multiDigitDivisionTwo:
            return 1.0
        case .multiDigitDivisionThree:
            return 4.0
        case .fourDigitDivision:
            return 4.0
        }
    }
    
    // 练习方式说明
    var practiceMethodDescription: String {
        switch self {
        case .mixed:
            return "综合练习"
        case .twoDigitAddition, .twoDigitSubtraction:
            return "口算"
        case .threeDigitAddition, .threeDigitSubtraction:
            return "口算"
        case .twoDigitMultiplication:
            return "口算"
        case .multiDigitDivisionTwo:
            return "口算，只需商首位"
        case .multiDigitDivisionThree:
            return "动笔，商前两位"
        case .fourDigitDivision:
            return "考场实战，根据选项差距截位"
        }
    }
    
    // 详细说明
    var detailedDescription: String? {
        switch self {
        case .multiDigitDivisionTwo:
            return "无需四舍五入（例：86313/41商2）"
        case .multiDigitDivisionThree:
            return "无需四舍五入（例：86313/411商21）"
        case .fourDigitDivision:
            return "4分钟优秀，6分钟及格"
        default:
            return nil
        }
    }
    
    // 格式化时间显示
    var formattedTime: String {
        let minutes = Int(recommendedTimeInMinutes)
        let seconds = Int((recommendedTimeInMinutes - Double(minutes)) * 60)
        
        if seconds == 0 {
            return "\(minutes)分钟"
        } else if seconds == 30 {
            return "\(minutes).5分钟"
        } else {
            return "\(minutes)分\(seconds)秒"
        }
    }
}
