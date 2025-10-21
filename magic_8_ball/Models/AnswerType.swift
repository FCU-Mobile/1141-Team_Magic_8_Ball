import Foundation

/// 答案類型枚舉，用於分類占卜答案的性質
enum AnswerType: String, Codable {
    case positive = "肯定"
    case negative = "否定"
    case neutral = "中性"
}
