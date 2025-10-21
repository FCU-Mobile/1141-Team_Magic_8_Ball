import Foundation
import SwiftData

/// 占卜記錄模型，記錄每次占卜的問題和答案
@Model
final class AnswerRecord {
    @Attribute(.unique) var id: UUID
    var question: String
    var answer: String
    var answerType: AnswerType
    var timestamp: Date
    
    @Relationship var user: User
    
    init(question: String, answer: String, answerType: AnswerType, user: User) {
        self.id = UUID()
        self.question = question
        self.answer = answer
        self.answerType = answerType
        self.timestamp = Date()
        self.user = user
    }
}
