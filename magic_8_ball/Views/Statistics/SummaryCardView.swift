//
//  SummaryCardView.swift
//  magic_8_ball
//
//  統計摘要卡片視圖
//

import SwiftUI

struct SummaryCardView: View {
    let statistics: Statistics
    
    var body: some View {
        VStack(spacing: 16) {
            // 標題
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.blue)
                Text("統計概覽")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
            }
            
            // 統計卡片網格
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                // 總提問數
                StatCard(
                    icon: "bubble.left.and.bubble.right.fill",
                    title: "總提問",
                    value: "\(statistics.totalQuestions)",
                    subtitle: "次",
                    color: .blue
                )
                
                // 使用天數
                StatCard(
                    icon: "calendar.badge.clock",
                    title: "使用天數",
                    value: "\(statistics.totalDaysUsed)",
                    subtitle: "天",
                    color: .purple
                )
                
                // 今日提問
                StatCard(
                    icon: "star.fill",
                    title: "今日提問",
                    value: "\(statistics.questionsToday)",
                    subtitle: "次",
                    color: .orange
                )
                
                // 平均每日
                StatCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "平均每日",
                    value: String(format: "%.1f", statistics.averageQuestionsPerDay),
                    subtitle: "次",
                    color: .green
                )
            }
            
            // 答案類型快速統計
            HStack(spacing: 12) {
                QuickStatBadge(
                    color: .green,
                    label: "肯定",
                    count: statistics.positiveCount,
                    percentage: statistics.positivePercentage
                )
                
                QuickStatBadge(
                    color: .blue,
                    label: "中性",
                    count: statistics.neutralCount,
                    percentage: statistics.neutralPercentage
                )
                
                QuickStatBadge(
                    color: .red,
                    label: "否定",
                    count: statistics.negativeCount,
                    percentage: statistics.negativePercentage
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
    }
}

// MARK: - 統計卡片
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .systemBackground))
        )
    }
}

// MARK: - 快速統計徽章
struct QuickStatBadge: View {
    let color: Color
    let label: String
    let count: Int
    let percentage: Double
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text("\(count)")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(color)
            
            Text(String(format: "%.1f%%", percentage))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
        )
    }
}

#Preview {
    ScrollView {
        SummaryCardView(
            statistics: Statistics(
                totalQuestions: 45,
                positiveCount: 18,
                neutralCount: 15,
                negativeCount: 12,
                questionsToday: 3,
                questionsThisWeek: 12,
                averageQuestionsPerDay: 3.75,
                totalDaysUsed: 12,
                firstQuestionDate: Date(),
                lastQuestionDate: Date(),
                dailyTrend: [],
                weeklyTrend: [],
                questionsByHour: [:],
                questionsByDayOfWeek: [:],
                topAnswers: []
            )
        )
        .padding()
    }
}
