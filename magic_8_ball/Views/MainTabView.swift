//
//  MainTabView.swift
//  magic_8_ball
//
//  主標籤視圖 - 底部導航
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            // 主畫面 - 神奇八號球
            Magic8BallView()
                .tabItem {
                    Label("占卜", systemImage: "8.circle.fill")
                }
            
            // 歷史記錄
            HistoryView()
                .tabItem {
                    Label("記錄", systemImage: "clock.arrow.circlepath")
                }
            
            // 統計分析
            StatisticsView()
                .tabItem {
                    Label("統計", systemImage: "chart.bar.fill")
                }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [User.self, AnswerRecord.self], inMemory: true)
}
