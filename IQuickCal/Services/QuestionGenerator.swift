//
//  QuestionGenerator.swift
//  IQuickCal
//
//  Created by sunyuan on 2025/6/4.
//

import Foundation

protocol QuestionGenerator {
    func generateQuestions(type: QuestionType, count: Int) -> [Question]
}

class DefaultQuestionGenerator: QuestionGenerator {
    
    func generateQuestions(type: QuestionType, count: Int) -> [Question] {
        var questions: [Question] = []
        
        for _ in 0..<count {
            let question = generateSingleQuestion(type: type)
            questions.append(question)
        }
        
        return questions
    }
    
    private func generateSingleQuestion(type: QuestionType) -> Question {
        switch type {
        case .twoDigitAddition:
            return generateTwoDigitAddition()
        case .twoDigitSubtraction:
            return generateTwoDigitSubtraction()
        case .threeDigitAddition:
            return generateThreeDigitAddition()
        case .threeDigitSubtraction:
            return generateThreeDigitSubtraction()
        case .twoDigitMultiplication:
            return generateTwoDigitMultiplication()
        case .multiDigitDivisionTwo:
            return generateMultiDigitDivisionTwo()
        case .multiDigitDivisionThree:
            return generateMultiDigitDivisionThree()
        case .fourDigitDivision:
            return generateFourDigitDivision()
        case .mixed:
            return generateMixedQuestion()
        }
    }
    
    // 混合练习 - 随机选择一种题型
    private func generateMixedQuestion() -> Question {
        let allTypes: [QuestionType] = [
            .twoDigitAddition,
            .twoDigitSubtraction,
            .threeDigitAddition,
            .threeDigitSubtraction,
            .twoDigitMultiplication,
            .multiDigitDivisionTwo,
            .multiDigitDivisionThree,
            .fourDigitDivision
        ]
        
        let randomType = allTypes.randomElement()!
        return generateSingleQuestion(type: randomType)
    }
    
    // 两位数加法
    private func generateTwoDigitAddition() -> Question {
        let num1 = Int.random(in: 10...99)
        let num2 = Int.random(in: 10...99)
        let expression = "\(num1) + \(num2)"
        let answer = "\(num1 + num2)"
        return Question(type: .twoDigitAddition, expression: expression, correctAnswer: answer)
    }
    
    // 两位数减法
    private func generateTwoDigitSubtraction() -> Question {
        let num1 = Int.random(in: 10...99)
        let num2 = Int.random(in: 10...min(num1, 99))
        let expression = "\(num1) - \(num2)"
        let answer = "\(num1 - num2)"
        return Question(type: .twoDigitSubtraction, expression: expression, correctAnswer: answer)
    }
    
    // 三位数加法
    private func generateThreeDigitAddition() -> Question {
        let num1 = Int.random(in: 100...999)
        let num2 = Int.random(in: 100...999)
        let expression = "\(num1) + \(num2)"
        let answer = "\(num1 + num2)"
        return Question(type: .threeDigitAddition, expression: expression, correctAnswer: answer)
    }
    
    // 三位数减法
    private func generateThreeDigitSubtraction() -> Question {
        let num1 = Int.random(in: 100...999)
        let num2 = Int.random(in: 100...min(num1, 999))
        let expression = "\(num1) - \(num2)"
        let answer = "\(num1 - num2)"
        return Question(type: .threeDigitSubtraction, expression: expression, correctAnswer: answer)
    }
    
    // 两位数乘以一位数
    private func generateTwoDigitMultiplication() -> Question {
        let num1 = Int.random(in: 10...99)
        let num2 = Int.random(in: 2...9)
        let expression = "\(num1) × \(num2)"
        let answer = "\(num1 * num2)"
        return Question(type: .twoDigitMultiplication, expression: expression, correctAnswer: answer)
    }
    
    // 多位数除以两位数（只需首位商）
    private func generateMultiDigitDivisionTwo() -> Question {
        let divisor = Int.random(in: 10...99)
        let quotientFirstDigit = Int.random(in: 1...9)
        let dividend = divisor * quotientFirstDigit + Int.random(in: 0..<divisor)
        
        // 确保是5位数
        let adjustedDividend = dividend < 10000 ? dividend + 10000 : dividend
        let finalDividend = adjustedDividend > 99999 ? adjustedDividend % 90000 + 10000 : adjustedDividend
        
        let expression = "\(finalDividend) ÷ \(divisor)"
        let actualQuotient = finalDividend / divisor
        let answer = "\(String(actualQuotient).first!)"
        
        return Question(type: .multiDigitDivisionTwo, expression: expression, correctAnswer: answer)
    }
    
    // 多位数除以三位数（商前两位）
    private func generateMultiDigitDivisionThree() -> Question {
        let divisor = Int.random(in: 100...999)
        let quotient = Int.random(in: 10...99)
        let dividend = divisor * quotient + Int.random(in: 0..<divisor)
        
        // 确保是5位数
        let adjustedDividend = dividend < 10000 ? dividend + 10000 : dividend
        let finalDividend = adjustedDividend > 99999 ? adjustedDividend % 90000 + 10000 : adjustedDividend
        
        let expression = "\(finalDividend) ÷ \(divisor)"
        let actualQuotient = finalDividend / divisor
        let quotientStr = String(actualQuotient)
        let answer = quotientStr.count >= 2 ? String(quotientStr.prefix(2)) : quotientStr
        
        return Question(type: .multiDigitDivisionThree, expression: expression, correctAnswer: answer)
    }
    
    // 四位数除法（四选一，保留两位小数）
    private func generateFourDigitDivision() -> Question {
        let num1 = Int.random(in: 1000...9999)
        let num2 = Int.random(in: 1000...9999)
        let expression = "\(num1) ÷ \(num2)"
        
        let result = Double(num1) / Double(num2)
        let correctAnswer = String(format: "%.2f", result)
        
        // 生成三个错误选项
        var options = [correctAnswer]
        for _ in 0..<3 {
            let wrongResult = result + Double.random(in: -0.5...0.5)
            let wrongAnswer = String(format: "%.2f", wrongResult)
            if !options.contains(wrongAnswer) {
                options.append(wrongAnswer)
            }
        }
        
        // 确保有4个选项
        while options.count < 4 {
            let wrongResult = result + Double.random(in: -1.0...1.0)
            let wrongAnswer = String(format: "%.2f", wrongResult)
            if !options.contains(wrongAnswer) {
                options.append(wrongAnswer)
            }
        }
        
        options.shuffle()
        
        return Question(type: .fourDigitDivision, expression: expression, correctAnswer: correctAnswer, options: options)
    }
}
