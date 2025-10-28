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
        // 肯定類型 💚
        (.positive, "穩了啦", "It is certain"),
        (.positive, "這必須贏", "It is decidedly so"),
        (.positive, "可以，這很可以", "Without a doubt"),
        (.positive, "鐵定沒問題", "Yes, definitely"),
        (.positive, "相信我的直覺", "You may rely on it"),
        (.positive, "依我看就是衝", "As I see it, yes"),
        (.positive, "八九不離十", "Most likely"),
        (.positive, "前途一片光明", "Outlook good"),
        (.positive, "就是這樣", "Yes"),
        (.positive, "宇宙都在幫你", "Signs point to yes"),
        
        // 中性類型 💙
        (.neutral, "訊號不穩，再問一次", "Reply hazy try again"),
        (.neutral, "等等再說吧", "Ask again later"),
        (.neutral, "現在說了你會後悔", "Better not tell you now"),
        (.neutral, "算命仙也不知道", "Cannot predict now"),
        (.neutral, "誠心發問才會靈", "Concentrate and ask again"),
        
        // 否定類型 ❤️
        (.negative, "別做夢了", "Don't count on it"),
        (.negative, "不行就是不行", "My reply is no"),
        (.negative, "內線消息說 NG", "My sources say no"),
        (.negative, "我勸你最好不要", "Outlook not so good"),
        (.negative, "這很有事", "Very doubtful")
    ]

}
