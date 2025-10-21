# Magic 8 Ball SwiftData 整合需求文件

## 文件資訊
- **版本**: 2.2
- **建立日期**: 2025/1/24
- **最後更新**: 2025/1/24
- **專案名稱**: Magic 8 Ball iOS App
- **文件目的**: SwiftData 持久化資料整合需求規範
- **開發策略**: 標準 MVP - 平衡功能完整度與開發時間
- **配套文件**: 
  - `SwiftData_MVP_Strategy.md` - MVP 策略說明
  - `SwiftData_Todo.md` - 詳細任務清單

---

## 目錄

1. [系統需求](#系統需求)
2. [核心決策](#核心決策標準-mvp---2-週)
3. [MVP 範圍界定](#mvp-範圍界定-)
4. [必須修正項目](#零必須修正與強烈建議事項-)
5. [資料模型設計](#一資料模型設計)
6. [整合實作步驟](#三整合實作步驟)
7. [錯誤處理策略](#43-錯誤處理策略)
8. [總結與建議](#八總結與建議)
9. [快速參考](#九快速參考-)

---

## 系統需求
- **最低 iOS 版本**: iOS 17.0+
- **建議 iOS 版本**: iOS 17.2+ (修復早期 SwiftData bugs)
- **macOS 版本**: macOS 14.0+ (若支援 macOS)
- **Xcode 版本**: Xcode 15.0+
- **Swift 版本**: Swift 5.9+

> ⚠️ **重要**: SwiftData 是 iOS 17 的新功能，不支援舊版本 iOS。若專案需支援 iOS 16 或更早版本，請改用 Core Data。

## 核心決策（標準 MVP）
- ✅ **刪除策略**: 採用 `cascade` - 刪除用戶時連同刪除所有相關記錄
- ✅ **模型註冊**: 必須同時註冊 `User.self` 和 `AnswerRecord.self`
- ✅ **錯誤處理**: 所有 SwiftData 操作必須實作完整的 try-catch 處理
- ✅ **用戶管理**: 首次啟動引導建立用戶（UserCreationView）
- ✅ **用戶數量**: 限制 **僅 1 個用戶**，提供清理重建功能
- ✅ **錯誤恢復**: ModelContainer 初始化失敗時顯示 DatabaseErrorView
- ✅ **用戶識別**: 採用動態查詢方式識別當前用戶，避免 @AppStorage 單點失效
- ✅ **MVP 範圍**: 階段一實作基本資料持久化，階段二補充 UI 和錯誤處理

## MVP 範圍界定 🎯

### 標準 MVP 包含功能
**階段一：基礎實作**
- ✅ User 模型（name, birthday, gender, createdAt）
- ✅ AnswerRecord 模型（question, answer, timestamp）
- ✅ ModelContainer 基本設定（容錯處理）
- ✅ ContentView 改用 @Query（只讀歷史）
- ✅ 基本儲存功能（問答後自動存）

**階段二：UI 和錯誤處理**
- ✅ DatabaseErrorView（容錯處理）
- ✅ UserCreationView（首次使用建立用戶）
- ✅ 動態用戶查詢（修正 @AppStorage 問題）
- ✅ 完整錯誤處理（所有 save() 使用 do-catch）
- ✅ 基本 UI/UX 測試

### 延後實作功能（非 MVP 範圍）
- ❌ UserProfileView（顯示用戶資料）
- ❌ 用戶資料編輯功能（UserEditView）
- ❌ 複雜的資料統計分析
- ❌ 資料匯出/匯入功能
- ❌ 效能優化（fetchLimit、分頁）
- ❌ 進階錯誤恢復機制
- ❌ 單元測試和 UI 測試

---

## 零、必須修正與強烈建議事項 🔴

### 0.1 必須修正項目 (Critical Fixes)

本節列出在基礎 SwiftData 實作中**必須修正**的關鍵問題，若不處理將導致 App 不穩定或用戶體驗不佳。

---

#### 修正 1: 移除 fatalError，實作優雅的錯誤處理 🚨

**問題描述**:
目前 ModelContainer 初始化失敗時使用 `fatalError`，會導致 App 直接閃退，用戶體驗極差。

**現有錯誤實作**:
```swift
} catch {
    fatalError("無法建立 ModelContainer: \(error)")  // ❌ 直接閃退
}
```

**✅ 必須改為**:

```swift
// magic_8_ballApp.swift
import SwiftUI
import SwiftData

@main
struct magic_8_ballApp: App {
    @State private var modelContainerError: Error?
    
    // ✅ 改為可選型，初始化失敗返回 nil
    var sharedModelContainer: ModelContainer? = {
        let schema = Schema([
            User.self,
            AnswerRecord.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        
        do {
            let container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            print("✅ ModelContainer 建立成功")
            return container
        } catch {
            // ✅ 記錄錯誤但不閃退
            print("❌ ModelContainer 建立失敗: \(error.localizedDescription)")
            return nil
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            // ✅ 根據 container 狀態顯示不同畫面
            if let container = sharedModelContainer {
                ContentView()
                    .modelContainer(container)
            } else {
                DatabaseErrorView()
            }
        }
    }
}

/// ✅ 資料庫錯誤畫面
struct DatabaseErrorView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("資料庫初始化失敗")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("請嘗試以下方式解決：")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "1.circle.fill")
                    Text("重新啟動 App")
                }
                HStack {
                    Image(systemName: "2.circle.fill")
                    Text("檢查儲存空間是否充足")
                }
                HStack {
                    Image(systemName: "3.circle.fill")
                    Text("若問題持續，請重新安裝 App")
                }
            }
            .font(.callout)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            Button("重新啟動") {
                // 觸發 App 重新啟動
                exit(0)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
        }
        .padding()
        .multilineTextAlignment(.center)
    }
}
```

**實作檢查清單**:
- [ ] 移除所有 `fatalError` 改為錯誤處理
- [ ] 實作 DatabaseErrorView
- [ ] 測試：模擬初始化失敗情境
- [ ] 驗證：顯示錯誤畫面而非閃退

---

#### 修正 2: 修正 @AppStorage 單點失效問題 🚨

**問題描述**:
使用 `@AppStorage("currentUserId")` 儲存當前用戶 ID，當 UserDefaults 清空時會造成用戶識別失效。

**現有錯誤實作**:
```swift
@AppStorage("currentUserId") private var currentUserId: String = ""

var currentUser: User? {
    users.first { $0.id.uuidString == currentUserId }  // ⚠️ 若 currentUserId 為空，返回 nil
}
```

**✅ 必須改為動態查詢**:

**方案 A: 純動態查詢（推薦 - 單用戶模式）**
```swift
// ContentView.swift
struct ContentView: View {
    @Query private var users: [User]
    @Environment(\.modelContext) private var modelContext
    
    // ✅ 動態查詢，始終返回唯一用戶
    var currentUser: User? {
        users.first  // 單用戶模式，直接返回第一個（也是唯一）用戶
    }
    
    var body: some View {
        VStack {
            if let user = currentUser {
                // 有用戶，正常使用
                MainContentView(user: user)
            } else {
                // 無用戶，顯示建立畫面
                UserCreationView()
            }
        }
        .onAppear {
            validateAndInitializeUser()
        }
    }
    
    /// ✅ 啟動時驗證用戶狀態
    private func validateAndInitializeUser() {
        // 檢查是否有用戶
        if users.isEmpty {
            print("⚠️ 無用戶，需要建立")
            // 自動顯示建立畫面
        } else if users.count > 1 {
            // ⚠️ 不應該發生：多於一個用戶
            print("⚠️ 警告：發現 \(users.count) 個用戶，應該只有 1 個")
            // 可選：清理多餘用戶
        } else {
            print("✅ 用戶已存在: \(users.first!.name)")
        }
    }
}
```

**方案 B: 混合模式（保留 @AppStorage 但加強驗證）**
```swift
struct ContentView: View {
    @Query private var users: [User]
    @Environment(\.modelContext) private var modelContext
    
    @AppStorage("currentUserId") private var currentUserId: String = ""
    
    // ✅ 加強驗證的計算屬性
    var currentUser: User? {
        // 1. 優先使用 AppStorage 的 ID
        if !currentUserId.isEmpty,
           let user = users.first(where: { $0.id.uuidString == currentUserId }) {
            return user
        }
        
        // 2. 若 ID 無效，返回第一個用戶（單用戶模式）
        if let firstUser = users.first {
            // 修復：更新 currentUserId
            currentUserId = firstUser.id.uuidString
            print("✅ 已修復 currentUserId: \(firstUser.name)")
            return firstUser
        }
        
        // 3. 無用戶
        return nil
    }
    
    var body: some View {
        // ... 同上
    }
}
```

**實作檢查清單**:
- [ ] 移除依賴 @AppStorage 的關鍵邏輯
- [ ] 實作動態查詢或驗證機制
- [ ] 測試：清除 UserDefaults 後 App 仍正常運作
- [ ] 測試：重新安裝 App 後正確識別用戶

---

#### 修正 3: 明確 iOS 17 版本要求 ⚠️

**問題描述**:
文件未明確說明 SwiftData 需要 iOS 17+，可能導致開發者誤用。

**✅ 必須在專案設定中明確**:

```swift
// Package.swift 或 project settings
platforms: [
    .iOS(.v17),  // ✅ 明確要求 iOS 17
    .macOS(.v14)
],
```

**Info.plist 或 target 設定**:
```xml
<key>MinimumOSVersion</key>
<string>17.0</string>
```

**實作檢查清單**:
- [ ] 設定 Deployment Target 為 iOS 17.0
- [ ] 在 README 中說明系統需求
- [ ] 在 App Store 描述中註明系統需求
- [ ] 測試：在 iOS 17 模擬器上運行正常

---

### 0.2 強烈建議項目 (Recommended Improvements)

本節列出**強烈建議**實作的改善項目，可大幅提升程式品質、可維護性和用戶體驗。

---

#### 建議 1: 說明單用戶設計的理由與權衡 📝

**問題描述**:
文件採用「限制 1 個用戶」+ 「保留 User 模型」的設計，但未說明為何需要 User 模型。

**✅ 必須在文件中補充**:

**為何採用 User 模型？**

儘管系統限制只有 1 個用戶，但仍保留 User 模型基於以下考量：

1. **資料結構完整性**: 
   - 問答記錄需要關聯到用戶資訊（姓名、生日、性別）
   - 分離 User 和 AnswerRecord 符合正規化設計

2. **未來擴展性**:
   - 若需求變更（如支援多用戶），只需移除數量限制
   - 無需重構整個資料模型

3. **業務邏輯清晰**:
   - 明確區分「用戶資料」和「問答記錄」
   - 便於實作用戶資料編輯功能

4. **級聯刪除需求**:
   - 需要「刪除用戶時同時刪除所有記錄」的邏輯
   - 使用 `cascade` 關聯比手動刪除更可靠

**替代方案比較**:

| 方案 | 優點 | 缺點 | 適用情境 |
|-----|------|------|---------|
| **方案 A: 保留 User 模型**（當前） | 結構清晰、可擴展 | 略微複雜 | 可能未來多用戶 |
| **方案 B: 無 User 模型** | 極簡、效能最佳 | 無擴展性 | 確定永遠單用戶 |
| **方案 C: UserDefaults 儲存** | 最簡單 | 無資料關聯 | 僅個人設定 |

**建議**: 當前採用**方案 A**，若確定永不擴展可改為**方案 B**。

---

#### 建議 2: @Query 效能優化與查詢限制 ⚡

**問題描述**:
目前使用 `@Query` 查詢所有記錄，當記錄數量多時可能影響效能。

**現有實作**:
```swift
@Query private var allRecords: [AnswerRecord]  // ⚠️ 查詢所有記錄
```

**✅ 強烈建議優化**:

**優化 1: 限制查詢數量**
```swift
// ✅ 只查詢最近 100 筆記錄
@Query(
    sort: \.timestamp,
    order: .reverse
) 
private var recentRecords: [AnswerRecord]

// 在 View 中手動限制
var displayRecords: [AnswerRecord] {
    Array(recentRecords.prefix(100))
}
```

**優化 2: 使用 FetchDescriptor（推薦）**
```swift
import SwiftData

struct ContentView: View {
    @Query(
        FetchDescriptor<AnswerRecord>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)],
            predicate: nil,
            fetchLimit: 100  // ✅ 資料庫層面限制
        ),
        animation: .default
    )
    private var records: [AnswerRecord]
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        List(records) { record in
            // 顯示記錄
        }
    }
}
```

**優化 3: 分頁載入**
```swift
struct HistoryView: View {
    @State private var fetchLimit = 50
    @State private var hasMoreData = true
    
    @Query var records: [AnswerRecord]
    
    init() {
        let descriptor = FetchDescriptor<AnswerRecord>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)],
            fetchLimit: fetchLimit
        )
        _records = Query(descriptor)
    }
    
    var body: some View {
        List {
            ForEach(records) { record in
                RecordRow(record: record)
            }
            
            // ✅ 載入更多按鈕
            if hasMoreData {
                Button("載入更多") {
                    loadMore()
                }
            }
        }
    }
    
    func loadMore() {
        fetchLimit += 50
        // 觸發重新查詢
    }
}
```

**效能測試基準**:
- [ ] 測試 100 筆記錄的載入時間 < 100ms
- [ ] 測試 1000 筆記錄的載入時間 < 500ms
- [ ] 測試滑動列表的流暢度 (60 FPS)

---

#### 建議 3: 並發存取與執行緒安全 🔒

**問題描述**:
ModelContext 不是執行緒安全的，在背景執行緒操作可能導致崩潰。

**現有風險**:
```swift
// ❌ 危險：可能在背景執行緒執行
Task {
    modelContext.insert(record)
    try modelContext.save()
}
```

**✅ 強烈建議規範**:

**規範 1: 使用 @MainActor**
```swift
// ✅ 確保在主執行緒執行
@MainActor
func saveRecord(_ record: AnswerRecord) async throws {
    modelContext.insert(record)
    try modelContext.save()
}

// 呼叫時
Task { @MainActor in
    try await saveRecord(newRecord)
}
```

**規範 2: 背景操作使用獨立 Context**
```swift
// ✅ 背景匯入大量資料
func importRecords(_ records: [ImportData]) async throws {
    // 建立背景 Context
    let backgroundContext = ModelContext(modelContainer)
    
    await backgroundContext.perform {
        for recordData in records {
            let record = AnswerRecord(from: recordData)
            backgroundContext.insert(record)
        }
        
        try backgroundContext.save()
    }
}
```

**規範 3: 使用 ModelActor (iOS 17+)**
```swift
@ModelActor
actor DataManager {
    func saveRecord(_ record: AnswerRecord) throws {
        modelContext.insert(record)
        try modelContext.save()
    }
    
    func fetchRecords() throws -> [AnswerRecord] {
        let descriptor = FetchDescriptor<AnswerRecord>()
        return try modelContext.fetch(descriptor)
    }
}

// 使用
let manager = DataManager(modelContainer: container)
try await manager.saveRecord(newRecord)
```

**實作檢查清單**:
- [ ] 所有 UI 操作的 save() 標註 @MainActor
- [ ] 背景操作使用獨立 Context
- [ ] 測試：多執行緒同時操作無崩潰

---

## 一、現況分析

### 1.1 專案現況
- **框架**: SwiftUI
- **App 入口**: `magic_8_ballApp.swift`
- **主要視圖**: `ContentView.swift`
- **現有功能**:
  - 魔術 8 球問答互動
  - 20 種預設答案（正面/中立/負面）
  - 記憶體內的歷史紀錄（`@State` 陣列）
  - 歷史紀錄檢視功能

### 1.2 現有資料結構
```swift
struct AnswerRecord: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
    let englishAnswer: String
    let type: MagicAnswerType
    let timestamp: Date
}
```

### 1.3 問題點
- ❌ 歷史紀錄僅存於記憶體，App 關閉後資料遺失
- ❌ 無用戶管理機制
- ❌ 無法追蹤不同用戶的使用記錄
- ❌ 缺乏資料持久化方案

---

## 二、SwiftData 整合方案評估

### 2.1 整體架構評估 ✅

根據 `SwiftData_How.md`、`SwiftData_1_AnswerTable.md`、`SwiftData_2_UserTable.md` 和 `SwiftData_3_ResultTable.md` 的規劃，整體方案**合理且完整**。

**優點**:
- ✅ 採用 SwiftData 原生框架，與 SwiftUI 整合度高
- ✅ 使用 `@Model` 宏，代碼簡潔
- ✅ 自動處理資料遷移
- ✅ 支援關聯式資料結構（FK/PK）

**建議改進點**:
- ⚠️ 需明確定義資料模型之間的關係
- ⚠️ 需考慮多用戶情境下的資料隔離
- ⚠️ 需增加錯誤處理機制

---

### 2.2 資料模型設計評估

#### 2.2.1 User 模型 ✅ (已實作)

**現有實作** (`User.swift`):
```swift
@Model
final class User {
    @Attribute(.unique) var id: UUID
    var name: String
    var birthday: Date
    var gender: Gender
    
    enum Gender: String, Codable, CaseIterable, Identifiable {
        case male = "男"
        case female = "女"
        case other = "其他"
    }
}
```

**評估結果**: ✅ **合理**
- ✅ 包含用戶基本資訊（姓名、生日、性別）
- ✅ 使用 UUID 作為主鍵
- ✅ 性別使用 enum，類型安全

**建議補充**:
- 📝 增加用戶建立時間 `createdAt: Date`
- 📝 增加用戶頭像或個人化設定
- 📝 考慮增加 `isActive: Bool` 標記當前活躍用戶

---

#### 2.2.2 AnswerRecord 模型 ⚠️ (需調整)

**文件中的設計方案**:
```swift
@Model
final class AnswerRecord {
    @Attribute(.unique) var id: UUID
    var question: String
    var answer: String
    var englishAnswer: String
    var typeRaw: Int // 或 String
    var timestamp: Date
    @Relationship var user: User?
}
```

**評估結果**: ⚠️ **基本合理，但需改進**

**問題點**:
1. ❌ `typeRaw` 使用 Int 或 String 不夠語義化
2. ❌ `user` 為可選型（`User?`），應明確業務邏輯（是否允許無主用戶的記錄）
3. ⚠️ 缺少與 User 的反向關聯設計

**建議改進**:
```swift
@Model
final class AnswerRecord {
    @Attribute(.unique) var id: UUID
    var question: String
    var answer: String
    var englishAnswer: String
    var answerType: String  // 改用 enum 的 rawValue
    var timestamp: Date
    
    // 明確關聯到 User，deleteRule 設定為 cascade
    @Relationship(deleteRule: .nullify) 
    var user: User
    
    init(question: String, answer: String, englishAnswer: String, 
         answerType: AnswerType, timestamp: Date = Date(), user: User) {
        self.id = UUID()
        self.question = question
        self.answer = answer
        self.englishAnswer = englishAnswer
        self.answerType = answerType.rawValue
        self.timestamp = timestamp
        self.user = user
    }
}

enum AnswerType: String, Codable {
    case affirmative = "affirmative"
    case neutral = "neutral"
    case negative = "negative"
}
```

---

#### 2.2.3 User-AnswerRecord 關聯 ✅ **【已決策】**

**✅ 採用方案**: **Cascade 刪除策略**

基於以下考量，本專案採用 `cascade` 刪除策略：
1. 🔒 **隱私保護**: 刪除用戶時應完全清除其個人資料
2. 📱 **個人裝置特性**: Magic 8 Ball 為個人使用 App，不涉及多人共享資料分析
3. 🧹 **資料一致性**: 避免產生無主記錄造成資料混亂

**標準實作**:
```swift
// User.swift
@Model
final class User {
    @Attribute(.unique) var id: UUID
    var name: String
    var birthday: Date
    var gender: Gender
    var createdAt: Date
    
    // ✅ 使用 cascade - 刪除用戶時連同刪除所有記錄
    @Relationship(deleteRule: .cascade, inverse: \AnswerRecord.user)
    var records: [AnswerRecord] = []
    
    init(name: String, birthday: Date, gender: Gender) {
        self.id = UUID()
        self.name = name
        self.birthday = birthday
        self.gender = gender
        self.createdAt = Date()
    }
}
```

```swift
// AnswerRecord.swift
@Model
final class AnswerRecord {
    @Attribute(.unique) var id: UUID
    var question: String
    var answer: String
    var englishAnswer: String
    var answerType: String
    var timestamp: Date
    
    // ✅ 非可選型 - 每筆記錄必須關聯到用戶
    @Relationship var user: User
    
    init(question: String, answer: String, englishAnswer: String, 
         answerType: AnswerType, user: User, timestamp: Date = Date()) {
        self.id = UUID()
        self.question = question
        self.answer = answer
        self.englishAnswer = englishAnswer
        self.answerType = answerType.rawValue
        self.user = user
        self.timestamp = timestamp
    }
}
```

**刪除用戶時的行為**:
```swift
// 當執行以下操作時：
modelContext.delete(user)
try modelContext.save()

// SwiftData 會自動：
// 1. 刪除 User 實例
// 2. 刪除所有 user.records 中的 AnswerRecord 實例
// 3. 確保資料庫一致性
```

---

### 2.3 App 入口整合 ✅ **【必須實作】**

**現有實作** (`magic_8_ballApp.swift`) - ❌ **不完整**:
```swift
import SwiftUI
import SwiftData

@main
struct magic_8_ballApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: User.self)  // ❌ 只註冊 User
        }
    }
}
```

**❌ 問題**:
- 只註冊了 `User.self`，未註冊 `AnswerRecord.self`
- SwiftData 需要明確註冊所有模型，否則關聯會失效
- 缺少錯誤處理機制

---

**✅ 標準實作 (必須採用)**:

```swift
import SwiftUI
import SwiftData

@main
struct magic_8_ballApp: App {
    // ✅ 建立共享的 ModelContainer，包含所有模型
    var sharedModelContainer: ModelContainer = {
        // 1. 定義 Schema - 必須註冊所有模型
        let schema = Schema([
            User.self,           // ✅ 用戶模型
            AnswerRecord.self    // ✅ 答案記錄模型
        ])
        
        // 2. 設定 ModelConfiguration
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,  // 持久化到磁碟
            allowsSave: true,              // 允許儲存
            cloudKitDatabase: .none        // 不使用 iCloud（可選）
        )
        
        // 3. 建立 ModelContainer 並處理錯誤
        do {
            let container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            print("✅ ModelContainer 建立成功")
            return container
        } catch {
            // ❌ 若 ModelContainer 建立失敗，應用程式無法正常運作
            fatalError("無法建立 ModelContainer: \(error.localizedDescription)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)  // ✅ 注入 ModelContainer
    }
}
```

---

**📋 ModelContainer 註冊檢查清單**:
- ✅ 必須在 Schema 中註冊 `User.self`
- ✅ 必須在 Schema 中註冊 `AnswerRecord.self`
- ✅ 必須使用 `do-catch` 處理初始化錯誤
- ✅ `isStoredInMemoryOnly: false` 確保資料持久化
- ✅ 建議加入 debug log 確認初始化成功

**⚠️ 常見錯誤**:
```swift
// ❌ 錯誤 1: 只註冊一個模型
.modelContainer(for: User.self)

// ❌ 錯誤 2: 遺漏關聯模型
let schema = Schema([User.self])  // 缺少 AnswerRecord

// ❌ 錯誤 3: 沒有錯誤處理
let container = try! ModelContainer(...)  // 強制 unwrap 不安全

// ✅ 正確: 註冊所有模型並處理錯誤
let schema = Schema([User.self, AnswerRecord.self])
do { ... } catch { ... }
```

---

### 2.4 ContentView 錯誤處理整合 ✅ **【必須實作】**

**現有問題**:
1. ❌ 未處理「無用戶」情況
2. ❌ 未處理 SwiftData 插入失敗的錯誤
3. ❌ 沒有向用戶顯示錯誤訊息

---

**✅ 標準實作 (含完整錯誤處理)**:

```swift
import SwiftUI
import SwiftData

struct ContentView: View {
    // MARK: - SwiftData 查詢
    @Query private var users: [User]
    @Query(sort: \AnswerRecord.timestamp, order: .reverse) 
    private var allRecords: [AnswerRecord]
    
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - 狀態管理
    @State private var question = ""
    @State private var currentAnswer = (MagicAnswerType.neutral, "", "")
    @State private var showAnswer = false
    @State private var showHistory = false
    @State private var showUserSelection = false
    
    // ✅ 錯誤處理狀態
    @State private var showError = false
    @State private var errorMessage = ""
    
    // 當前用戶管理
    @AppStorage("currentUserId") private var currentUserId: String = ""
    
    // MARK: - 計算屬性
    private var currentUser: User? {
        users.first { $0.id.uuidString == currentUserId }
    }
    
    private var currentUserRecords: [AnswerRecord] {
        guard let user = currentUser else { return [] }
        return allRecords.filter { $0.user.id == user.id }
    }
    
    // MARK: - 主要功能
    
    /// ✅ 取得答案並儲存到 SwiftData（含完整錯誤處理）
    private func getAnswer() {
        // 1️⃣ 驗證：確保有當前用戶
        guard let user = currentUser else {
            errorMessage = "請先選擇或建立用戶"
            showUserSelection = true
            return
        }
        
        // 2️⃣ 驗證：確保有輸入問題
        guard !question.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "請輸入問題"
            showError = true
            return
        }
        
        // 隱藏答案（動畫效果）
        withAnimation(.easeOut(duration: 0.5)) {
            showAnswer = false
        }
        
        // 延遲顯示答案
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            // 3️⃣ 選擇隨機答案
            guard let selectedAnswer = answers.randomElement() else {
                errorMessage = "答案資料錯誤"
                showError = true
                return
            }
            
            currentAnswer = selectedAnswer
            
            // 4️⃣ 儲存到 SwiftData（含完整錯誤處理）
            saveAnswerRecord(user: user, answer: selectedAnswer)
            
            // 顯示答案（動畫效果）
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showAnswer = true
            }
        }
    }
    
    /// ✅ 儲存答案記錄（完整錯誤處理）
    private func saveAnswerRecord(user: User, answer: (MagicAnswerType, String, String)) {
        do {
            // 建立記錄
            let record = AnswerRecord(
                question: question,
                answer: answer.1,
                englishAnswer: answer.2,
                answerType: AnswerType(from: answer.0),
                user: user
            )
            
            // 插入資料
            modelContext.insert(record)
            
            // ✅ 嘗試儲存並處理錯誤
            try modelContext.save()
            
            print("✅ 答案記錄已儲存: \(record.id)")
            
        } catch let error as NSError {
            // ❌ 處理不同類型的錯誤
            handleSaveError(error)
        }
    }
    
    /// ✅ 錯誤處理函式
    private func handleSaveError(_ error: NSError) {
        print("❌ SwiftData 儲存失敗: \(error)")
        
        // 根據錯誤類型顯示不同訊息
        switch error.code {
        case NSPersistentStoreCoordinatorError:
            errorMessage = "資料庫連接失敗"
        case NSValidationError:
            errorMessage = "資料驗證失敗"
        case NSManagedObjectConstraintError:
            errorMessage = "資料重複或約束違反"
        default:
            errorMessage = "儲存失敗: \(error.localizedDescription)"
        }
        
        showError = true
        
        // 可選：嘗試回滾變更
        modelContext.rollback()
    }
    
    /// ✅ 刪除用戶（含 cascade 刪除確認）
    private func deleteUser(_ user: User) {
        let recordCount = user.records.count
        
        do {
            // ⚠️ cascade 刪除會同時刪除所有相關記錄
            modelContext.delete(user)
            try modelContext.save()
            
            print("✅ 已刪除用戶及其 \(recordCount) 筆記錄")
            
            // 清除當前用戶 ID
            if currentUserId == user.id.uuidString {
                currentUserId = ""
            }
            
        } catch {
            errorMessage = "刪除用戶失敗: \(error.localizedDescription)"
            showError = true
        }
    }
    
    // MARK: - UI Body
    var body: some View {
        // ... UI 程式碼 ...
        .alert("錯誤", isPresented: $showError) {
            Button("確定", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
}

// MARK: - 答案類型轉換
extension AnswerType {
    init(from magicType: ContentView.MagicAnswerType) {
        switch magicType {
        case .affirmative: self = .affirmative
        case .neutral: self = .neutral
        case .negative: self = .negative
        }
    }
}
```

---

**📋 錯誤處理檢查清單**:
- ✅ 所有 `modelContext.save()` 必須包在 `do-catch` 中
- ✅ 所有 `modelContext.insert()` 後必須呼叫 `save()`
- ✅ 錯誤訊息必須顯示給用戶（Alert 或 Toast）
- ✅ 記錄錯誤到 Console（使用 `print` 或 Logger）
- ✅ 關鍵操作前先驗證資料（如 user 是否存在）
- ✅ 儲存失敗時考慮 `rollback()` 回滾變更

---

**⚠️ 常見錯誤寫法**:
```swift
// ❌ 錯誤 1: 沒有錯誤處理
modelContext.insert(record)
try! modelContext.save()  // 強制 unwrap，App 會閃退

// ❌ 錯誤 2: 忽略錯誤
try? modelContext.save()  // 靜默失敗，用戶不知道儲存失敗

// ❌ 錯誤 3: 不完整的錯誤處理
do {
    try modelContext.save()
} catch {
    print(error)  // 只印出來，沒有通知用戶
}

// ✅ 正確: 完整錯誤處理
do {
    modelContext.insert(record)
    try modelContext.save()
    print("✅ 儲存成功")
} catch {
    errorMessage = "儲存失敗: \(error.localizedDescription)"
    showError = true
    modelContext.rollback()
}
```

---

## 三、整合實作步驟 **【必須依序執行】**

### 階段 1: 資料模型建立 (🔴 高優先級 - 必須完成)

#### 1. ✅ **User.swift** - 修改現有檔案
**必須實作項目**:
```swift
@Model
final class User {
    @Attribute(.unique) var id: UUID
    var name: String
    var birthday: Date
    var gender: Gender
    var createdAt: Date  // ✅ 新增：建立時間
    
    // ✅ 必須：使用 cascade 刪除策略
    @Relationship(deleteRule: .cascade, inverse: \AnswerRecord.user)
    var records: [AnswerRecord] = []
    
    enum Gender: String, Codable, CaseIterable, Identifiable {
        case male = "男"
        case female = "女"
        case other = "其他"
        var id: String { rawValue }
    }
}
```

#### 2. 📝 **AnswerRecord.swift** - 新建檔案
**必須實作項目**:
```swift
import Foundation
import SwiftData

@Model
final class AnswerRecord {
    @Attribute(.unique) var id: UUID
    var question: String
    var answer: String
    var englishAnswer: String
    var answerType: String  // 儲存 enum rawValue
    var timestamp: Date
    
    // ✅ 必須：非可選型，每筆記錄必須關聯用戶
    @Relationship var user: User
    
    init(question: String, answer: String, englishAnswer: String, 
         answerType: AnswerType, user: User, timestamp: Date = Date()) {
        self.id = UUID()
        self.question = question
        self.answer = answer
        self.englishAnswer = englishAnswer
        self.answerType = answerType.rawValue
        self.user = user
        self.timestamp = timestamp
    }
}
```

#### 3. 📝 **AnswerType.swift** - 新建檔案
**必須實作項目**:
```swift
import Foundation

enum AnswerType: String, Codable, CaseIterable {
    case affirmative = "affirmative"
    case neutral = "neutral"
    case negative = "negative"
}
```

---

### 階段 2: App 入口整合 (🔴 高優先級 - 必須完成)

#### 4. ⚠️ **magic_8_ballApp.swift** - 修改現有檔案
**✅ 必須實作項目** (不可省略):

```swift
import SwiftUI
import SwiftData

@main
struct magic_8_ballApp: App {
    // ✅ 必須：建立包含所有模型的 ModelContainer
    var sharedModelContainer: ModelContainer = {
        // ✅ 必須：註冊所有模型
        let schema = Schema([
            User.self,           // ← 必須註冊
            AnswerRecord.self    // ← 必須註冊
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        // ✅ 必須：使用 do-catch 錯誤處理
        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            // ✅ 必須：記錄錯誤訊息
            fatalError("無法建立 ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
```

**📋 階段 2 檢查清單**:
- [ ] Schema 包含 `User.self`
- [ ] Schema 包含 `AnswerRecord.self`
- [ ] 使用 `do-catch` 處理初始化錯誤
- [ ] 設定 `isStoredInMemoryOnly: false`
- [ ] 將 `sharedModelContainer` 注入到 WindowGroup

### 階段 3: UI 整合與錯誤處理 (🟡 中優先級 - 重要)

#### 5. 📝 **ContentView.swift** - 大幅修改現有檔案
**✅ 必須實作的錯誤處理**:

**5.1 資料查詢**:
```swift
// ✅ 使用 @Query 取代 @State 陣列
@Query private var users: [User]
@Query(sort: \AnswerRecord.timestamp, order: .reverse) 
private var allRecords: [AnswerRecord]

@Environment(\.modelContext) private var modelContext
```

**5.2 錯誤處理狀態**:
```swift
// ✅ 必須：錯誤處理狀態
@State private var showError = false
@State private var errorMessage = ""
```

**5.3 儲存記錄（完整錯誤處理）**:
```swift
private func saveAnswerRecord(user: User, answer: (type, text, english)) {
    do {
        // ✅ 建立記錄
        let record = AnswerRecord(
            question: question,
            answer: answer.text,
            englishAnswer: answer.english,
            answerType: AnswerType(from: answer.type),
            user: user
        )
        
        // ✅ 插入並儲存
        modelContext.insert(record)
        try modelContext.save()  // ← 必須用 try，不可用 try!
        
        print("✅ 儲存成功")
        
    } catch {
        // ✅ 必須：處理錯誤
        errorMessage = "儲存失敗: \(error.localizedDescription)"
        showError = true
        modelContext.rollback()  // ← 建議：回滾變更
    }
}
```

**5.4 刪除用戶（cascade 確認）**:
```swift
private func deleteUser(_ user: User) {
    // ⚠️ 提醒：cascade 會刪除所有相關記錄
    let recordCount = user.records.count
    
    do {
        modelContext.delete(user)  // ← 會觸發 cascade
        try modelContext.save()
        
        print("✅ 已刪除用戶及 \(recordCount) 筆記錄")
        
    } catch {
        errorMessage = "刪除失敗: \(error.localizedDescription)"
        showError = true
    }
}
```

**5.5 錯誤提示 UI**:
```swift
var body: some View {
    // ... 主要 UI ...
    .alert("錯誤", isPresented: $showError) {
        Button("確定", role: .cancel) { }
    } message: {
        Text(errorMessage)
    }
}
```

**📋 階段 3 檢查清單**:
- [ ] 移除 `@State private var answerHistory: [AnswerRecord]`
- [ ] 使用 `@Query` 查詢資料
- [ ] 所有 `save()` 包在 `do-catch` 中
- [ ] 錯誤訊息顯示給用戶（Alert）
- [ ] 關鍵操作前驗證資料
- [ ] 刪除用戶前提示會同時刪除記錄

---

#### 6. 📝 **HistoryView** - 修改現有元件
**必須修改項目**:
```swift
struct HistoryView: View {
    let currentUser: User?
    
    @Query(sort: \AnswerRecord.timestamp, order: .reverse)
    private var allRecords: [AnswerRecord]
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    // ✅ 過濾當前用戶的記錄
    private var userRecords: [AnswerRecord] {
        guard let user = currentUser else { return [] }
        return allRecords.filter { $0.user.id == user.id }
    }
    
    // ✅ 刪除記錄（含錯誤處理）
    private func deleteRecord(_ record: AnswerRecord) {
        do {
            modelContext.delete(record)
            try modelContext.save()
        } catch {
            // 顯示錯誤
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(userRecords) { record in
                    // 顯示記錄
                }
                .onDelete { indexSet in
                    // 處理刪除
                }
            }
        }
    }
}
```

### 階段 4: 用戶管理 (🟡 中優先級 - 簡化版)

> **注意**: 由於採用單一用戶模式，用戶管理功能大幅簡化

#### 7. 📝 **UserCreationView.swift** - 新建檔案
**✅ 單一用戶版本實作**:

```swift
import SwiftUI
import SwiftData

struct UserCreationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @Query private var users: [User]
    @Binding var currentUserId: String
    
    // 表單欄位
    @State private var name: String = ""
    @State private var birthday: Date = Date()
    @State private var gender: User.Gender = .male
    
    // 錯誤處理
    @State private var showError = false
    @State private var errorMessage = ""
    
    var isFirstUser: Bool {
        users.isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("姓名", text: $name)
                    DatePicker("生日", selection: $birthday, displayedComponents: .date)
                    Picker("性別", selection: $gender) {
                        ForEach(User.Gender.allCases) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                } header: {
                    Text("用戶資料")
                } footer: {
                    if isFirstUser {
                        Text("建立您的個人檔案以開始使用 Magic 8 Ball")
                    }
                }
                
                Section {
                    Button("建立用戶") {
                        createUser()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .navigationTitle(isFirstUser ? "建立用戶" : "替換用戶")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !isFirstUser {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("取消") {
                            dismiss()
                        }
                    }
                }
            }
            .alert("錯誤", isPresented: $showError) {
                Button("確定", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
        .interactiveDismissDisabled(isFirstUser)  // 首次使用不可關閉
    }
    
    /// ✅ 建立用戶（單一用戶模式）
    private func createUser() {
        do {
            let newUser = User(
                name: name.trimmingCharacters(in: .whitespaces),
                birthday: birthday,
                gender: gender
            )
            
            modelContext.insert(newUser)
            try modelContext.save()
            
            // ✅ 自動選擇為當前用戶（也是唯一用戶）
            currentUserId = newUser.id.uuidString
            
            print("✅ 用戶已建立: \(newUser.name)")
            dismiss()
            
        } catch {
            errorMessage = "建立用戶失敗: \(error.localizedDescription)"
            showError = true
        }
    }
}
```

---

#### 8. 📝 **UserProfileView.swift** - 新建檔案
**✅ 單一用戶資料管理**:

```swift
import SwiftUI
import SwiftData

struct UserProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    
    @Binding var currentUserId: String
    
    @State private var showUserCreation = false
    @State private var showReplaceConfirmation = false
    @State private var showEditSheet = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var currentUser: User? {
        users.first { $0.id.uuidString == currentUserId }
    }
    
    var body: some View {
        NavigationView {
            List {
                if let user = currentUser {
                    // 用戶資訊區
                    Section {
                        HStack {
                            Text("姓名")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(user.name)
                        }
                        
                        HStack {
                            Text("生日")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(user.birthday, style: .date)
                        }
                        
                        HStack {
                            Text("性別")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(user.gender.rawValue)
                        }
                    } header: {
                        Text("個人資料")
                    }
                    
                    // 統計資訊
                    Section {
                        HStack {
                            Text("問答記錄")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(user.records.count) 筆")
                                .foregroundColor(.blue)
                        }
                        
                        HStack {
                            Text("建立時間")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(user.createdAt, style: .date)
                        }
                    } header: {
                        Text("使用統計")
                    }
                    
                    // 操作區
                    Section {
                        Button("編輯資料") {
                            showEditSheet = true
                        }
                        
                        Button("替換用戶", role: .destructive) {
                            showReplaceConfirmation = true
                        }
                    }
                    
                } else {
                    // 無用戶狀態
                    Section {
                        VStack(spacing: 16) {
                            Image(systemName: "person.crop.circle.badge.plus")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("尚未建立用戶")
                                .font(.headline)
                            
                            Text("請建立用戶以開始使用")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Button("建立用戶") {
                                showUserCreation = true
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 32)
                    }
                }
            }
            .navigationTitle("用戶資料")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showUserCreation) {
                UserCreationView(currentUserId: $currentUserId)
            }
            .sheet(isPresented: $showEditSheet) {
                if let user = currentUser {
                    UserEditView(user: user)
                }
            }
            .alert("替換用戶", isPresented: $showReplaceConfirmation) {
                Button("取消", role: .cancel) { }
                Button("清除並重建", role: .destructive) {
                    replaceUser()
                }
            } message: {
                if let user = currentUser {
                    Text("系統僅支援 1 位用戶。\n\n目前用戶：\(user.name)\n共有 \(user.records.count) 筆記錄\n\n確定要刪除現有用戶並建立新用戶嗎？\n此操作無法復原。")
                }
            }
            .alert("錯誤", isPresented: $showError) {
                Button("確定", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    /// ✅ 替換用戶（刪除舊用戶並顯示建立畫面）
    private func replaceUser() {
        guard let user = currentUser else { return }
        
        do {
            // 刪除現有用戶（cascade 會刪除所有記錄）
            modelContext.delete(user)
            try modelContext.save()
            
            // 清空當前用戶 ID
            currentUserId = ""
            
            // 顯示建立用戶畫面
            showUserCreation = true
            
            print("✅ 已刪除用戶，準備建立新用戶")
            
        } catch {
            errorMessage = "刪除用戶失敗: \(error.localizedDescription)"
            showError = true
        }
    }
}

/// 用戶編輯視圖
struct UserEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    let user: User
    
    @State private var name: String
    @State private var birthday: Date
    @State private var gender: User.Gender
    
    @State private var showError = false
    @State private var errorMessage = ""
    
    init(user: User) {
        self.user = user
        _name = State(initialValue: user.name)
        _birthday = State(initialValue: user.birthday)
        _gender = State(initialValue: user.gender)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("姓名", text: $name)
                    DatePicker("生日", selection: $birthday, displayedComponents: .date)
                    Picker("性別", selection: $gender) {
                        ForEach(User.Gender.allCases) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                } header: {
                    Text("編輯資料")
                }
            }
            .navigationTitle("編輯用戶")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("儲存") {
                        saveChanges()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .alert("錯誤", isPresented: $showError) {
                Button("確定", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    /// ✅ 儲存變更
    private func saveChanges() {
        do {
            user.name = name.trimmingCharacters(in: .whitespaces)
            user.birthday = birthday
            user.gender = gender
            
            try modelContext.save()
            
            print("✅ 用戶資料已更新: \(user.name)")
            dismiss()
            
        } catch {
            errorMessage = "儲存失敗: \(error.localizedDescription)"
            showError = true
        }
    }
}
```

**📋 階段 4 檢查清單（簡化版）**:
- [ ] 實作 UserCreationView（建立用戶）
- [ ] 實作 UserProfileView（用戶資料顯示與管理）
- [ ] 實作 UserEditView（編輯用戶資料）
- [ ] 首次啟動強制建立用戶
- [ ] 建立用戶後自動選擇（也是唯一用戶）
- [ ] 限制只能有 1 個用戶
- [ ] 提供「替換用戶」功能（刪除舊用戶+建立新用戶）
- [ ] 顯示用戶資料和統計資訊
- [ ] 替換用戶時顯示記錄數量確認

### 階段 5: 進階功能 (低優先級)

9. 📝 **資料統計功能**:
   - 每個用戶的使用次數
   - 答案類型分布
   - 使用時間分析

10. 📝 **資料匯出/匯入**:
    - JSON 格式匯出
    - iCloud 同步（選用）

---

## 四、風險與注意事項

### 4.1 技術風險

| 風險項目 | 影響程度 | 應對措施 |
|---------|---------|---------|
| SwiftData 版本相容性 | 中 | 明確設定最低 iOS 17.0 |
| 資料遷移問題 | 高 | 實作版本化 Schema |
| 關聯資料刪除邏輯 | 高 | 明確定義 deleteRule |
| 多用戶並發存取 | 低 | SwiftData 自動處理 |
| 儲存空間限制 | 低 | 實作舊資料清理機制 |

### 4.2 業務邏輯決策 ✅ **【已確認】**

#### 決策 1: 是否允許「匿名使用」？ ✅

**✅ 採用方案**: **強制建立用戶，建立後自動選擇**

**實作規格**:
1. **首次啟動流程**:
   - App 啟動時檢查是否有用戶
   - 若無任何用戶，強制顯示「建立用戶」畫面
   - 不可跳過，必須建立至少一個用戶才能使用

2. **建立用戶後自動選擇**:
   ```swift
   // 建立用戶後自動設為當前用戶
   func createUser(name: String, birthday: Date, gender: User.Gender) {
       do {
           let newUser = User(name: name, birthday: birthday, gender: gender)
           modelContext.insert(newUser)
           try modelContext.save()
           
           // ✅ 自動選擇為當前用戶
           currentUserId = newUser.id.uuidString
           print("✅ 用戶已建立並自動選擇: \(newUser.name)")
           
       } catch {
           errorMessage = "建立用戶失敗: \(error.localizedDescription)"
           showError = true
       }
   }
   ```

3. **問答前驗證**:
   ```swift
   private func getAnswer() {
       // ✅ 確保有當前用戶
       guard let user = currentUser else {
           errorMessage = "請先建立或選擇用戶"
           showUserCreation = true  // 顯示建立用戶畫面
           return
       }
       // ... 繼續問答流程
   }
   ```

**理由**:
- ✅ 符合用戶追蹤需求，確保每筆記錄都有關聯
- ✅ 簡化用戶體驗，建立後自動使用
- ✅ 避免無主記錄的產生
- ✅ 便於實作多用戶切換功能

**UI/UX 要求**:
- 首次啟動必須顯示歡迎畫面 + 建立用戶表單
- 建立成功後自動跳轉到主畫面
- 主畫面顯示當前用戶名稱
- 提供用戶切換按鈕（導航列或設定頁）

---

#### 決策 2: 刪除用戶時，是否保留歷史記錄？ ✅

**✅ 採用方案**: **連同刪除所有記錄 (cascade)**

**理由**: 
- 🔒 保護用戶隱私
- 📱 個人裝置使用情境
- 🧹 避免產生無主記錄

**UI 要求**: 
刪除前必須顯示確認對話框，告知會同時刪除 N 筆記錄

```swift
.alert("確認刪除", isPresented: $showDeleteConfirmation) {
    Button("取消", role: .cancel) { }
    Button("刪除", role: .destructive) {
        deleteUser(userToDelete)
    }
} message: {
    Text("確定要刪除「\(userToDelete.name)」嗎？\n這將同時刪除該用戶的 \(userToDelete.records.count) 筆問答記錄，此操作無法復原。")
}
```

---

#### 決策 3: 是否限制用戶數量？ ✅

**✅ 採用方案**: **限制僅 1 個用戶，提供清理重建功能**

**實作規格**:
1. **單一用戶模式**: 系統只允許存在 **1 個用戶**
   ```swift
   private let maxUserCount = 1  // ✅ 固定為 1
   
   var canCreateUser: Bool {
       return users.count < maxUserCount
   }
   ```

2. **首次啟動流程**:
   - App 啟動時檢查用戶數量
   - 若無用戶（`users.isEmpty`），自動顯示建立用戶畫面
   - 建立完成後作為唯一用戶使用

3. **已有用戶時的處理**:
   ```swift
   func createNewUser() {
       // ✅ 檢查是否已有用戶
       if let existingUser = users.first {
           // 顯示替換用戶確認對話框
           showReplaceUserConfirmation = true
           return
       }
       
       // 顯示建立用戶畫面
       showUserCreation = true
   }
   ```

4. **替換用戶功能**（清理重建）:
   - 當已有用戶時，提供「替換用戶」功能
   - 必須先刪除現有用戶（連同所有記錄）
   - 然後建立新用戶
   
   ```swift
   /// ✅ 替換用戶（刪除舊用戶並建立新用戶）
   func replaceUser(
       oldUser: User,
       newName: String,
       newBirthday: Date,
       newGender: User.Gender
   ) {
       do {
           // 1. 刪除舊用戶（cascade 會刪除所有記錄）
           modelContext.delete(oldUser)
           try modelContext.save()
           
           // 2. 建立新用戶
           let newUser = User(
               name: newName,
               birthday: newBirthday,
               gender: newGender
           )
           modelContext.insert(newUser)
           try modelContext.save()
           
           // 3. 自動設為當前用戶
           currentUserId = newUser.id.uuidString
           
           print("✅ 用戶已替換: \(oldUser.name) → \(newUser.name)")
           
       } catch {
           errorMessage = "替換用戶失敗: \(error.localizedDescription)"
           showError = true
       }
   }
   ```

5. **清理重建確認對話框**:
   ```swift
   .alert("替換用戶", isPresented: $showReplaceUserConfirmation) {
       Button("取消", role: .cancel) { }
       Button("清除並重建", role: .destructive) {
           if let user = users.first {
               deleteUserAndShowCreation(user)
           }
       }
   } message: {
       if let user = users.first {
           Text("系統僅支援 1 位用戶。\n\n目前用戶：\(user.name)\n共有 \(user.records.count) 筆記錄\n\n確定要刪除現有用戶並建立新用戶嗎？\n此操作無法復原。")
       }
   }
   
   /// 刪除用戶並顯示建立畫面
   private func deleteUserAndShowCreation(_ user: User) {
       do {
           modelContext.delete(user)
           try modelContext.save()
           showUserCreation = true
       } catch {
           errorMessage = "刪除用戶失敗: \(error.localizedDescription)"
           showError = true
       }
   }
   ```

6. **UI 簡化**:
   由於只有單一用戶，可簡化 UI：
   - ❌ **不需要**：用戶列表選擇功能
   - ❌ **不需要**：用戶切換功能
   - ❌ **不需要**：批次清理功能
   - ✅ **需要**：顯示當前用戶資訊
   - ✅ **需要**：「替換用戶」按鈕（設定中）
   - ✅ **需要**：編輯用戶資料功能

**理由**:
- 🎯 **極簡設計**: Magic 8 Ball 為個人專屬占卜工具，單一用戶最符合使用情境
- 🚀 **效能最佳**: 無需多用戶切換邏輯，查詢效率最高
- 🧹 **管理簡單**: 不需複雜的用戶管理介面
- 💾 **資料精簡**: 避免多用戶資料累積，保持資料庫輕量
- 👤 **個人化**: 強化個人專屬體驗，所有記錄都屬於同一個用戶

**適用情境**:
- ✅ 個人使用的占卜 App
- ✅ 單一裝置單一使用者
- ✅ 重視簡潔體驗
- ❌ 不適合家庭共用情境（若需要可調整為多用戶）

**建議的 UI 呈現**:
```
設定頁面：
┌─────────────────────┐
│ 👤 用戶資訊          │
│                     │
│ 姓名：張三           │
│ 生日：1990/01/01    │
│ 性別：男            │
│ 記錄數：42 筆        │
│                     │
│ [編輯資料]  [替換用戶] │
└─────────────────────┘
```

---

### 4.3 錯誤處理策略 ✅ **【核心需求】**

#### 4.3.1 SwiftData 操作錯誤處理規範

**🔴 Level 1: 關鍵錯誤（必須 fatalError）**
```swift
// ModelContainer 初始化失敗
do {
    return try ModelContainer(...)
} catch {
    fatalError("無法建立 ModelContainer: \(error)")
}
```

**🟡 Level 2: 重要錯誤（必須顯示 Alert）**
```swift
// 資料儲存失敗
do {
    try modelContext.save()
} catch {
    errorMessage = "儲存失敗: \(error.localizedDescription)"
    showError = true
    modelContext.rollback()
}
```

**🟢 Level 3: 一般錯誤（記錄 Log）**
```swift
// 資料查詢失敗
do {
    let records = try modelContext.fetch(descriptor)
} catch {
    print("⚠️ 查詢失敗: \(error)")
    return []
}
```

#### 4.3.2 必須實作的錯誤處理點

| 操作 | 錯誤處理方式 | 是否必須 |
|-----|------------|---------|
| ModelContainer 初始化 | fatalError | ✅ 必須 |
| modelContext.save() | do-catch + Alert | ✅ 必須 |
| modelContext.insert() | 配合 save() 處理 | ✅ 必須 |
| modelContext.delete() | do-catch + Alert | ✅ 必須 |
| @Query 自動查詢 | 自動處理 | ⚪ 不需要 |
| 手動 fetch() | do-catch + 返回空陣列 | 🟡 建議 |

#### 4.3.3 錯誤訊息使用者友善化

```swift
// ❌ 不友善：直接顯示技術錯誤
errorMessage = error.localizedDescription

// ✅ 友善：根據錯誤類型顯示易懂訊息
private func handleSaveError(_ error: NSError) {
    switch error.code {
    case NSPersistentStoreCoordinatorError:
        errorMessage = "資料庫連接失敗，請重新啟動 App"
    case NSValidationError:
        errorMessage = "資料格式錯誤，請檢查輸入"
    case NSManagedObjectConstraintError:
        errorMessage = "資料重複，請重新輸入"
    default:
        errorMessage = "儲存失敗，請稍後再試"
    }
    showError = true
}
```

#### 4.3.4 錯誤處理最佳實踐

✅ **必須做到**:
1. 所有 `try` 都使用 `do-catch`，禁止使用 `try!`
2. 錯誤訊息必須顯示給用戶（Alert、Toast 或 Banner）
3. 關鍵錯誤記錄到 Console（使用 `print` 或 `Logger`）
4. 儲存失敗後考慮 `modelContext.rollback()`

❌ **禁止做法**:
1. 使用 `try!` 強制 unwrap（會導致 App 閃退）
2. 使用 `try?` 靜默失敗（用戶不知道操作失敗）
3. 只用 `print` 不顯示給用戶（用戶無感知）
4. 忽略錯誤繼續執行（資料不一致）

---

## 五、測試計畫

### 5.1 單元測試
- [ ] User 模型建立與查詢
- [ ] AnswerRecord 模型建立與查詢
- [ ] User-AnswerRecord 關聯正確性
- [ ] deleteRule 行為驗證

### 5.2 整合測試
- [ ] 新增用戶後可正常記錄問答
- [ ] 切換用戶後顯示正確的歷史記錄
- [ ] 刪除用戶後相關記錄處理正確
- [ ] App 重啟後資料持久化正確

### 5.3 UI 測試
- [ ] 用戶選擇流程順暢
- [ ] 歷史記錄正確顯示
- [ ] 刪除操作有確認提示
- [ ] 錯誤訊息正確顯示

---

## 六、效能考量

### 6.1 查詢優化
```swift
// ❌ 不推薦：查詢所有記錄後過濾
@Query private var allRecords: [AnswerRecord]
let userRecords = allRecords.filter { $0.user?.id == currentUser.id }

// ✅ 推薦：使用 predicate 直接過濾
@Query(filter: #Predicate<AnswerRecord> { record in
    record.user?.id == currentUserId
})
private var userRecords: [AnswerRecord]
```

### 6.2 批次操作
- 大量資料插入時使用 transaction
- 避免在主執行緒進行複雜查詢

### 6.3 資料清理
```swift
// 建議實作：清理 90 天前的舊記錄
func cleanOldRecords() {
    let calendar = Calendar.current
    let ninetyDaysAgo = calendar.date(byAdding: .day, value: -90, to: Date())!
    
    let predicate = #Predicate<AnswerRecord> { record in
        record.timestamp < ninetyDaysAgo
    }
    
    try? modelContext.delete(model: AnswerRecord.self, where: predicate)
}
```

---

## 七、文件與規範

### 7.1 代碼規範 ✅ **【強制執行】**

#### 7.1.1 SwiftData 模型規範
```swift
// ✅ 必須：使用 final class
@Model
final class User { ... }

// ✅ 必須：關聯屬性明確標註 deleteRule
@Relationship(deleteRule: .cascade, inverse: \AnswerRecord.user)
var records: [AnswerRecord] = []

// ✅ 必須：UUID 標記為 unique
@Attribute(.unique) var id: UUID

// ✅ 必須：提供完整的 init
init(...) { ... }
```

#### 7.1.2 錯誤處理規範
```swift
// ✅ 必須：使用 do-catch
do {
    try modelContext.save()
} catch {
    // 處理錯誤
}

// ❌ 禁止：使用 try!
try! modelContext.save()  // 會閃退

// ❌ 禁止：使用 try?（除非明確不需要錯誤訊息）
try? modelContext.save()  // 靜默失敗
```

#### 7.1.3 文件註解規範
```swift
/// 儲存答案記錄到 SwiftData
/// - Parameters:
///   - user: 當前用戶
///   - answer: 答案內容
/// - Throws: 當儲存失敗時拋出錯誤
/// - Note: 使用 do-catch 捕獲錯誤並顯示給用戶
private func saveAnswerRecord(user: User, answer: Answer) throws {
    // ...
}
```

### 7.2 命名規範
- 模型檔案: `ModelName.swift`
- 視圖檔案: `ViewNameView.swift`
- 變數使用 camelCase
- 類型使用 PascalCase

---

## 八、總結與建議

### 8.1 規劃評估總結

**整體評價**: ⭐⭐⭐⭐ (4/5 星)

現有的 SwiftData 整合規劃**總體合理且可行**，但在以下方面需要補充和改進:

✅ **做得好的地方**:
- 正確使用 SwiftData 框架
- 資料模型設計符合業務需求
- 考慮了 User-AnswerRecord 關聯

⚠️ **需要改進的地方**:
- ModelContainer 註冊不完整
- 缺少錯誤處理機制
- deleteRule 需根據業務邏輯明確定義
- 缺少用戶管理 UI
- 缺少資料遷移計畫

### 8.2 實作優先順序（標準 MVP）

**階段一：基礎實作**
1. ✅ 完善 User 和 AnswerRecord 模型定義
2. ✅ 修正 App 入口的 ModelContainer 設定
3. ✅ 實作基本的 CRUD 操作
4. ✅ 實作自動建立預設用戶
5. ✅ 基本儲存功能測試

**階段二：UI 和錯誤處理**
6. ✅ 實作 DatabaseErrorView（容錯處理）
7. ✅ 實作 UserCreationView（首次引導）
8. ✅ 修正用戶識別邏輯（動態查詢）
9. ✅ 完善錯誤處理（所有 SwiftData 操作）
10. ✅ 基本 UI/UX 測試

**延後實作（非 MVP 範圍）**
- UserProfileView（顯示用戶資料）
- 用戶替換功能（清理重建）
- 資料統計功能
- 資料匯出功能
- 效能優化（fetchLimit、分頁）
- 並發安全（@MainActor）
- 單元測試和 UI 測試

### 8.3 實作檢查清單 ✅（標準 MVP）

#### 階段一：基礎實作

**步驟 1: 資料模型**
- [ ] User.swift 增加 `createdAt` 和 `@Relationship`
- [ ] User.swift 包含完整欄位（name, birthday, gender）
- [ ] 建立 AnswerRecord.swift 檔案
- [ ] 建立 AnswerType.swift 檔案
- [ ] 驗證：可編譯無錯誤

**步驟 2: ModelContainer 註冊**
- [ ] Schema 包含 User.self
- [ ] Schema 包含 AnswerRecord.self
- [ ] 使用 do-catch 錯誤處理
- [ ] 初始化失敗返回 nil 而非 fatalError
- [ ] 驗證：App 啟動時 Console 顯示「✅ ModelContainer 建立成功」

**步驟 3: SwiftData 整合**
- [ ] ContentView 改用 @Query 查詢記錄
- [ ] 實作 saveAnswer() 函數（包含 do-catch）
- [ ] 實作 currentUser 動態查詢邏輯
- [ ] 首次啟動自動建立預設用戶
- [ ] 驗證：可新增記錄並持久化

**步驟 4: 基本測試**
- [ ] 新增記錄後重啟 App，資料仍存在
- [ ] 刪除用戶後，相關記錄全部消失（cascade）
- [ ] 無明顯 bug 或閃退
- [ ] 驗證：資料持久化正常運作

#### 階段二：UI 和錯誤處理

**步驟 5: 錯誤處理 UI**
- [ ] 實作 DatabaseErrorView
- [ ] App 啟動時根據 container 狀態顯示對應畫面
- [ ] 測試：模擬初始化失敗情境
- [ ] 驗證：顯示錯誤畫面而非閃退

**步驟 6: 用戶建立 UI**
- [ ] 實作 UserCreationView
- [ ] 包含 name、birthday、gender 輸入欄位
- [ ] 簡單表單驗證（name 不為空）
- [ ] 建立用戶後自動選擇為當前用戶
- [ ] 驗證：首次啟動引導建立用戶

**步驟 7: 動態查詢和錯誤處理**
- [ ] 修正 currentUser 為動態查詢（users.first）
- [ ] 所有 save() 操作使用 do-catch
- [ ] 錯誤訊息顯示 Alert
- [ ] 驗證：@AppStorage 清空後仍可識別用戶

**步驟 8: 完整測試**
- [ ] 首次啟動流程測試（無用戶 → 建立用戶）
- [ ] 重新安裝 App 後測試用戶建立
- [ ] 儲存失敗時顯示錯誤訊息
- [ ] 所有 SwiftData 操作有錯誤處理
- [ ] 基本 UI/UX 測試

#### 標準 MVP 交付標準
- [ ] ✅ ModelContainer 初始化失敗顯示錯誤畫面
- [ ] ✅ 首次啟動引導建立用戶
- [ ] ✅ 用戶識別穩定，重裝 App 後正常
- [ ] ✅ 所有 SwiftData 操作有錯誤處理
- [ ] ✅ 問答記錄可儲存並持久化
- [ ] ✅ 重啟 App 後歷史記錄仍存在
- [ ] ✅ 無明顯 bug 或閃退

---

### 8.4 後續行動（標準 MVP）

**階段一行動**:
1. 按照「三、整合實作步驟」實作資料模型
2. 設定 ModelContainer（包含容錯處理）
3. ContentView 整合 @Query 和基本儲存
4. 實作自動建立預設用戶邏輯
5. 完成階段一檢查清單驗證

**階段二行動**:
1. 實作 DatabaseErrorView 和 UserCreationView
2. 修正用戶識別邏輯（動態查詢）
3. 完善所有 SwiftData 操作的錯誤處理
4. 執行完整 UI/UX 測試
5. 完成標準 MVP 交付標準驗證

**Post-MVP 規劃**:
- 根據使用反饋決定是否實作 UserProfileView
- 評估是否需要效能優化
- 考慮增加單元測試和 UI 測試

**技術支援**:
- SwiftData 錯誤處理參考「4.3 錯誤處理策略」
- 代碼規範參考「7.1 代碼規範」
- MVP 策略參考 `SwiftData_MVP_Strategy.md` 文件

---

## 附錄

### A. 相關檔案清單
- ✅ `SwiftData_How.md` - 整體規劃
- ✅ `SwiftData_1_AnswerTable.md` - Answer 資料表設計
- ✅ `SwiftData_2_UserTable.md` - User 資料表設計
- ✅ `SwiftData_3_ResultTable.md` - Result/Record 關聯設計
- ✅ `User.swift` - User 模型（已實作）
- ⚠️ `AnswerRecord.swift` - 待建立
- ⚠️ `magic_8_ballApp.swift` - 需修改

### B. 參考資源
- [SwiftData 官方文件](https://developer.apple.com/documentation/swiftdata)
- [SwiftData Relationships](https://developer.apple.com/documentation/swiftdata/defining-a-schema)
- [SwiftData Migration](https://developer.apple.com/documentation/swiftdata/migrating-your-apps-data)

### C. 版本記錄

| 版本 | 日期 | 修改內容 | 作者 |
|-----|------|---------|------|
| 1.0 | 2025/1/24 | 初版建立 | AI Assistant |
| 1.1 | 2025/1/24 | 明確 cascade 刪除策略、ModelContainer 註冊規範、完整錯誤處理需求 | AI Assistant |
| 1.2 | 2025/1/24 | 強制建立用戶、限制用戶數量、新增用戶管理實作規範 | AI Assistant |
| 1.3 | 2025/1/24 | 限制僅 1 個用戶、簡化用戶管理、新增替換用戶功能 | AI Assistant |
| 1.4 | 2025/1/24 | 新增「必須修正與強烈建議事項」章節、明確 iOS 17 系統需求 | AI Assistant |
| 2.0 | 2025/1/24 | 採用標準 MVP 策略、更新實作優先順序和檢查清單 | AI Assistant |
| 2.1 | 2025/1/24 | 精修文件結構、優化內容表達、建立配套 SwiftData_Todo.md | AI Assistant |
| 2.2 | 2025/1/24 | 移除時間時程相關敘述，專注於任務內容描述 | AI Assistant |

---

## 九、快速參考 ✅

### 9.1 核心決策摘要（標準 MVP）

| 項目 | 決策 | 理由 | MVP 階段 |
|-----|------|------|---------|
| iOS 版本 | **iOS 17.0+** | SwiftData 最低需求 | 階段一 |
| 刪除策略 | **cascade** | 保護隱私，刪除用戶連同刪除記錄 | 階段一 |
| 模型註冊 | **User + AnswerRecord** | 必須同時註冊，否則關聯失效 | 階段一 |
| 錯誤處理 | **do-catch + Alert** | 所有 save() 必須處理錯誤，禁用 fatalError | 階段二 |
| 記錄關聯 | **非可選型 User** | 每筆記錄必須有用戶 | 階段一 |
| 首次使用 | **引導建立用戶** | UserCreationView 引導填寫資料 | 階段二 |
| 用戶數量 | **限制 1 個** | 極簡設計，個人專屬占卜工具 | 階段一 |
| 用戶識別 | **動態查詢** | 避免 @AppStorage 單點失效 | 階段二 |
| 容錯處理 | **DatabaseErrorView** | ModelContainer 失敗時顯示錯誤畫面 | 階段二 |
| 並發安全 | **延後實作** | 非 MVP 範圍 | Post-MVP |

### 9.2 關鍵代碼片段

**ModelContainer 註冊**:
```swift
let schema = Schema([User.self, AnswerRecord.self])  // ← 必須兩個都註冊
```

**Cascade 刪除**:
```swift
@Relationship(deleteRule: .cascade, inverse: \AnswerRecord.user)
var records: [AnswerRecord] = []
```

**錯誤處理**:
```swift
do {
    try modelContext.save()
} catch {
    errorMessage = "儲存失敗: \(error.localizedDescription)"
    showError = true
}
```

### 9.3 常見錯誤排查

| 錯誤現象 | 可能原因 | 解決方法 |
|---------|---------|---------|
| App 啟動閃退 | ModelContainer 初始化失敗 | ✅ 改用 DatabaseErrorView 而非 fatalError |
| 儲存後資料消失 | 未呼叫 save() | insert 後必須 save() |
| 關聯資料顯示錯誤 | AnswerRecord 未註冊 | Schema 必須包含 AnswerRecord.self |
| 刪除用戶後記錄仍存在 | deleteRule 未設定 | 確認使用 .cascade |
| 用戶識別失效 | @AppStorage 清空 | ✅ 改用動態查詢 users.first |
| 多執行緒崩潰 | 背景執行緒操作 Context | ✅ 使用 @MainActor 或背景 Context |
| 編譯錯誤 | iOS 版本過舊 | ✅ 設定 Deployment Target 為 iOS 17.0 |

### 9.4 必須修正項目快速檢查 🔴（標準 MVP）

實作前請確認以下項目：

**階段一必須完成**:
- [ ] ✅ User 模型包含完整欄位（name, birthday, gender, createdAt）
- [ ] ✅ AnswerRecord 模型實作完成
- [ ] ✅ ModelContainer 同時註冊 User 和 AnswerRecord
- [ ] ✅ ModelContainer 初始化失敗返回 nil（而非 fatalError）
- [ ] ✅ ContentView 改用 @Query 查詢記錄
- [ ] ✅ 實作自動建立預設用戶邏輯
- [ ] ✅ 基本儲存功能（do-catch）

**階段二必須完成**:
- [ ] ✅ **修正 1**: 實作 DatabaseErrorView
- [ ] ✅ **修正 2**: 用戶識別改為動態查詢（`users.first`）
- [ ] ✅ **修正 3**: Deployment Target 設為 iOS 17.0+
- [ ] ✅ 實作 UserCreationView（首次引導）
- [ ] ✅ 所有 SwiftData 操作有完整錯誤處理
- [ ] ✅ 完成基本 UI/UX 測試

**可選項目（延後）**:
- [ ] 🟡 **建議 1**: 在文件中說明單用戶設計理由
- [ ] 🟡 **建議 2**: @Query 使用 fetchLimit 限制數量
- [ ] 🟡 **建議 3**: UI 操作標註 @MainActor

**標準 MVP 交付確認**:
- [ ] ✅ ModelContainer 初始化失敗顯示錯誤畫面
- [ ] ✅ 首次啟動引導建立用戶
- [ ] ✅ 用戶識別穩定，重裝 App 後正常
- [ ] ✅ 所有 SwiftData 操作有錯誤處理
- [ ] ✅ 問答記錄持久化正常
- [ ] ✅ 無明顯 bug 或閃退

---

**文件結束**
