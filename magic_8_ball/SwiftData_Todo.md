# Magic 8 Ball SwiftData 整合 - 任務清單

## 文件資訊
- **版本**: 1.2
- **最後更新**: 2025/1/24
- **專案名稱**: Magic 8 Ball iOS App
- **開發策略**: 標準 MVP
- **配套文件**: `SwiftData_Requirements.md` - 需求規範文件

---

## 目錄
1. [開發階段概覽](#開發階段概覽)
2. [階段一：基礎實作](#階段一基礎實作)
3. [階段二：UI 和錯誤處理](#階段二ui-和錯誤處理)
4. [交付標準檢查](#交付標準檢查)
5. [延後實作項目](#延後實作項目)

---

## 開發階段概覽

### 標準 MVP 架構

```
階段一：基礎實作
├─ 資料模型設計與實作
├─ ModelContainer 設定
├─ ContentView 整合
└─ 基本測試與驗證

階段二：UI 和錯誤處理
├─ DatabaseErrorView 實作
├─ UserCreationView 實作
├─ 動態查詢與錯誤處理
└─ 完整測試與驗證
```

---

## 階段一：基礎實作

### 📋 模組 1: 資料模型設計與實作

#### ✅ 任務 1.1: User 模型完善
**優先級**: 🔴 必須

- [x] 開啟 `User.swift` 檔案
- [x] 確認包含以下欄位：
  - [x] `id: UUID` - 主鍵
  - [x] `name: String` - 用戶名稱
  - [x] `birthday: Date?` - 生日（可選）
  - [x] `gender: String?` - 性別（可選）
  - [x] `createdAt: Date` - 建立時間
- [x] 新增 `@Relationship` 關聯：
  ```swift
  @Relationship(deleteRule: .cascade, inverse: \AnswerRecord.user)
  var records: [AnswerRecord] = []
  ```
- [x] 驗證：編譯無錯誤

**參考代碼**: 見 `SwiftData_Requirements.md` 第一章節

**完成狀態**: ✅ 已完成
- 已將 `birthday` 和 `gender` 改為可選型
- 新增 `createdAt: Date` 欄位
- 新增 `@Relationship` 關聯到 AnswerRecord
- 更新初始化方法支援可選參數

---

#### ✅ 任務 1.2: AnswerRecord 模型建立
**優先級**: 🔴 必須

- [x] 建立新檔案 `Models/AnswerRecord.swift`
- [x] 實作以下欄位：
  - [x] `id: UUID` - 主鍵
  - [x] `question: String` - 用戶問題
  - [x] `answer: String` - 占卜答案
  - [x] `answerType: AnswerType` - 答案類型（肯定/否定/中性）
  - [x] `timestamp: Date` - 記錄時間
  - [x] `@Relationship var user: User` - 關聯用戶（非可選）
- [x] 實作初始化方法：
  ```swift
  init(question: String, answer: String, answerType: AnswerType, user: User) {
      self.id = UUID()
      self.question = question
      self.answer = answer
      self.answerType = answerType
      self.timestamp = Date()
      self.user = user
  }
  ```
- [x] 驗證：編譯無錯誤

**完成狀態**: ✅ 已完成
- 建立 Models 目錄
- 建立 AnswerRecord.swift 檔案
- 實作所有必要欄位（id, question, answer, answerType, timestamp）
- 實作 @Relationship 關聯到 User（非可選）
- 實作完整初始化方法

---

#### ✅ 任務 1.3: AnswerType 枚舉建立
**優先級**: 🔴 必須

- [ ] 建立新檔案 `Models/AnswerType.swift`
- [ ] 實作枚舉：
  ```swift
  import Foundation
  
  enum AnswerType: String, Codable {
      case positive = "肯定"
      case negative = "否定"
      case neutral = "中性"
  }
  ```
- [ ] 驗證：編譯無錯誤

---

### 📋 模組 2: ModelContainer 設定

#### ✅ 任務 2.1: ModelContainer 基本設定
**優先級**: 🔴 必須

- [ ] 開啟 `magic_8_ballApp.swift`
- [ ] 修改 `sharedModelContainer` 為可選型 `ModelContainer?`
- [ ] 註冊所有模型：
  ```swift
  let schema = Schema([
      User.self,
      AnswerRecord.self
  ])
  ```
- [ ] 設定 ModelConfiguration：
  ```swift
  let modelConfiguration = ModelConfiguration(
      schema: schema,
      isStoredInMemoryOnly: false,
      allowsSave: true
  )
  ```
- [ ] 實作 do-catch 錯誤處理
- [ ] 初始化失敗時返回 `nil`（不使用 fatalError）
- [ ] 添加 Console 日誌：
  - 成功：`print("✅ ModelContainer 建立成功")`
  - 失敗：`print("❌ ModelContainer 建立失敗: \(error.localizedDescription)")`
- [ ] 驗證：App 啟動時查看 Console 輸出

**參考代碼**: 見 `SwiftData_Requirements.md` 零、修正 1

---

#### ✅ 任務 2.2: App 入口條件渲染
**優先級**: 🔴 必須

- [ ] 在 `body: some Scene` 中實作條件判斷：
  ```swift
  var body: some Scene {
      WindowGroup {
          if let container = sharedModelContainer {
              ContentView()
                  .modelContainer(container)
          } else {
              DatabaseErrorView()  // 階段二實作
          }
      }
  }
  ```
- [ ] 暫時建立空的 DatabaseErrorView 佔位：
  ```swift
  struct DatabaseErrorView: View {
      var body: some View {
          Text("資料庫初始化失敗")
      }
  }
  ```
- [ ] 驗證：App 正常啟動並載入 ContentView

---

### 📋 模組 3: ContentView 整合

#### ✅ 任務 3.1: 新增 @Query 查詢
**優先級**: 🔴 必須

- [ ] 開啟 `ContentView.swift`
- [ ] 新增 SwiftData 匯入：`import SwiftData`
- [ ] 新增用戶查詢：
  ```swift
  @Query private var users: [User]
  ```
- [ ] 新增記錄查詢（按時間倒序）：
  ```swift
  @Query(sort: \AnswerRecord.timestamp, order: .reverse)
  private var records: [AnswerRecord]
  ```
- [ ] 新增 ModelContext：
  ```swift
  @Environment(\.modelContext) private var modelContext
  ```
- [ ] 驗證：編譯無錯誤

---

#### ✅ 任務 3.2: 實作自動建立預設用戶邏輯
**優先級**: 🔴 必須

- [ ] 新增 `currentUser` 計算屬性：
  ```swift
  var currentUser: User {
      if let user = users.first {
          return user
      } else {
          // 自動建立預設用戶
          let newUser = User(
              name: "我的占卜",
              birthday: nil,
              gender: nil
          )
          modelContext.insert(newUser)
          try? modelContext.save()
          return newUser
      }
  }
  ```
- [ ] 在 `.onAppear` 中確保用戶存在：
  ```swift
  .onAppear {
      _ = currentUser  // 觸發用戶建立邏輯
  }
  ```
- [ ] 驗證：首次啟動 App 時自動建立預設用戶

---

#### ✅ 任務 3.3: 實作基本儲存功能
**優先級**: 🔴 必須

- [ ] 找到現有的 `performShake()` 或類似函數
- [ ] 新增儲存邏輯（在顯示答案後）：
  ```swift
  func saveAnswer(question: String, answer: String, answerType: AnswerType) {
      let record = AnswerRecord(
          question: question,
          answer: answer,
          answerType: answerType,
          user: currentUser
      )
      
      do {
          modelContext.insert(record)
          try modelContext.save()
          print("✅ 記錄儲存成功")
      } catch {
          print("❌ 儲存失敗: \(error.localizedDescription)")
          // 階段二會改為顯示 Alert
      }
  }
  ```
- [ ] 整合到搖晃事件處理邏輯中
- [ ] 驗證：問答後可在 Console 看到成功訊息

---

### 📋 模組 4: 基本測試與驗證

#### ✅ 任務 4.1: 資料持久化測試
**優先級**: 🔴 必須

- [ ] 執行以下測試步驟：
  1. [ ] 啟動 App，提出問題並獲得答案
  2. [ ] 確認 Console 顯示「✅ 記錄儲存成功」
  3. [ ] 完全關閉 App（從多工列移除）
  4. [ ] 重新啟動 App
  5. [ ] 檢查記錄是否仍然存在
- [ ] 記錄測試結果

---

#### ✅ 任務 4.2: Cascade 刪除測試
**優先級**: 🔴 必須

- [ ] 暫時新增刪除用戶的測試代碼：
  ```swift
  Button("測試刪除用戶") {
      if let user = users.first {
          modelContext.delete(user)
          try? modelContext.save()
      }
  }
  ```
- [ ] 執行測試：
  1. [ ] 建立幾筆問答記錄
  2. [ ] 點擊「測試刪除用戶」按鈕
  3. [ ] 驗證所有記錄一併被刪除
- [ ] 測試完成後移除測試代碼
- [ ] 記錄測試結果

---

#### ✅ 任務 4.3: 階段一交付檢查
**優先級**: 🔴 必須

檢查以下項目是否完成：

- [ ] ✅ User 模型包含完整欄位
- [ ] ✅ AnswerRecord 模型實作完成
- [ ] ✅ AnswerType 枚舉實作完成
- [ ] ✅ ModelContainer 同時註冊兩個模型
- [ ] ✅ ModelContainer 初始化失敗返回 nil
- [ ] ✅ ContentView 改用 @Query 查詢記錄
- [ ] ✅ 實作自動建立預設用戶邏輯
- [ ] ✅ 基本儲存功能正常運作
- [ ] ✅ 資料持久化測試通過
- [ ] ✅ Cascade 刪除測試通過
- [ ] ✅ App 可正常啟動，無明顯 bug

**階段一完成度**: _____ / 11 項

---

## 階段二：UI 和錯誤處理

### 📋 模組 5: DatabaseErrorView 實作

#### ✅ 任務 5.1: 完善 DatabaseErrorView
**優先級**: 🔴 必須

- [ ] 開啟 `magic_8_ballApp.swift` 或建立 `Views/DatabaseErrorView.swift`
- [ ] 實作完整的錯誤畫面（參考 `SwiftData_Requirements.md` 修正 1）：
  - [ ] 錯誤圖示（`exclamationmark.triangle.fill`）
  - [ ] 錯誤標題「資料庫初始化失敗」
  - [ ] 解決方案列表（重啟 App、檢查空間、重新安裝）
  - [ ] 「重新啟動」按鈕
- [ ] 驗證：編譯無錯誤，畫面顯示正常

---

#### ✅ 任務 5.2: 測試錯誤處理流程
**優先級**: 🔴 必須

- [ ] 暫時修改 ModelContainer 初始化強制拋出錯誤：
  ```swift
  throw NSError(domain: "TestError", code: 1)
  ```
- [ ] 啟動 App，驗證顯示 DatabaseErrorView
- [ ] 恢復正常代碼
- [ ] 記錄測試結果

---

### 📋 模組 6: UserCreationView 實作

#### ✅ 任務 6.1: 建立 UserCreationView
**優先級**: 🔴 必須

- [ ] 建立新檔案 `Views/UserCreationView.swift`
- [ ] 實作表單欄位：
  - [ ] 名稱輸入（TextField，必填）
  - [ ] 生日選擇（DatePicker，可選）
  - [ ] 性別選擇（Picker，可選：男/女/其他）
- [ ] 實作簡單驗證：
  - [ ] 名稱不為空
  - [ ] 顯示錯誤提示
- [ ] 實作「建立」按鈕：
  ```swift
  Button("建立") {
      let user = User(
          name: userName,
          birthday: selectedBirthday,
          gender: selectedGender
      )
      modelContext.insert(user)
      
      do {
          try modelContext.save()
          isPresented = false  // 關閉畫面
      } catch {
          errorMessage = "建立失敗: \(error.localizedDescription)"
          showError = true
      }
  }
  ```
- [ ] 驗證：編譯無錯誤，表單顯示正常

**參考代碼**: 見 `SwiftData_Requirements.md` 第二章節

---

#### ✅ 任務 6.2: 整合首次啟動流程
**優先級**: 🔴 必須

- [ ] 修改 ContentView 的 `currentUser` 邏輯：
  ```swift
  @State private var showUserCreation = false
  
  var body: some View {
      VStack {
          // 原有內容
      }
      .sheet(isPresented: $showUserCreation) {
          UserCreationView()
      }
      .onAppear {
          if users.isEmpty {
              showUserCreation = true
          }
      }
  }
  ```
- [ ] 驗證：首次啟動顯示用戶建立畫面

---

### 📋 模組 7: 動態查詢與錯誤處理

#### ✅ 任務 7.1: 修正用戶識別邏輯
**優先級**: 🔴 必須

- [ ] 移除或不使用 `@AppStorage("currentUserId")`
- [ ] 改用動態查詢方式：
  ```swift
  var currentUser: User? {
      users.first  // 因為限制僅 1 個用戶
  }
  ```
- [ ] 更新所有使用 currentUser 的地方處理可選型
- [ ] 驗證：重新安裝 App 後仍可正常識別用戶

**參考**: 見 `SwiftData_Requirements.md` 修正 2

---

#### ✅ 任務 7.2: 完善所有 SwiftData 操作的錯誤處理
**優先級**: 🔴 必須

- [ ] 找出所有 `modelContext.save()` 呼叫
- [ ] 為每個呼叫新增完整的 do-catch：
  ```swift
  do {
      try modelContext.save()
      // 成功處理
  } catch {
      errorMessage = "操作失敗: \(error.localizedDescription)"
      showError = true
  }
  ```
- [ ] 新增 Alert 顯示：
  ```swift
  @State private var showError = false
  @State private var errorMessage = ""
  
  .alert("錯誤", isPresented: $showError) {
      Button("確定", role: .cancel) { }
  } message: {
      Text(errorMessage)
  }
  ```
- [ ] 測試各種錯誤情境
- [ ] 驗證：錯誤時顯示友善提示而非閃退

---

#### ✅ 任務 7.3: 設定 iOS 17.0 Deployment Target
**優先級**: 🔴 必須

- [ ] 開啟 Xcode 專案設定
- [ ] 選擇專案目標（Target）
- [ ] 在 General > Deployment Info 中：
  - [ ] 設定 Minimum Deployments 為 iOS 17.0
- [ ] 清理建置：Product > Clean Build Folder
- [ ] 重新編譯專案
- [ ] 驗證：編譯成功，無版本相關警告

---

### 📋 模組 8: 完整測試與驗證

#### ✅ 任務 8.1: 首次啟動流程測試
**優先級**: 🔴 必須

- [ ] 完全移除 App（模擬首次安裝）
- [ ] 執行測試流程：
  1. [ ] 啟動 App
  2. [ ] 驗證顯示 UserCreationView
  3. [ ] 測試表單驗證（空名稱應提示錯誤）
  4. [ ] 填寫完整資料並建立
  5. [ ] 驗證自動進入主畫面
  6. [ ] 提出問題並獲得答案
  7. [ ] 驗證記錄儲存成功
- [ ] 記錄測試結果

---

#### ✅ 任務 8.2: 重新安裝測試
**優先級**: 🔴 必須

- [ ] 執行測試流程：
  1. [ ] 建立用戶並新增幾筆記錄
  2. [ ] 完全移除 App
  3. [ ] 重新安裝 App
  4. [ ] 驗證需要重新建立用戶
  5. [ ] 驗證舊記錄不存在（預期行為）
- [ ] 記錄測試結果

---

#### ✅ 任務 8.3: 錯誤處理測試
**優先級**: 🔴 必須

- [ ] 測試以下錯誤情境：
  1. [ ] ModelContainer 初始化失敗（暫時強制拋錯）
     - [ ] 驗證顯示 DatabaseErrorView
  2. [ ] 儲存失敗（可能需模擬）
     - [ ] 驗證顯示錯誤 Alert
  3. [ ] 用戶建立失敗（名稱為空）
     - [ ] 驗證顯示驗證錯誤
- [ ] 記錄所有測試結果

---

#### ✅ 任務 8.4: 基本 UI/UX 測試
**優先級**: 🔴 必須

- [ ] 測試以下操作流程：
  1. [ ] 正常問答流程（搖晃 → 答案 → 儲存）
  2. [ ] 查看歷史記錄
  3. [ ] 連續多次問答
  4. [ ] 背景切換測試（App 進入背景再恢復）
  5. [ ] 裝置旋轉測試
- [ ] 檢查以下 UI 元素：
  - [ ] 按鈕可點擊
  - [ ] 文字可閱讀
  - [ ] 布局無錯位
  - [ ] 動畫流暢
- [ ] 記錄發現的任何問題

---

## 交付標準檢查

### 標準 MVP 交付確認

請逐項確認以下標準：

#### 階段一基礎功能
- [ ] ✅ User 模型包含完整欄位（name, birthday, gender, createdAt）
- [ ] ✅ AnswerRecord 模型實作完成
- [ ] ✅ AnswerType 枚舉實作完成
- [ ] ✅ ModelContainer 同時註冊 User 和 AnswerRecord
- [ ] ✅ ModelContainer 初始化失敗返回 nil（而非 fatalError）
- [ ] ✅ ContentView 改用 @Query 查詢記錄
- [ ] ✅ 實作自動建立預設用戶邏輯（或首次引導建立）
- [ ] ✅ 基本儲存功能（包含 do-catch）

#### 階段二 UI 和錯誤處理
- [ ] ✅ 實作 DatabaseErrorView
- [ ] ✅ 用戶識別改為動態查詢（`users.first`）
- [ ] ✅ Deployment Target 設為 iOS 17.0+
- [ ] ✅ 實作 UserCreationView（首次引導）
- [ ] ✅ 所有 SwiftData 操作有完整錯誤處理
- [ ] ✅ 完成基本 UI/UX 測試

#### 核心功能驗證
- [ ] ✅ ModelContainer 初始化失敗顯示錯誤畫面
- [ ] ✅ 首次啟動引導建立用戶
- [ ] ✅ 用戶識別穩定，重裝 App 後正常
- [ ] ✅ 所有 SwiftData 操作有錯誤處理
- [ ] ✅ 問答記錄可儲存並持久化
- [ ] ✅ 重啟 App 後歷史記錄仍存在
- [ ] ✅ 無明顯 bug 或閃退

**標準 MVP 完成度**: _____ / 22 項

---

## 延後實作項目

以下功能屬於「完整版」或「Post-MVP」範圍，在標準 MVP 階段**不需要實作**：

### UserProfileView（顯示用戶資料）
- 顯示用戶基本資料
- 顯示統計資訊（問答次數、最常問的問題等）
- **延後理由**: 非核心功能，標準 MVP 專注於基本持久化

### 用戶資料編輯功能（UserEditView）
- 修改名稱、生日、性別
- 更新用戶資料
- **延後理由**: 單用戶模式下編輯需求較低

### 用戶替換功能
- 清理現有用戶和所有記錄
- 重新建立新用戶
- **延後理由**: 極少使用的功能，可等待用戶反饋

### 資料統計分析
- 各類型答案統計（肯定/否定/中性）
- 時間分布圖表
- 最常問的問題排行
- **延後理由**: 進階功能，需要圖表庫

### 資料匯出/匯入功能
- 匯出記錄為 JSON 或 CSV
- 從檔案匯入記錄
- **延後理由**: 複雜度高，非必要功能

### 效能優化
- @Query fetchLimit 限制
- 分頁載入歷史記錄
- 查詢效能優化
- **延後理由**: 記錄數量較少時無明顯效能問題

### 進階錯誤恢復機制
- 自動重試機制
- 資料修復功能
- 詳細錯誤日誌
- **延後理由**: 標準錯誤處理已足夠

### 並發安全
- @MainActor 標註
- 背景執行緒處理
- ModelContext 隔離
- **延後理由**: 簡單 CRUD 操作無並發問題

### 單元測試和 UI 測試
- User 模型測試
- AnswerRecord 模型測試
- SwiftData 操作測試
- UI 流程測試
- **延後理由**: 手動測試已覆蓋核心流程

---

## 進度追蹤

### 階段一進度

| 模組 | 計畫任務 | 完成狀態 | 備註 |
|-----|---------|---------|-----|
| 模組 1 | 任務 1.1-1.3 資料模型 | ⬜ | |
| 模組 2 | 任務 2.1-2.2 ModelContainer | ⬜ | |
| 模組 3 | 任務 3.1-3.3 ContentView 整合 | ⬜ | |
| 模組 4 | 任務 4.1-4.3 測試驗證 | ⬜ | |

### 階段二進度

| 模組 | 計畫任務 | 完成狀態 | 備註 |
|-----|---------|---------|-----|
| 模組 5 | 任務 5.1-5.2 DatabaseErrorView | ⬜ | |
| 模組 6 | 任務 6.1-6.2 UserCreationView | ⬜ | |
| 模組 7 | 任務 7.1-7.3 動態查詢與錯誤處理 | ⬜ | |
| 模組 8 | 任務 8.1-8.4 完整測試 | ⬜ | |

---

## 問題追蹤

### 遇到的問題記錄

| # | 問題描述 | 解決方案 | 狀態 |
|---|---------|---------|-----|
| 1 | | | |
| 2 | | | |
| 3 | | | |

### 技術決策記錄

| # | 決策內容 | 理由 | 影響 |
|---|---------|-----|-----|
| 1 | | | |
| 2 | | | |
| 3 | | | |

---

## 快速參考

### 常用指令

**清理 Xcode 建置**:
```bash
# Product > Clean Build Folder
# 或使用快捷鍵：Shift + Cmd + K
```

**完全移除 App**:
1. 從模擬器或裝置刪除 App
2. 從最近使用列表中移除
3. 重新從 Xcode 安裝

**查看 Console 輸出**:
- Xcode 下方 Debug area
- 或使用 Console.app（macOS）

### 重要檔案位置

```
magic_8_ball/
├── Models/
│   ├── User.swift                 ← 已存在，需修改
│   ├── AnswerRecord.swift         ← 需建立
│   └── AnswerType.swift           ← 需建立
├── Views/
│   ├── ContentView.swift          ← 需修改
│   ├── DatabaseErrorView.swift    ← 需建立
│   └── UserCreationView.swift     ← 需建立
└── magic_8_ballApp.swift          ← 需修改
```

### 參考文件

- `SwiftData_Requirements.md` - 完整需求規範
- `SwiftData_MVP_Strategy.md` - MVP 策略說明
- [SwiftData 官方文件](https://developer.apple.com/documentation/swiftdata)

---

## 總結

### 開發重點
1. **階段一專注於基礎**: 資料模型、持久化、基本儲存
2. **階段二專注於體驗**: 錯誤處理、用戶引導、完整測試
3. **避免過度設計**: 延後非必要功能，確保核心功能穩定

### 成功標準
- ✅ 資料可持久化保存
- ✅ 首次使用體驗流暢
- ✅ 錯誤優雅處理不閃退
- ✅ 所有核心功能正常運作

### 下一步
完成標準 MVP 後，根據使用反饋決定是否實作延後項目。

---

**文件結束**
