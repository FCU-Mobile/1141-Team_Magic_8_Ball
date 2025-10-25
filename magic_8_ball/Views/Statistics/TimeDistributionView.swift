//
//  TimeDistributionView.swift
//  magic_8_ball
//
//  時段分布圖表（按小時和星期）
//

import SwiftUI
import Charts

struct TimeDistributionView: View {
    let statistics: Statistics
    @State private var selectedTab: DistributionType = .hour
    
    enum DistributionType: String, CaseIterable {
        case hour = "時段"
        case weekday = "星期"
    }
    
    // 小時統計資料
    private var hourData: [HourStatistic] {
        (0...23).map { hour in
            HourStatistic(hour: hour, count: statistics.questionsByHour[hour] ?? 0)
        }
    }
    
    // 星期統計資料
    private var weekdayData: [WeekdayStatistic] {
        (1...7).map { weekday in
            WeekdayStatistic(weekday: weekday, count: statistics.questionsByDayOfWeek[weekday] ?? 0)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 標題和切換器
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.orange)
                Text("時段分析")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                // 類型選擇器
                Picker("類型", selection: $selectedTab) {
                    ForEach(DistributionType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 140)
            }
            
            if statistics.totalQuestions == 0 {
                // 空狀態
                EmptyChartView(message: "還沒有任何提問記錄")
            } else {
                switch selectedTab {
                case .hour:
                    HourDistributionChart(data: hourData)
                case .weekday:
                    WeekdayDistributionChart(data: weekdayData)
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

// MARK: - 小時分布圖表
struct HourDistributionChart: View {
    let data: [HourStatistic]
    
    private var maxCount: Int {
        data.map { $0.count }.max() ?? 0
    }
    
    private var peakHour: Int? {
        data.max(by: { $0.count < $1.count })?.hour
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // 長條圖
            Chart(data) { stat in
                BarMark(
                    x: .value("時段", stat.hour),
                    y: .value("數量", stat.count)
                )
                .foregroundStyle(
                    stat.hour == peakHour ?
                    Color.orange.gradient :
                    Color.orange.opacity(0.5).gradient
                )
                .cornerRadius(4)
            }
            .chartXAxis {
                AxisMarks(values: [0, 6, 12, 18, 23]) { value in
                    if let hour = value.as(Int.self) {
                        AxisValueLabel {
                            Text("\(hour):00")
                                .font(.caption2)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(height: 180)
            
            // 統計資訊
            if let peak = peakHour, let peakData = data.first(where: { $0.hour == peak }) {
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    
                    Text("最活躍時段：\(peak):00 - \(peak):59")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(peakData.count) 次")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.orange.opacity(0.1))
                )
            }
        }
    }
}

// MARK: - 星期分布圖表
struct WeekdayDistributionChart: View {
    let data: [WeekdayStatistic]
    
    private var maxCount: Int {
        data.map { $0.count }.max() ?? 0
    }
    
    private var peakWeekday: Int? {
        data.max(by: { $0.count < $1.count })?.weekday
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // 長條圖
            Chart(data) { stat in
                BarMark(
                    x: .value("星期", stat.weekdayShort),
                    y: .value("數量", stat.count)
                )
                .foregroundStyle(
                    stat.weekday == peakWeekday ?
                    Color.purple.gradient :
                    Color.purple.opacity(0.5).gradient
                )
                .cornerRadius(4)
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(height: 180)
            
            // 統計資訊
            if let peak = peakWeekday, let peakData = data.first(where: { $0.weekday == peak }) {
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.purple)
                        .font(.caption)
                    
                    Text("最活躍日：星期\(peakData.weekdayShort)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(peakData.count) 次")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.purple)
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.purple.opacity(0.1))
                )
            }
        }
    }
}

#Preview {
    ScrollView {
        TimeDistributionView(
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
                questionsByHour: [
                    9: 5, 10: 7, 11: 3, 12: 2, 13: 4,
                    14: 6, 15: 8, 16: 5, 17: 3, 18: 2
                ],
                questionsByDayOfWeek: [
                    1: 3, 2: 8, 3: 7, 4: 10, 5: 9, 6: 5, 7: 3
                ],
                topAnswers: []
            )
        )
        .padding()
    }
}
