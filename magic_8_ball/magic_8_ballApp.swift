//
//  magic_8_ballApp.swift
//  magic_8_ball
//
//  Created by 林政佑 on 2025/8/4.
//

import SwiftUI
import SwiftData

@main
struct magic_8_ballApp: App {
    /// 共享的 ModelContainer，可選型以支援優雅的錯誤處理
    var sharedModelContainer: ModelContainer? = {
        // 定義 Schema，註冊所有資料模型
        let schema = Schema([
            User.self,
            AnswerRecord.self
        ])
        
        // 設定 ModelConfiguration
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        
        // 使用 do-catch 進行錯誤處理
        do {
            let container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            print("✅ ModelContainer 建立成功")
            return container
        } catch {
            // 記錄錯誤但不閃退
            print("❌ ModelContainer 建立失敗: \(error.localizedDescription)")
            return nil
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            // 根據 ModelContainer 初始化狀態顯示不同畫面
            if let container = sharedModelContainer {
                ContentView()
                    .modelContainer(container)
            } else {
                DatabaseErrorView()
            }
        }
    }
}

/// 資料庫錯誤畫面（暫時實作，階段二會完善）
struct DatabaseErrorView: View {
    var body: some View {
        Text("資料庫初始化失敗")
    }
}

