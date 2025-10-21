## User

[@ContentView.swift](zed:///agent/file?path=%2FUsers%2Fjoseph-m2%2FDev%2F1141-Team_Magic_8_Ball%2Fmagic_8_ball%2FContentView.swift) 目前使用 let answers 儲存答案， 改為使用 SwiftData 儲存。

## Assistant

你目前使用 `let answers` 儲存所有答案，並用 `[AnswerRecord]` 來管理歷史記錄。
要改用 SwiftData 儲存歷史記錄（即問答紀錄），請依照以下步驟調整：

---

## 1. 建立 SwiftData 資料模型

新增一個 SwiftData 模型，取代 `AnswerRecord` 結構：

```/dev/null/MagicAnswer.swift#L1-15
import SwiftData
import SwiftUI

@Model
class MagicAnswer {
    var id: UUID
    var question: String
    var answer: String
    var englishAnswer: String
    var typeRaw: String
    var timestamp: Date

    init(question: String, answer: String, englishAnswer: String, typeRaw: String, timestamp: Date = Date()) {
        self.id = UUID()
        self.question = question
        self.answer = answer
        self.englishAnswer = englishAnswer
        self.typeRaw = typeRaw
        self.timestamp = timestamp
    }
}
```

> `typeRaw` 用來儲存答案型別（"affirmative"、"neutral"、"negative"），在 View 轉換為 enum。

---

## 2. 注入 ModelContainer

請參考前述回覆，將 `.modelContainer(for: MagicAnswer.self)` 加入 `magic_8_ballApp.swift`。

---

## 3. 修改 ContentView 使用 SwiftData

### 主要調整：

- 用 `@Query var answerHistory: [MagicAnswer]` 取代 `@State private var answerHistory: [AnswerRecord]`
- 用 `@Environment(\.modelContext)` 操作資料
- 新增紀錄時，插入到 SwiftData

### 範例程式碼：

```/Users/joseph-m2/Dev/1141-Team_Magic_8_Ball/magic_8_ball/ContentView.swift#L1-40
import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var question = ""
    @State private var currentAnswer = (MagicAnswerType.neutral, "", "")
    @State private var showAnswer = false
    @State private var showHistory = false

    @Query(sort: \.timestamp, order: .reverse) var answerHistory: [MagicAnswer]
    @Environment(\.modelContext) private var modelContext

    enum MagicAnswerType: String {
        case affirmative, neutral, negative

        var color: Color {
            switch self {
            case .affirmative: return .green
            case .neutral: return .blue
            case .negative: return .red
            }
        }
    }

    let answers = [
        (MagicAnswerType.affirmative, "這是必然", "It is certain"),
        // ... 其他答案 ...
        (MagicAnswerType.negative, "很可疑", "Very doubtful")
    ]

    var body: some View {
        // ... 你的 UI 保持不變 ...
        .sheet(isPresented: $showHistory) {
            HistoryView(answerHistory: answerHistory)
        }
    }

    private func getAnswer() {
        withAnimation(.easeOut(duration: 0.5)) {
            showAnswer = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            currentAnswer = answers.randomElement() ?? (MagicAnswerType.neutral, "請再試一次", "Please try again")

            // SwiftData 新增紀錄
            let record = MagicAnswer(
                question: question,
                answer: currentAnswer.1,
                englishAnswer: currentAnswer.2,
                typeRaw: currentAnswer.0.rawValue,
                timestamp: Date()
            )
            modelContext.insert(record)

            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showAnswer = true
            }
        }
    }

    // ... 其他程式碼不變 ...
}
```

---

## 4. 修改 HistoryView

將 `HistoryView` 改為接收 `[MagicAnswer]`，並在顯示時將 `typeRaw` 轉回 enum：

```/Users/joseph-m2/Dev/1141-Team_Magic_8_Ball/magic_8_ball/ContentView.swift#L41-80
struct HistoryView: View {
    let answerHistory: [MagicAnswer]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack {
                if answerHistory.isEmpty {
                    // ... 空狀態 ...
                } else {
                    List {
                        ForEach(answerHistory) { record in
                            VStack(alignment: .leading, spacing: 8) {
                                // ... 顯示內容 ...
                                let type = ContentView.MagicAnswerType(rawValue: record.typeRaw) ?? .neutral
                                HStack {
                                    Circle()
                                        .fill(type.color)
                                        .frame(width: 8, height: 8)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(record.answer)
                                            .font(.body)
                                            .foregroundColor(type.color)
                                        Text(record.englishAnswer)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.top, 4)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            // ... 其他 UI 不變 ...
        }
    }
}
```

---

## 5. 小結

- 歷史記錄將自動持久化於 SwiftData。
- UI/互動邏輯基本不變，只需將資料來源與儲存方式切換到 SwiftData。
- 若需完整檔案內容，請告知，我可以直接幫你產生整合後的檔案！

如需進一步協助（如資料刪除、資料遷移等），隨時告訴我！
