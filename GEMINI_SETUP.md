# 🔮 Gemini API 設定指南

## 📋 概述

本專案成功整合了 Google Gemini AI，為 Magic 8 Ball 提供個人化的占卜回應。用戶輸入問題後，系統會：

1. 首先顯示傳統的 Magic 8 Ball 答案
2. 同時調用 Gemini AI 生成專屬的個人化回應
3. 結合兩者提供更有意義的占卜體驗

## 🚀 快速設定

### 步驟 1: 取得 Gemini API Key

1. 前往 [Google AI Studio](https://makersuite.google.com/app/apikey)
2. 登入您的 Google 帳號
3. 點擊「Create API Key」或「Get API Key」
4. 複製生成的 API Key（格式類似：`AIzaSyDXXXXXXXXXXXXXXXXXXXXXXXXXXXX`）

### 步驟 2: 設定 API Key

**推薦方法：使用環境變數（最安全）**

1. **在 Xcode 中設定環境變數**：
   - 點擊 Xcode 左上角的 Scheme（顯示 "magic_8_ball"）
   - 選擇 "Edit Scheme..."
   - 在左側選擇 "Run"
   - 點擊 "Arguments" 標籤
   - 在 "Environment Variables" 區域點擊 "+"
   - 添加新的環境變數：
     - **Name**: `GEMINI_API_KEY`
     - **Value**: `AIzaSyDXXXXXXXXXXXXXXXXXXXXXXXXXXXX`（您的實際 API Key）

2. **確認設定成功**：環境變數會在每次運行應用程式時自動載入

**替代方法：**

如果不想使用環境變數，可以在 `GeminiAPIService.swift` 中硬編碼（僅開發用）：

```swift
self.apiKey = "AIzaSyDXXXXXXXXXXXXXXXXXXXXXXXXXXXX" // 您的實際 API Key
```

⚠️ **重要提醒**: 
- 環境變數方法最安全，不會意外提交到版本控制系統
- 硬編碼方法僅適用於開發測試，切勿用於生產環境

### 步驟 3: 編譯並測試

1. 在 Xcode 中編譯專案（⌘+B）
2. 運行應用程式（⌘+R）
3. 輸入一個問題，例如：「今天會是美好的一天嗎？」
4. 點擊「獲得答案」
5. 觀察以下行為：
   - 立即顯示傳統 Magic 8 Ball 答案
   - 出現載入動畫（三個跳動的圓點）
   - 數秒後顯示 AI 生成的個人化回應

### 步驟 4: 驗證功能正常

在 Xcode 控制台中，您應該看到類似的日誌：

**使用環境變數時**：
```
✅ 已從環境變數載入 Gemini API Key
🚀 正在呼叫 Gemini API...
📡 HTTP 狀態碼: 200
✅ API 回應解析成功
🎯 AI 生成內容: 親愛的神秘占卜師，宇宙的能量告訴我...
```

**未設定 API Key 時**：
```
⚠️ 未找到 API Key，請設定：
   推薦：在 Xcode Scheme 中設定環境變數 GEMINI_API_KEY
   或者：在 Info.plist 中添加 GEMINI_API_KEY
   或者：在此處直接填入（僅開發用）
```

## 🔧 功能特點

### AI 增強回應
- **個人化**: 使用用戶名稱個人化回應
- **情境感知**: 針對具體問題提供相關建議
- **語調一致**: 保持神秘占卜師的語調
- **適當長度**: 80-120 字的精練回應
- **表情符號**: 適當加入 emoji 增加趣味性

### 用戶體驗
- **即時反饋**: 先顯示傳統答案，再補充 AI 內容
- **載入動畫**: 三個跳動圓點視覺化 AI 思考過程
- **優雅降級**: API 失敗時仍顯示傳統答案並友善提示
- **錯誤提示**: 顯示「✨ 神秘的力量暫時不穩定」

### 技術實作
- **非同步處理**: 使用 async/await 避免阻塞 UI
- **完整錯誤處理**: 網路錯誤、API 錯誤、解析錯誤
- **狀態管理**: 載入中、完成、錯誤狀態
- **SwiftUI 動畫**: 流暢的狀態轉換動畫

## 🛠 除錯指南

### 常見問題與解決方案

#### 1. 顯示「請設定 Gemini API Key」
**原因**: API Key 未設定或為空
**解決方案**:
- 確認在 `GeminiAPIService.swift` 中正確填入 API Key
- 檢查 API Key 格式是否正確（應以 `AIzaSy` 開頭）

#### 2. 顯示「✨ 神秘的力量暫時不穩定」
**原因**: API 調用失敗
**可能原因**:
- 網路連線問題
- API Key 無效或過期
- API 使用額度已滿
- Gemini API 服務暫時不可用

**解決步驟**:
1. 檢查網路連線
2. 確認 API Key 在 Google AI Studio 中顯示為有效
3. 查看 Xcode 控制台的詳細錯誤訊息
4. 檢查 API 使用限制

#### 3. 載入動畫持續很久
**原因**: API 回應時間較長
**正常情況**: 通常 2-5 秒內會有回應
**如果超過 10 秒**: 可能是網路問題或 API 服務異常

### 除錯日誌說明

**成功載入日誌**：
```
✅ 已從環境變數載入 Gemini API Key
→ 從 Xcode Scheme 環境變數成功載入

✅ 已從 Info.plist 載入 Gemini API Key
→ 從 Info.plist 檔案成功載入

✅ 已使用硬編碼 API Key（請勿用於生產環境）
→ 使用程式碼中的 API Key
```

**錯誤或警告日誌**：
```
⚠️ 未找到 API Key，請設定：
→ 所有方法都未找到有效的 API Key

🚀 正在呼叫 Gemini API...
→ 開始 API 請求

📡 HTTP 狀態碼: 200
→ API 請求成功

❌ HTTP 狀態碼: 400
→ API 請求格式錯誤

❌ HTTP 狀態碼: 401
→ API Key 無效或過期

❌ HTTP 狀態碼: 429
→ API 使用額度已滿

✅ API 回應解析成功
→ 成功解析 AI 回應

🎯 AI 生成內容: [前50字...]
→ 顯示生成內容的前段
```

## 📊 使用限制

### Gemini API 免費額度
- **每分鐘**: 60 次請求
- **每天**: 1,500 次請求
- **每月**: 免費額度重置

### 請求限制
- 每次請求最多 30,000 字符
- 回應通常在 2-5 秒內完成
- 需要穩定的網路連線

## 🔐 安全建議

### 生產環境最佳實務

**1. 推薦：使用環境變數**
- ✅ 最安全的方法
- ✅ 不會意外提交到版本控制
- ✅ 易於 CI/CD 整合

**2. 使用 Info.plist（需小心處理）**
- 創建 Info.plist 並添加 `GEMINI_API_KEY`
- ⚠️ 確保將 Info.plist 加入 .gitignore

**3. 使用外部設定檔**
```swift
// 讀取不被版本控制的設定檔
if let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist"),
   let plist = NSDictionary(contentsOfFile: path),
   let key = plist["GEMINI_API_KEY"] as? String {
    self.apiKey = key
}
```

**4. 加入 .gitignore**:
```
# API Keys - 避免意外提交
APIKeys.plist
Config.plist
Secrets.swift
Info.plist
```

### 安全檢查清單
- [ ] **使用環境變數設定 API Key**（最推薦）
- [ ] API Key 不在程式碼中硬編碼（生產環境）
- [ ] 敏感檔案已加入 .gitignore
- [ ] 設定適當的 API 使用限制
- [ ] 定期輪換 API Key
- [ ] 監控 API 使用量
- [ ] 使用 HTTPS 連線（已預設）
- [ ] 團隊成員了解 API Key 安全重要性

## 📝 自訂選項

### 修改 AI 回應風格

在 `GeminiAPIService.swift` 的 `createPrompt` 方法中調整 prompt：

```swift
let prompt = """
你是一個神奇的占卜師，請根據以下資訊為 \(userName) 生成一個溫暖且有趣的占卜回應：

問題：\(question)
原始答案：\(chineseAnswer)

請用繁體中文回應，要求：
1. 融合原始答案的核心含義
2. 針對具體問題給出建議
3. 保持神秘而溫暖的占卜師語調
4. 長度控制在 80-120 字
5. 可以適當加入 emoji 增加趣味性
"""
```

### 調整載入動畫

在 `Magic8BallView.swift` 中修改動畫參數：

```swift
.animation(
    Animation.easeInOut(duration: 0.8)  // 調整速度
        .repeatForever()
        .delay(Double(index) * 0.3),    // 調整延遲
    value: answer.isLoading
)
```

## 🎉 測試範例

### 推薦測試問題
- 「今天會是美好的一天嗎？」
- 「我應該學習新的程式語言嗎？」
- 「這個專案會成功嗎？」
- 「明天的天氣會很好嗎？」

### 期望的 AI 回應範例
```
親愛的神秘占卜師，宇宙的能量告訴我這是一個充滿可能性的問題！✨ 
根據水晶球的指引，「穩了啦」的答案透露出強烈的正面訊號。
今天的星象顯示，只要你保持積極的心態，美好的事物會自然而然地
被你吸引過來。記住，快樂是一種選擇，而你今天選擇了光明！🌟
```

## 🆘 支援與協助

### 遇到問題時請：

1. **檢查 API Key 設定**:
   - 確認在 Xcode Scheme 環境變數中正確設定
   - 檢查 API Key 格式（應以 `AIzaSy` 開頭）
   - 確認沒有多餘的空格或隱藏字符

2. **檢查控制台日誌**: 查看詳細的錯誤訊息和載入狀態

3. **驗證 API Key**: 在 Google AI Studio 中確認狀態和權限

4. **測試網路連線**: 確保能正常訪問網際網路

5. **檢查使用額度**: 查看 API 使用量是否超限

### 聯絡資訊
- 專案 GitHub: [連結]
- 技術文件: [連結]
- Issue 回報: [連結]

---

*最後更新：2024年10月*
*版本：v1.0 - Gemini API 整合版*