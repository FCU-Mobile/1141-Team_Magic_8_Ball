# SwiftData 故障排查指南

## 文件資訊
- **建立日期**: 2025/1/24
- **專案名稱**: Magic 8 Ball iOS App
- **問題**: 步驟 5 資料持久化檢查失敗

---

## 問題描述

根據 `SwiftData_Test_Results.md`，發現以下問題：

### 步驟 4: 重新啟動 App
- ❌ 失敗 - Console 沒有顯示 ModelContainer 建立成功

### 步驟 5: 檢查資料持久化
- ❌ 失敗 - 無法看到用戶和記錄資料

### Console 輸出
```
-[RTIInputSystemClient remoteTextInputSessionWithID:performInputOperation:]  perform input operation requires a valid sessionID
[C:3] Error received: Connection interrupted.
```

---

## 可能原因分析

### 原因 1: Console 日誌被過濾或隱藏
**症狀**: 
- Console 只顯示系統錯誤訊息
- 沒有看到我們的 print() 輸出

**診斷方法**:
1. 檢查 Xcode Console 的過濾設置
2. 確認是否選擇了正確的目標設備

**解決方案**:
- 在 Xcode Console 右下角檢查過濾器設置
- 選擇「All Output」而非「Errors and Warnings Only」
- 清除搜索框中的任何過濾文字

---

### 原因 2: App 在首次運行時閃退或未完全啟動
**症狀**:
- App 啟動後立即關閉
- Console 顯示 Connection interrupted

**診斷方法**:
1. 查看完整的 Console 輸出
2. 檢查是否有 crash log

**解決方案**:
- 完全刪除 App 並重新安裝
- 清理 Xcode 建置快取（Shift + Cmd + K）
- 檢查模擬器狀態

---

### 原因 3: ModelContainer 初始化失敗但錯誤被忽略
**症狀**:
- App 正常顯示但資料無法儲存
- DatabaseErrorView 沒有顯示

**診斷方法**:
1. 檢查 `sharedModelContainer` 是否為 nil
2. 添加更詳細的錯誤日誌

**解決方案**:
```swift
var sharedModelContainer: ModelContainer? = {
    print("🔧 開始建立 ModelContainer...")
    
    let schema = Schema([
        User.self,
        AnswerRecord.self
    ])
    print("🔧 Schema 建立完成，包含 \(schema.entities.count) 個實體")
    
    let modelConfiguration = ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: false,
        allowsSave: true
    )
    print("🔧 ModelConfiguration 設定完成")
    
    do {
        let container = try ModelContainer(
            for: schema,
            configurations: [modelConfiguration]
        )
        print("✅ ModelContainer 建立成功")
        print("📁 儲存位置: \(container.configurations.first?.url.path ?? "未知")")
        return container
    } catch {
        print("❌ ModelContainer 建立失敗")
        print("❌ 錯誤類型: \(type(of: error))")
        print("❌ 錯誤描述: \(error.localizedDescription)")
        print("❌ 完整錯誤: \(error)")
        return nil
    }
}()
```

---

### 原因 4: 資料確實儲存了但日誌沒有顯示
**症狀**:
- saveAnswer() 執行成功
- 但 onAppear 日誌沒有輸出

**診斷方法**:
1. 檢查 onAppear 是否被觸發
2. 添加更早期的日誌點

**解決方案**:
```swift
var body: some View {
    VStack {
        // ... UI code
    }
    .onAppear {
        print("🚀 ContentView.onAppear 被觸發")
        _ = currentUser
        
        print("=== SwiftData 狀態檢查 ===")
        print("📊 用戶數量: \(users.count)")
        print("📊 記錄數量: \(records.count)")
        // ... rest of logging
    }
}
```

---

### 原因 5: @Query 沒有正確更新
**症狀**:
- 資料已儲存到資料庫
- 但 @Query 沒有反映最新資料

**診斷方法**:
1. 檢查 @Query 的定義
2. 驗證 modelContext 是否正確注入

**解決方案**:
- 確保使用 `.modelContainer(container)` 而非 `.modelContainer(for: User.self)`
- 檢查 ModelContainer 是否正確傳遞

---

## 立即排查步驟

### 步驟 1: 增強日誌輸出（已完成）
已在 ContentView.swift 添加詳細日誌：
- ✅ users.count
- ✅ records.count
- ✅ 用戶資訊
- ✅ 最近的記錄

### 步驟 2: 檢查 Console 設置
1. 打開 Xcode
2. 運行 App
3. 在 Console 區域檢查：
   - [ ] 過濾器設為「All Output」
   - [ ] 搜索框為空
   - [ ] 選擇正確的模擬器/設備

