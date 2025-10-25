# Magic 8 Ball - 神奇八號球 iOS App 🎱

> 一個使用 SwiftUI 和 SwiftData 開發的現代化占卜應用程式

## 📋 專案簡介

Magic 8 Ball 是一款互動式占卜應用程式，讓使用者提出問題並獲得神秘的答案。應用程式使用 SwiftData 框架進行資料持久化，記錄所有占卜歷史，並提供優雅的使用者介面和流暢的動畫效果。

### ✨ 主要功能

- 🔮 **占卜功能**：輸入問題，搖動神奇八號球獲得答案
- 📝 **歷史記錄**：自動保存所有占卜問答，方便回顧
- 👤 **使用者管理**：首次啟動時建立個人帳號
- 💾 **資料持久化**：使用 SwiftData 本地儲存所有資料
- 🎨 **精美介面**：動畫效果、漸層色彩、響應式設計
- ⚠️ **錯誤處理**：完善的錯誤處理與使用者提示機制

### 🎯 答案分類

- **肯定類 (綠色)**：10 種正面答案
- **否定類 (紅色)**：5 種否定答案  
- **中性類 (藍色)**：5 種模糊答案

共 20 種不同的中英文對照答案。

---

## 📂 專案結構

```
1141-Team_Magic_8_Ball/
│
├── magic_8_ball.xcodeproj/          # Xcode 專案檔案
│   ├── project.pbxproj              # 專案設定檔
│   └── xcshareddata/                # 共享資料
│
├── magic_8_ball/                    # 主要程式碼目錄
│   │
│   ├── magic_8_ballApp.swift       # 🎯 應用程式進入點
│   │                                # - 初始化 SwiftData ModelContainer
│   │                                # - 註冊資料模型 (User, AnswerRecord)
│   │                                # - 錯誤處理與 DatabaseErrorView 顯示
│   │
│   ├── ContentView.swift            # 📱 主視圖進入點
│   │                                # - 呼叫 MainTabView 作為根視圖
│   │
│   ├── Models/                      # 📊 資料模型層
│   │   │
│   │   ├── User.swift               # 👤 使用者資料模型
│   │   │                            # - @Model 標記 SwiftData 模型
│   │   │                            # - 屬性：id, name, birthday, gender
│   │   │                            # - 關聯：一對多 AnswerRecord (cascade delete)
│   │   │
│   │   ├── AnswerRecord.swift       # 📝 占卜記錄模型
│   │   │                            # - 記錄每次占卜的問題與答案
│   │   │                            # - 屬性：id, question, answer, answerType, timestamp
│   │   │                            # - 關聯：多對一 User
│   │   │
│   │   └── AnswerType.swift         # 🎲 答案類型枚舉
│   │                                # - 三種類型：positive, negative, neutral
│   │                                # - 包含所有 20 種預設答案 (中英文對照)
│   │                                # - 定義對應顏色 (綠/紅/藍)
│   │
│   ├── Views/                       # 🖼️ 使用者介面層
│   │   │
│   │   ├── MainTabView.swift        # 📑 主標籤視圖
│   │   │                            # - TabView 底部導航
│   │   │                            # - 兩個標籤：占卜 & 記錄
│   │   │
│   │   ├── Magic8BallView.swift    # 🎱 神奇八號球主畫面
│   │   │                            # - 問題輸入介面
│   │   │                            # - 八號球動畫與答案顯示
│   │   │                            # - 將答案儲存至 SwiftData
│   │   │                            # - 自動觸發 UserCreationView (首次啟動)
│   │   │
│   │   ├── HistoryView.swift        # 📜 歷史記錄視圖
│   │   │                            # - 顯示所有占卜記錄
│   │   │                            # - 按時間倒序排列
│   │   │                            # - 依答案類型顯示不同顏色
│   │   │
│   │   ├── UserCreationView.swift  # 👥 使用者建立畫面
│   │   │                            # - 首次啟動引導流程
│   │   │                            # - 輸入名稱、生日、性別
│   │   │                            # - 建立並儲存使用者資料
│   │   │
│   │   └── DatabaseErrorView.swift # ⚠️ 資料庫錯誤畫面
│   │                                # - ModelContainer 初始化失敗時顯示
│   │                                # - 提供解決方案與重啟提示
│   │
│   ├── Assets.xcassets/             # 🎨 資源檔案
│   │   ├── AppIcon.appiconset/      # 應用程式圖示
│   │   └── AccentColor.colorset/    # 主題色彩
│   │
│   ├── magic_8_ball.entitlements    # 🔐 應用程式權限設定
│   │
│   └── md/                          # 📚 專案文件
│       │
│       ├── SwiftData_Requirements.md     # SwiftData 需求規格
│       ├── SwiftData_MVP_Strategy.md     # MVP 開發策略
│       ├── SwiftData_Test_Results.md     # 測試結果報告
│       │
│       └── Reports/                      # 📋 開發報告
│           ├── Stage1_Completion_Report.md
│           ├── TabView_Navigation_Implementation.md
│           ├── Task_5.2_Test_Results.md
│           ├── Task_8.1_First_Launch_Test.md
│           ├── Cascade_Delete_Test.md
│           └── SwiftData_Todo.md
│
├── magic_8_ballTests/               # 🧪 單元測試
│   └── magic_8_ballTests.swift      # 測試案例
│
├── magic_8_ballUITests/             # 🖱️ UI 測試
│   ├── magic_8_ballUITests.swift
│   └── magic_8_ballUITestsLaunchTests.swift
│
├── .gitignore                       # Git 忽略檔案設定
├── .gitattributes                   # Git 屬性設定
└── README.md                        # 📖 本文件
```

