import AppIntents
import WidgetKit

struct RandomAnswerIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Random Answer"
    static var description = IntentDescription("Returns a random Magic 8 Ball answer.")

    static let answers: [(String, String)] = [
        ("這是必然", "It is certain"),
        ("肯定是的", "It is decidedly so"),
        ("不用懷疑", "Without a doubt"),
        ("毫無疑問", "Yes, definitely"),
        ("你能依靠它", "You may rely on it"),
        ("如我所見，是的", "As I see it, yes"),
        ("很有可能", "Most likely"),
        ("展望良好", "Outlook good"),
        ("是的", "Yes"),
        ("答案不明，請再問一次", "Reply hazy, try again"),
        ("再試一次", "Ask again later"),
        ("最好不要告訴你", "Better not tell you now"),
        ("無法預測", "Cannot predict now"),
        ("集中精神再問", "Concentrate and ask again"),
        ("不要指望它", "Don't count on it"),
        ("我的回答是否定的", "My reply is no"),
        ("展望不太好", "Outlook not so good"),
        ("很懷疑", "Very doubtful")
    ]

    func perform() async throws -> some IntentResult {
        // Trigger a widget timeline reload so a new random answer is shown
        WidgetCenter.shared.reloadTimelines(ofKind: "magic_8_ball_widget")
        return .result()
    }
}
