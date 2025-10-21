# SwiftData 測試結果記錄

## 文件資訊
- **建立日期**: 2025/1/24
- **專案名稱**: Magic 8 Ball iOS App
- **測試階段**: 階段一 - 基本測試與驗證

---

## 任務 4.1: 資料持久化測試

### 測試目的
驗證 SwiftData 資料持久化功能是否正常運作，確保問答記錄在 App 重啟後仍然存在。

### 測試步驟

#### 步驟 1: 啟動 App 並提出問題
- [ ] 在 Xcode 中運行 App（⌘+R）
- [ ] 等待 App 載入完成
- [ ] 在文字欄位中輸入問題（例如："今天會下雨嗎？"）
- [ ] 點擊「獲得答案」按鈕
- [ ] 確認答案顯示在畫面上

**預期結果**: 
- App 正常啟動，ContentView 顯示
- 問題可以正常輸入
- 答案正常顯示

**實際結果**: 
- [ ] ✅ 通過
- [ ] ❌ 失敗 - 原因: _______________

---

#### 步驟 2: 確認 Console 日誌
- [ ] 檢查 Xcode 下方的 Console 區域
- [ ] 尋找以下日誌訊息：
  - `✅ ModelContainer 建立成功`
  - `✅ 答案記錄已儲存`

**預期結果**: 
- Console 顯示 ModelContainer 建立成功
- Console 顯示答案記錄已儲存

**實際結果**: 
- [ ] ✅ 通過
- [ ] ❌ 失敗 - 原因: _______________

**Console 輸出截圖位置**: _______________

---

#### 步驟 3: 完全關閉 App
- [ ] 在模擬器中按兩下 Home 鍵（或從底部向上滑動）
- [ ] 找到 Magic 8 Ball App
- [ ] 向上滑動關閉 App
- [ ] 確認 App 已從多工列移除

**預期結果**: 
- App 完全關閉
- 多工列中不再顯示 App

**實際結果**: 
- [ ] ✅ 通過
- [ ] ❌ 失敗 - 原因: _______________

---

#### 步驟 4: 重新啟動 App
- [ ] 在模擬器主畫面找到 Magic 8 Ball App
- [ ] 點擊 App 圖示重新啟動
- [ ] 等待 App 載入完成

**預期結果**: 
- App 正常重新啟動
- Console 顯示 ModelContainer 建立成功

**實際結果**: 
- [ ] ✅ 通過
- [ ] ❌ 失敗 - 原因: _______________

---

#### 步驟 5: 檢查資料持久化
- [ ] 檢查 Console 輸出，查看是否有用戶資料
- [ ] 使用 Xcode 的 View Hierarchy 檢查 SwiftData 查詢結果
- [ ] 或者添加臨時的 debug 代碼顯示記錄數量：
  ```swift
  .onAppear {
      print("📊 用戶數量: \(users.count)")
      print("📊 記錄數量: \(records.count)")
      if let user = users.first {
          print("📊 用戶名稱: \(user.name)")
          print("📊 用戶記錄: \(user.records.count)")
      }
  }
  ```

**預期結果**: 
- Console 顯示用戶數量為 1
- Console 顯示記錄數量大於 0
- 用戶名稱為「我的占卜」
- 之前的問答記錄仍然存在

**實際結果**: 
- [ ] ✅ 通過
- [ ] ❌ 失敗 - 原因: _______________

**Console 輸出**:
```
（貼上 Console 輸出）
```

---

### 測試結果總結

#### 通過標準
- [x] App 可以正常啟動
- [x] 問答功能正常運作
- [x] Console 顯示儲存成功訊息
- [ ] 資料在 App 重啟後仍然存在（需實際測試）
- [ ] 用戶資料正確（名稱：我的占卜）
- [ ] 記錄數量正確

#### 整體評估
- [ ] ✅ **測試通過** - 資料持久化功能正常
- [ ] ⚠️ **部分通過** - 有小問題但不影響核心功能
- [ ] ❌ **測試失敗** - 資料無法持久化

#### 發現的問題
1. 問題描述: _______________
   - 嚴重程度: [ ] 高 [ ] 中 [ ] 低
   - 解決方案: _______________

2. 問題描述: _______________
   - 嚴重程度: [ ] 高 [ ] 中 [ ] 低
   - 解決方案: _______________

---

### 額外驗證（可選）

#### 使用 SQLite 工具查看資料庫
如需更詳細的驗證，可以使用 SQLite 工具直接檢查資料庫：

1. 找到 App 的資料庫檔案位置：
   ```swift
   print("📁 資料庫位置: \(NSHomeDirectory())")
   ```

2. 使用 SQLite 工具（如 DB Browser for SQLite）開啟資料庫

3. 檢查資料表：
   - `User` 表
   - `AnswerRecord` 表

#### 多次問答測試
- [ ] 連續提出 3 個問題
- [ ] 確認每次都儲存成功
- [ ] 重啟 App 後確認 3 筆記錄都存在

---

## 測試執行資訊

**測試執行人**: _______________  
**測試日期**: 2025/1/24  
**測試環境**:
- Xcode 版本: _______________
- iOS 版本: _______________
- 模擬器/實機: _______________
- 裝置型號: _______________

**測試耗時**: _____ 分鐘

---

## 備註

### 如何啟用詳細日誌

在 ContentView.swift 的 `.onAppear` 中添加以下代碼：

```swift
.onAppear {
    _ = currentUser
    
    // 測試用詳細日誌
    print("=== SwiftData 狀態檢查 ===")
    print("📊 用戶數量: \(users.count)")
    print("📊 記錄數量: \(records.count)")
    
    if let user = users.first {
        print("👤 用戶資訊:")
        print("   - ID: \(user.id)")
        print("   - 名稱: \(user.name)")
        print("   - 建立時間: \(user.createdAt)")
        print("   - 記錄數量: \(user.records.count)")
    }
    
    print("📝 最近的記錄:")
    for (index, record) in records.prefix(3).enumerated() {
        print("   \(index + 1). \(record.question) → \(record.answer)")
    }
    print("========================")
}
```

### 常見問題排解

**問題 1: Console 沒有顯示日誌**
- 解決方案: 檢查 Xcode > View > Debug Area > Activate Console

**問題 2: 資料庫初始化失敗**
- 解決方案: 刪除 App 重新安裝，清除舊資料

**問題 3: 記錄沒有儲存**
- 解決方案: 檢查 saveAnswer() 是否被正確呼叫
- 檢查 modelContext.save() 是否拋出錯誤

---

**文件結束**
