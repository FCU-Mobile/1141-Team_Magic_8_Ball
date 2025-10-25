//
//  AnswerTypeChartView.swift
//  magic_8_ball
//
//  答案類型分布圓餅圖
//

import SwiftUI
import Charts

struct AnswerTypeChartView: View {
    let statistics: Statistics
    
    // 圖表資料
    private var chartData: [ChartData] {
        [
            ChartData(type: "肯定", count: statistics.positiveCount, color: .green),
            ChartData(type: "中性", count: statistics.neutralCount, color: .blue),
            ChartData(type: "否定", count: statistics.negativeCount, color: .red)
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 標題
            HStack {
                Image(systemName: "chart.pie.fill")
                    .foregroundColor(.purple)
                Text("答案類型分布")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
            }
            
            if statistics.totalQuestions == 0 {
                // 空狀態
                EmptyChartView(message: "還沒有任何提問記錄")
            } else {
                HStack(spacing: 20) {
                    // 圓餅圖
                    Chart(chartData) { item in
                        SectorMark(
                            angle: .value("Count", item.count),
                            innerRadius: .ratio(0.5),  // 甜甜圈效果
                            angularInset: 2
                        )
                        .foregroundStyle(item.color)
                        .cornerRadius(4)
                    }
                    .frame(width: 140, height: 140)
                    .chartBackground { _ in
                        VStack(spacing: 2) {
                            Text("\(statistics.totalQuestions)")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("總提問")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // 圖例
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(chartData) { item in
                            LegendItem(
                                color: item.color,
                                label: item.type,
                                count: item.count,
                                percentage: Double(item.count) / Double(statistics.totalQuestions) * 100
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
    }
}

// MARK: - 圖表資料結構
private struct ChartData: Identifiable {
    let id = UUID()
    let type: String
    let count: Int
    let color: Color
}

// MARK: - 圖例項目
struct LegendItem: View {
    let color: Color
    let label: String
    let count: Int
    let percentage: Double
    
    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 16, height: 16)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 4) {
                    Text("\(count) 次")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(String(format: "%.1f%%", percentage))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
    }
}

#Preview {
    ScrollView {
        AnswerTypeChartView(
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
