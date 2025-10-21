import Foundation
import SwiftUI

/// 答案類型枚舉，用於分類占卜答案的性質
enum AnswerType: String, Codable {
    case positive = "肯定"
    case negative = "否定"
    case neutral = "中性"
    
    /// 對應的顏色
    var color: Color {
        switch self {
        case .positive:
            return .green
        case .negative:
            return .red
        case .neutral:
            return .blue
        }
    }
    
    /// 所有預設的占卜答案（中英文對照）
    static let allAnswers: [(AnswerType, String, String)] = [
        // 肯定類型
        (.positive, "這是必然", "It is certain"),
        (.positive, "肯定是的", "It is decidedly so"),
        (.positive, "不用懷疑", "Without a doubt"),
        (.positive, "毫無疑問", "Yes, definitely"),
        (.positive, "你能依靠它", "You may rely on it"),
        (.positive, "如我所見，是的", "As I see it, yes"),
        (.positive, "很有可能", "Most likely"),
        (.positive, "前景很好", "Outlook good"),
        (.positive, "是的", "Yes"),
        (.positive, "種種跡象指出「是的」", "Signs point to yes"),
        
        // 中性類型
        (.neutral, "回覆籠統，再試試", "Reply hazy try again"),
        (.neutral, "待會再問", "Ask again later"),
        (.neutral, "最好現在不告訴你", "Better not tell you now"),
        (.neutral, "現在無法預測", "Cannot predict now"),
        (.neutral, "專心再問一遍", "Concentrate and ask again"),
        
        // 否定類型
        (.negative, "想的美", "Don't count on it"),
        (.negative, "我的回覆是「不」", "My reply is no"),
        (.negative, "我的來源說「不」", "My sources say no"),
        (.negative, "前景不太好", "Outlook not so good"),
        (.negative, "很可疑", "Very doubtful")
    ]
}
