import Foundation
import SwiftData

/// 用戶資料模型，支援 SwiftData 持久化
@Model
final class User {
    @Attribute(.unique) var id: UUID
    var name: String
    var birthday: Date?
    var gender: String?
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \AnswerRecord.user)
    var records: [AnswerRecord] = []

    init(name: String, birthday: Date? = nil, gender: String? = nil) {
        self.id = UUID()
        self.name = name
        self.birthday = birthday
        self.gender = gender
        self.createdAt = Date()
    }
}
