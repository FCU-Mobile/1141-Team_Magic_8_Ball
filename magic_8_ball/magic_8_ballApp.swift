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
        let schema = Schema([
            User.self,
            AnswerRecord.self
        ])
        
        do {
            // 嘗試使用 App Group 路徑
            if let appGroupURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: "group.magic8ball.shared"
            ) {
                let storeURL = appGroupURL.appendingPathComponent("magic8ball.sqlite")
                let modelConfiguration = ModelConfiguration(url: storeURL)
                let container = try ModelContainer(
                    for: schema,
                    configurations: [modelConfiguration]
                )
                print("✅ ModelContainer 建立成功，使用 App Group: \(storeURL.path)")
                return container
            } else {
                // 如果無法使用 App Group，使用預設路徑
                print("⚠️ 無法取得 App Group 容器，使用預設存儲位置")
                let container = try ModelContainer(for: schema)
                print("✅ ModelContainer 建立成功，使用預設路徑")
                return container
            }
        } catch {
            print("❌ ModelContainer 建立失敗: \(error.localizedDescription)")
            return nil
        }
    }()
    
    init() {
        // SwiftData 會自動處理首次啟動
        // 刪除 app 時，SwiftData 數據也會一併刪除
    }
    
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