### 步驟 3: 完全清理重建
```bash
# 在終端機執行
cd /Users/joseph-m2/Dev/1141-Team_Magic_8_Ball
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

然後在 Xcode：
1. Product > Clean Build Folder（Shift + Cmd + K）
2. 刪除模擬器上的 App
3. Product > Build（Cmd + B）
4. Product > Run（Cmd + R）

### 步驟 4: 驗證資料庫位置
添加以下代碼到 `magic_8_ballApp.swift`：

```swift
var sharedModelContainer: ModelContainer? = {
    // ... existing code ...
    do {
        let container = try ModelContainer(
            for: schema,
            configurations: [modelConfiguration]
        )
        print("✅ ModelContainer 建立成功")
        
        // 新增：顯示資料庫位置
        if let url = container.configurations.first?.url {
            print("📁 資料庫位置: \(url.path)")
        }
        
        return container
    } catch {
        // ... existing error handling ...
    }
}()
```

### 步驟 5: 測試基本功能
1. 啟動 App
2. 查看 Console，應該看到：
   ```
   🔧 開始建立 ModelContainer...
   ✅ ModelContainer 建立成功
   📁 資料庫位置: /path/to/database
   🚀 ContentView.onAppear 被觸發
   === SwiftData 狀態檢查 ===
   📊 用戶數量: 0 或 1
   📊 記錄數量: 0
   ```
3. 輸入問題並獲得答案
4. 查看 Console，應該看到：
   ```
   ✅ 答案記錄已儲存
   ```
5. 關閉並重啟 App
6. 查看 Console，應該看到：
   ```
   📊 用戶數量: 1
   📊 記錄數量: 1 或更多
   👤 用戶資訊:
      - 名稱: 我的占卜
   📝 最近的記錄:
      1. [問題] → [答案]
   ```

---

## 替代診斷方法

### 方法 1: 使用 Xcode Debugger
1. 在 `currentUser` 計算屬性中設置斷點
2. 運行 App
3. 檢查 `users.count` 的值
4. 檢查 `users.first` 是否為 nil

### 方法 2: 使用 View Hierarchy
1. 運行 App
2. 點擊 Xcode 的「Debug View Hierarchy」按鈕
3. 檢查 ContentView 的屬性
4. 查看 @Query 的結果

### 方法 3: 直接檢查資料庫檔案
1. 找到資料庫位置（從 Console 日誌）
2. 使用 DB Browser for SQLite 開啟
3. 查看 User 和 AnswerRecord 表
4. 確認資料是否真的儲存

---

## 預期的正常 Console 輸出

### 首次啟動（沒有資料）
```
✅ ModelContainer 建立成功
📁 資料庫位置: /Users/.../default.store
🚀 ContentView.onAppear 被觸發
=== SwiftData 狀態檢查 ===
📊 用戶數量: 0
📊 記錄數量: 0
⚠️ 沒有找到用戶
📝 最近的記錄:
   ⚠️ 沒有任何記錄
========================
```

### 提出問題後
```
✅ 答案記錄已儲存
```

### 重啟後（有資料）
```
✅ ModelContainer 建立成功
📁 資料庫位置: /Users/.../default.store
🚀 ContentView.onAppear 被觸發
=== SwiftData 狀態檢查 ===
📊 用戶數量: 1
📊 記錄數量: 1
👤 用戶資訊:
   - ID: ABC-123-DEF
   - 名稱: 我的占卜
   - 建立時間: 2025-01-24 15:30:00 +0000
   - 記錄數量: 1
📝 最近的記錄:
   1. 今天會下雨嗎？ → 這是必然
========================
```

---

## 已實施的修復

### 修復 1: 增強 ContentView 日誌
✅ 已完成 - 在 `.onAppear` 中添加詳細的 SwiftData 狀態檢查

內容包括：
- 用戶數量
- 記錄數量
- 用戶詳細資訊
- 最近的記錄列表
- 空狀態警告訊息

### 修復 2: 改善錯誤處理
待實施 - 可選擇添加更詳細的 ModelContainer 建立日誌

---

## 下一步行動

1. **立即執行**:
   - [ ] 提交當前的日誌增強代碼
   - [ ] 重新運行 App 測試
   - [ ] 記錄新的 Console 輸出

2. **如果問題持續**:
   - [ ] 實施原因 3 的詳細日誌方案
   - [ ] 檢查資料庫檔案是否存在
   - [ ] 考慮使用 Instruments 追蹤

3. **最終驗證**:
   - [ ] 確認資料持久化正常
   - [ ] 更新 SwiftData_Test_Results.md
   - [ ] 標記任務為完成

---

## 聯絡資訊

如果問題無法解決，請提供以下資訊：
- 完整的 Console 輸出
- Xcode 版本
- iOS 版本
- 是否使用模擬器或實機
- 錯誤截圖

---

**文件結束**
