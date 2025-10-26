//
//  TrendChartView.swift
//  magic_8_ball
//
//  提問趨勢折線圖
//

import SwiftUI
import Charts

struct TrendChartView: View {
    let statistics: Statistics
    @State private var selectedPeriod: TrendPeriod = .week
    
    enum TrendPeriod: String, CaseIterable {
        case week = "7 天"
        case month = "30 天"
    }
    
    private var chartData: [DailyStatistic] {
        switch selectedPeriod {
        case .week:
            return statistics.dailyTrend
        case .month:
            return statistics.weeklyTrend
        }
    }
    
    private var maxCount: Int {
        chartData.map { $0.count }.max() ?? 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 標題和期間選擇器
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.blue)
                Text("提問趨勢")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                // 期間選擇器
                Picker("期間", selection: $selectedPeriod) {
                    ForEach(TrendPeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 140)
            }
            
            if chartData.isEmpty || statistics.totalQuestions == 0 {
                // 空狀態
                EmptyChartView(message: "還沒有足夠的資料")
            } else {
                VStack(spacing: 8) {
                    // 折線圖
                    Chart {
                        ForEach(chartData) { stat in
                            // 面積圖
                            AreaMark(
                                x: .value("日期", stat.date),
                                y: .value("數量", stat.count)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue.opacity(0.3), .blue.opacity(0.05)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            
                            // 折線
                            LineMark(
                                x: .value("日期", stat.date),
                                y: .value("數量", stat.count)
                            )
                            .foregroundStyle(.blue)
                            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                            
                            // 數據點
                            PointMark(
                                x: .value("日期", stat.date),
                                y: .value("數量", stat.count)
                            )
                            .foregroundStyle(.blue)
                            .symbolSize(60)
                        }
                    }
                    .chartYScale(domain: 0...(maxCount + 1))
                    .chartXAxis {
                        AxisMarks(values: .stride(by: selectedPeriod == .week ? .day : .day, count: selectedPeriod == .week ? 1 : 5)) { value in
                            if let date = value.as(Date.self) {
                                AxisValueLabel {
                                    VStack(spacing: 2) {
                                        Text(date, format: .dateTime.day())
                                            .font(.caption2)
                                        Text(date, format: .dateTime.month(.narrow))
                                            .font(.caption2)
                                    }
                                }
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    .frame(height: 200)
                    
                    // 統計摘要
                    HStack(spacing: 16) {
                        TrendStat(
                            label: "總計",
                            value: "\(chartData.map { $0.count }.reduce(0, +))",
                            icon: "sum"
                        )
                        
                        TrendStat(
                            label: "平均",
                            value: String(format: "%.1f", Double(chartData.map { $0.count }.reduce(0, +)) / Double(chartData.count)),
                            icon: "chart.bar.fill"
                        )
                        
                        TrendStat(
                            label: "最高",
                            value: "\(maxCount)",
                            icon: "arrow.up.circle.fill"
                        )
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
    }
}

// MARK: - 趨勢統計項目
struct TrendStat: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(uiColor: .systemBackground))
        )
    }
}

#Preview {
    ScrollView {
        TrendChartView(
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
                dailyTrend: (0..<7).map { i in
                    DailyStatistic(
                        date: Calendar.current.date(byAdding: .day, value: -i, to: Date())!,
                        count: Int.random(in: 1...8),
                        positiveCount: 2,
                        neutralCount: 2,
                        negativeCount: 2
                    )
                }.reversed(),
                weeklyTrend: [],
                questionsByHour: [:],
                questionsByDayOfWeek: [:],
                topAnswers: []
            )
        )
        .padding()
    }
}
