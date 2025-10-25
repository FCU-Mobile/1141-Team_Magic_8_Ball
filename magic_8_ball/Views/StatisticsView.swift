//
//  StatisticsView.swift
//  magic_8_ball
//
//  統計頁面主視圖
//

import SwiftUI
import SwiftData

struct StatisticsView: View {
    @Query(sort: \AnswerRecord.timestamp, order: .reverse)
    private var records: [AnswerRecord]
    
    @State private var showInfoSheet = false
    
    // 計算統計資料
    private var statistics: Statistics {
        Statistics.calculate(from: records)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景漸層
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(uiColor: .systemBackground),
                        Color(uiColor: .secondarySystemBackground)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                if records.isEmpty {
                    // 空狀態
                    EmptyStateView()
                } else {
                    // 統計內容
                    ScrollView {
                        VStack(spacing: 20) {
                            // 摘要卡片
                            SummaryCardView(statistics: statistics)
                            
                            // 答案類型分布圓餅圖
                            AnswerTypeChartView(statistics: statistics)
                            
                            // 提問趨勢折線圖
                            TrendChartView(statistics: statistics)
                            
                            // 時段分布圖
                            TimeDistributionView(statistics: statistics)
                            
                            // 熱門答案排行
                            TopAnswersView(statistics: statistics)
                            
                            // 底部間距
                            Color.clear.frame(height: 20)
                        }
                        .padding()
                    }
                    .refreshable {
                        // 下拉刷新（自動重新計算）
                        await Task.sleep(500_000_000) // 0.5 秒
                    }
                }
            }
            .navigationTitle("統計分析")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showInfoSheet = true
                    }) {
                        Image(systemName: "info.circle")
                    }
                }
            }
            .sheet(isPresented: $showInfoSheet) {
                StatisticsInfoSheet(statistics: statistics)
            }
        }
    }
}

// MARK: - 空狀態視圖
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 24) {
            // 圖示
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
            }
            
            VStack(spacing: 12) {
                Text("還沒有統計資料")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("開始提問，建立你的占卜統計記錄吧！")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // 提示卡片
            VStack(alignment: .leading, spacing: 12) {
                Label("查看答案類型分布", systemImage: "chart.pie.fill")
                Label("追蹤提問趨勢", systemImage: "chart.line.uptrend.xyaxis")
                Label("分析活躍時段", systemImage: "clock.fill")
                Label("發現熱門答案", systemImage: "trophy.fill")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
            )
            .padding(.horizontal)
        }
        .padding()
    }
}

// MARK: - 統計資訊頁
struct StatisticsInfoSheet: View {
    let statistics: Statistics
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("關於統計") {
                    InfoRow(
                        icon: "info.circle.fill",
                        title: "統計說明",
                        description: "此頁面顯示您的占卜記錄統計分析"
                    )
                }
                
                Section("時間範圍") {
                    if let firstDate = statistics.firstQuestionDate {
                        InfoRow(
                            icon: "calendar.badge.plus",
                            title: "第一次提問",
                            description: firstDate.formatted(date: .long, time: .shortened)
                        )
                    }
                    
                    if let lastDate = statistics.lastQuestionDate {
                        InfoRow(
                            icon: "calendar.badge.clock",
                            title: "最近提問",
                            description: lastDate.formatted(date: .long, time: .shortened)
                        )
                    }
                    
                    InfoRow(
                        icon: "clock.arrow.circlepath",
                        title: "使用天數",
                        description: "\(statistics.totalDaysUsed) 天"
                    )
                }
                
                Section("圖表說明") {
                    InfoRow(
                        icon: "chart.pie.fill",
                        title: "答案類型分布",
                        description: "顯示肯定、中性、否定答案的比例"
                    )
                    
                    InfoRow(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "提問趨勢",
                        description: "過去 7 天或 30 天的每日提問數量變化"
                    )
                    
                    InfoRow(
                        icon: "clock.fill",
                        title: "時段分析",
                        description: "按小時或星期統計最活躍的提問時段"
                    )
                    
                    InfoRow(
                        icon: "trophy.fill",
                        title: "熱門答案",
                        description: "最常出現的答案排行榜"
                    )
                }
            }
            .navigationTitle("統計說明")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 資訊列
struct InfoRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    StatisticsView()
        .modelContainer(for: [User.self, AnswerRecord.self], inMemory: true)
}