---

## 🔧 技術架構

### 核心技術

- **語言**：Swift 5.9+
- **框架**：SwiftUI
- **資料持久化**：SwiftData
- **最低支援版本**：iOS 17.0+
- **開發工具**：Xcode 15.0+

### SwiftData 架構

#### 資料模型關係

```
User (使用者)
  └── @Relationship(cascade delete)
      └── AnswerRecord[] (占卜記錄)
            ├── question: String
            ├── answer: String
            ├── answerType: AnswerType
            └── timestamp: Date
```

#### 特性

- ✅ **唯一性約束**：User 和 AnswerRecord 的 id 使用 `@Attribute(.unique)`
- ✅ **級聯刪除**：刪除使用者時自動刪除所有相關記錄
- ✅ **反向關聯**：雙向關聯確保資料一致性
- ✅ **錯誤處理**：完善的 do-catch 錯誤處理機制

---

## 🚀 開始使用

### 環境需求

- macOS 14.0 (Sonoma) 或更新版本
- Xcode 15.0 或更新版本
- iOS 17.0+ 的實體裝置或模擬器

### 安裝步驟

1. **複製專案**
   ```bash
   git clone https://github.com/FCU-Mobile/1141-Team_Magic_8_Ball.git
   cd 1141-Team_Magic_8_Ball
   ```

2. **開啟專案**
   ```bash
   open magic_8_ball.xcodeproj
   ```

3. **選擇目標裝置**
   - 在 Xcode 中選擇模擬器或實體裝置

4. **建置並執行**
   - 按下 `⌘ + R` 或點擊 Run 按鈕

### 首次啟動流程

1. 應用程式啟動後會自動顯示「建立帳號」畫面
2. 輸入名稱（必填）
3. 選擇性輸入生日和性別
4. 點擊「建立帳號」完成設定
5. 開始使用占卜功能

---

## 📱 功能說明

### 1. 占卜功能 🎱

**位置**：主畫面「占卜」標籤

**操作步驟**：
1. 在輸入框輸入你的問題
2. 點擊「獲得答案」按鈕
3. 觀看八號球動畫並顯示答案
4. 點擊「再問一次」重置

**技術實現**：
- 使用 `withAnimation` 實現流暢的顯示/隱藏動畫
- 從 20 種預設答案中隨機選擇
- 自動儲存到 SwiftData
- 使用 `EquilateralTriangle` 自訂形狀顯示答案

### 2. 歷史記錄 📜

**位置**：底部「記錄」標籤

**功能**：
- 顯示所有占卜記錄
- 按時間倒序排列（最新在上）
- 依答案類型顯示對應顏色
- 顯示問題、答案、時間戳記

