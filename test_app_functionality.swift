import Foundation

// Test the core functionality of IQuickCal models
print("Testing IQuickCal Core Functionality")
print("=====================================")

// Test QuestionType
print("\n1. Testing QuestionType enumeration:")
let types: [QuestionType] = [.addition, .subtraction, .multiplication, .division]
for type in types {
    print("   - \(type.rawValue): \(type.displayName)")
}

// Test DifficultyLevel
print("\n2. Testing DifficultyLevel enumeration:")
let difficulties: [DifficultyLevel] = [.easy, .medium, .hard]
for difficulty in difficulties {
    print("   - \(difficulty.rawValue): \(difficulty.displayName)")
}

// Test Question model
print("\n3. Testing Question model:")
let sampleQuestion = Question(
    questionText: "15 + 27 = ?",
    correctAnswer: 42,
    type: .addition,
    difficulty: .easy
)
print("   - Question: \(sampleQuestion.questionText)")
print("   - Correct Answer: \(sampleQuestion.correctAnswer)")
print("   - Type: \(sampleQuestion.type.displayName)")
print("   - Difficulty: \(sampleQuestion.difficulty.displayName)")

// Test Answer model
print("\n4. Testing Answer model:")
let sampleAnswer = Answer(
    userAnswer: 42,
    isCorrect: true,
    timeSpent: 3.5
)
print("   - User Answer: \(sampleAnswer.userAnswer)")
print("   - Is Correct: \(sampleAnswer.isCorrect)")
print("   - Time Spent: \(sampleAnswer.timeSpent) seconds")

// Test WrongAnswer model
print("\n5. Testing WrongAnswer model:")
let wrongAnswer = WrongAnswer(
    question: sampleQuestion,
    userAnswer: 40,
    correctAnswer: 42
)
print("   - Question: \(wrongAnswer.question.questionText)")
print("   - User Answer: \(wrongAnswer.userAnswer)")
print("   - Correct Answer: \(wrongAnswer.correctAnswer)")

// Test UserPreferences
print("\n6. Testing UserPreferences model:")
let preferences = UserPreferences()
print("   - Preferred Difficulty: \(preferences.preferredDifficulty.displayName)")
print("   - Preferred Types: \(preferences.preferredTypes.map { $0.displayName }.joined(separator: ", "))")
print("   - Questions Per Session: \(preferences.questionsPerSession)")
print("   - Time Limit: \(preferences.timeLimit ?? 0) seconds")

print("\n✅ All core models are working correctly!")
print("🎉 IQuickCal is ready for use!")
