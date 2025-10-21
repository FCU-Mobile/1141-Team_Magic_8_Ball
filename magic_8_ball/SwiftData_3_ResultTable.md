## User

 [@ContentView.swift](zed:///agent/file?path=%2FUsers%2Fjoseph-m2%2FDev%2F1141-Team_Magic_8_Ball%2Fmagic_8_ball%2FContentView.swift) 將 struct HistoryView 轉換為 SwiftData 儲存，其中具備 FK 和 user table PK 關聯。

## Assistant

你希望將 `HistoryView` 的歷史紀錄資料從記憶體陣列（`[AnswerRecord]`）改為 SwiftData 儲存，並且讓每筆紀錄具備 FK（外鍵）與 user table PK（主鍵）關聯。這代表你需要：

1. 定義 SwiftData 的資料模型（`User` 與 `AnswerRecord`）。
2. 設計 `AnswerRecord` 具備外鍵，關聯到 `User` 的主鍵。
3. 修改 `HistoryView` 與 `ContentView`，讓它們從 SwiftData 讀寫資料，而不是只用 @State 陣列。

以下是步驟與範例程式碼：

---

## 1. 定義 SwiftData 資料模型

你需要兩個模型：`User` 和 `AnswerRecord`。`AnswerRecord` 會有一個 `@Relationship` 指向 `User`。

```magic_8_ball/Models.swift#L1-44
import Foundation
import SwiftData

@Model
final class User {
    @Attribute(.unique) var id: UUID
    var name: String
    @Relationship(deleteRule: .cascade, inverse: \AnswerRecord.user)
    var records: [AnswerRecord] = []

    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}

@Model
final class AnswerRecord {
    @Attribute(.unique) var id: UUID
    var question: String
    var answer: String
    var englishAnswer: String
    var typeRaw: Int // 0: affirmative, 1: neutral, 2: negative
    var timestamp: Date
    @Relationship var user: User?

    init(
        id: UUID = UUID(),
        question: String,
        answer: String,
        englishAnswer: String,
        typeRaw: Int,
        timestamp: Date,
        user: User?
    ) {
        self.id = id
        self.question = question
        self.answer = answer
        self.englishAnswer = englishAnswer
        self.typeRaw = typeRaw
        self.timestamp = timestamp
        self.user = user
    }
}
```

---

## 2. 修改 ContentView 與 HistoryView

- 使用 `@Query` 取得紀錄。
- 使用 `@Environment(\.modelContext)` 存取 SwiftData。
- 新增/查詢時，將 `AnswerRecord` 關聯到目前的 `User`。

### 主要修改重點

```magic_8_ball/ContentView.swift#L1-80
import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var question = ""
    @State private var currentAnswer = (MagicAnswerType.neutral, "", "")
    @State private var showAnswer = false
    @State private var showHistory = false

    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    @Query private var records: [AnswerRecord]

    // 假設只支援單一使用者（可擴充多帳號）
    private var currentUser: User? {
        users.first
    }

    // ... MagicAnswerType 與 answers 不變 ...

    var body: some View {
        // ... 省略 UI ...
        .sheet(isPresented: $showHistory) {
            HistoryView(user: currentUser)
        }
    }

    private func getAnswer() {
        // ... 動畫 ...
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            currentAnswer = answers.randomElement() ?? (MagicAnswerType.neutral, "請再試一次", "Please try again")
            if let user = currentUser {
                let record = AnswerRecord(
                    question: question,
                    answer: currentAnswer.1,
                    englishAnswer: currentAnswer.2,
                    typeRaw: currentAnswer.0.rawValue,
                    timestamp: Date(),
                    user: user
                )
                modelContext.insert(record)
            }
            // ... 動畫 ...
        }
    }
    // ... 其他程式碼 ...
}
```

### HistoryView

```magic_8_ball/ContentView.swift#L81-120
struct HistoryView: View {
    var user: User?
    @Query private var records: [AnswerRecord]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack {
                if let user = user {
                    let userRecords = records.filter { $0.user?.id == user.id }
                    if userRecords.isEmpty {
                        // ... 無紀錄畫面 ...
                    } else {
                        List {
                            ForEach(userRecords) { record in
                                // ... 顯示紀錄 ...
                            }
                        }
                    }
                } else {
                    Text("找不到使用者")
                }
            }
            .navigationTitle("解答記錄")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}
```

---

## 3. 其他注意事項

- 你需要在 App 入口（`magic_8_ballApp.swift`）初始化 SwiftData 的 ModelContainer。
- `MagicAnswerType` 建議加上 `rawValue`（Int）方便儲存。

---

如果你需要完整檔案內容或有多帳號需求，請告訴我！
