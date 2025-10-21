import Foundation
import SwiftData

/// 用戶資料模型，支援 SwiftData 持久化
@Model
final class User {
    @Attribute(.unique) var id: UUID
    var name: String
    var birthday: Date
    var gender: Gender

    init(name: String, birthday: Date, gender: Gender) {
        self.id = UUID()
        self.name = name
        self.birthday = birthday
        self.gender = gender
    }

    /// 性別列舉
    enum Gender: String, Codable, CaseIterable, Identifiable {
        case male = "男"
        case female = "女"
        case other = "其他"

        var id: String { rawValue }
    }
}
