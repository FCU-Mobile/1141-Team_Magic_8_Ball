import AppIntents
import SwiftUI
import SwiftData
import WidgetKit

struct RandomAnswerIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Random Answer"
    static var description = IntentDescription("Returns a random Magic 8 Ball answer.")
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult {
        // 產生新答案
        let allAnswers = AnswerType.allAnswers
        let randomAnswer = allAnswers.randomElement() ?? (.neutral, "請再試一次", "Please try again")
        let answerType = randomAnswer.0
        let answer = randomAnswer.1
        let answerTypeRawValue = answerType.rawValue
        let timestamp = Date()
        let questionText = "Widget 快速占卜"
        
        print("🎲 Widget: 產生新答案 - \(answer)")
        
        // 儲存到 UserDefaults（用於即時顯示）
        let defaults = UserDefaults.standard
        defaults.set(answer, forKey: "LatestWidgetAnswer")
        defaults.set(answerTypeRawValue, forKey: "LatestWidgetAnswerType")
        defaults.set(timestamp, forKey: "LatestWidgetTimestamp")
        defaults.synchronize()
        print("✅ Widget答案已儲存到 UserDefaults")
        
        // 嘗試儲存到 SwiftData（用於歷史記錄）
        await saveToDatabase(question: questionText, answer: answer, answerType: answerType)

        // 立即重新整理Widget顯示
        print("🔄 Widget: 重新整理 Timeline")
        WidgetCenter.shared.reloadTimelines(ofKind: "magic_8_ball_widget")
        
        return .result()
    }
    
    private func saveToDatabase(question: String, answer: String, answerType: AnswerType) async {
        do {
            let schema = Schema([User.self, AnswerRecord.self])
            var container: ModelContainer?
            
            // 優先嘗試使用 App Group
            if let appGroupURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: "group.magic8ball.shared"
            ) {
                let storeURL = appGroupURL.appendingPathComponent("magic8ball.sqlite")
                print("📁 使用 App Group 路徑: \(storeURL.path)")
                let modelConfiguration = ModelConfiguration(url: storeURL)
                container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            } else {
                // 如果 App Group 不可用，嘗試使用共享的預設路徑
                print("⚠️ App Group 不可用，嘗試使用預設路徑")
                container = try ModelContainer(for: schema)
            }
            
            guard let container = container else {
                print("❌ 無法建立 ModelContainer")
                return
            }
            
            let context = ModelContext(container)
            
            // 查詢第一個用戶
            let userDescriptor = FetchDescriptor<User>()
            let users = try context.fetch(userDescriptor)
            
            if let user = users.first {
                // 建立新記錄
                let record = AnswerRecord(
                    question: question,
                    answer: answer,
                    answerType: answerType,
                    user: user
                )
                context.insert(record)
                try context.save()
                print("✅ Widget記錄已儲存到 SwiftData（用戶: \(user.name)）")
            } else {
                print("⚠️ 找不到用戶，請先在主 App 中創建用戶")
            }
        } catch {
            print("❌ Widget儲存到資料庫失敗: \(error.localizedDescription)")
        }
    }
}