**技術實現**：
- 使用 `@Query(sort: \AnswerRecord.timestamp, order: .reverse)` 自動排序
- SwiftUI List 渲染
- 空狀態提示畫面

### 3. 使用者管理 👤

**功能**：
- 首次啟動自動觸發建立流程
- 儲存個人資訊（名稱、生日、性別）
- 資料僅存本機，保護隱私

**技術實現**：
- 使用 `.sheet(isPresented:)` 顯示模態畫面
- 檢查 `users.isEmpty` 判斷是否首次啟動
- DatePicker 日期選擇器
- Segmented Picker 性別選擇

---

## 🎨 設計特色

### 視覺元素

- **漸層背景**：藍紫色漸層營造神秘氛圍
- **八號球設計**：
  - 黑灰色漸層圓形
  - 中央數字 "８"
  - 答案顯示時轉換為三角形視窗
- **顏色系統**：
  - 🟢 綠色：肯定答案
  - 🔴 紅色：否定答案
  - 🔵 藍色：中性答案

### 動畫效果

- **淡入淡出**：答案顯示使用 `.easeOut` 和 `.spring` 動畫
- **縮放效果**：答案文字使用 `.scale` transition
- **按鈕互動**：按下時的視覺回饋
- **陰影效果**：增加深度感

---

## 🧪 測試

### 執行測試

```bash
# 執行所有測試
⌘ + U

# 或使用命令列
xcodebuild test -scheme magic_8_ball -destination 'platform=iOS Simulator,name=iPhone 15'
```

### 測試覆蓋

- ✅ SwiftData 模型初始化測試
- ✅ 使用者建立流程測試
- ✅ 級聯刪除功能測試
- ✅ 首次啟動流程測試
- ✅ UI 啟動測試

---

## 📝 開發紀錄

### 已完成功能

- ✅ SwiftData 資料模型設計與實作
- ✅ 使用者建立與管理
- ✅ 占卜功能與答案系統
- ✅ 歷史記錄顯示
- ✅ TabView 底部導航
- ✅ 錯誤處理機制
- ✅ 首次啟動引導
- ✅ 級聯刪除關聯
- ✅ iOS 17.0 部署目標設定

### 版本歷程

詳細的開發階段報告請參閱 `magic_8_ball/md/Reports/` 目錄。

---

## 🤝 貢獻指南

### 分支策略

- `main`：穩定版本分支
- `SwiftData`：功能開發分支
- 功能分支：`feature/功能名稱`

### 提交規範

```
<類型>: <簡短描述>

<詳細說明>

範例：
✅ 完成任務 7.3: 設定 iOS 17.0 Deployment Target
重構: 實作 TabView 底部導航
```

### Pull Request 流程

1. Fork 專案
2. 建立功能分支
3. 完成開發與測試
4. 提交 Pull Request
5. 等待 Code Review

---

## 📄 授權

本專案為 FCU Mobile 課程專案，僅供學習與教育用途。

---

## 👥 開發團隊

**Team Magic 8 Ball**

- 開發者：林政佑
- 機構：逢甲大學 (FCU)
- 課程：Mobile Application Development

---

## 📞 聯絡資訊

如有問題或建議，請透過以下方式聯繫：

- GitHub Issues: [提交 Issue](https://github.com/FCU-Mobile/1141-Team_Magic_8_Ball/issues)
- Pull Requests: [提交 PR](https://github.com/FCU-Mobile/1141-Team_Magic_8_Ball/pulls)

---

## 🔗 相關資源

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [Swift Programming Language](https://swift.org/documentation/)

---

<p align="center">
  Made with ❤️ by Team Magic 8 Ball
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Swift-5.9+-orange.svg" alt="Swift 5.9+">
  <img src="https://img.shields.io/badge/iOS-17.0+-blue.svg" alt="iOS 17.0+">
  <img src="https://img.shields.io/badge/Xcode-15.0+-blue.svg" alt="Xcode 15.0+">
  <img src="https://img.shields.io/badge/SwiftUI-✓-green.svg" alt="SwiftUI">
  <img src="https://img.shields.io/badge/SwiftData-✓-green.svg" alt="SwiftData">
</p>
