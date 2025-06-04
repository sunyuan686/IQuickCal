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
}
