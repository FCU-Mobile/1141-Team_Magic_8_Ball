//
//  TopAnswersView.swift
//  magic_8_ball
//
//  熱門答案排行榜
//

import SwiftUI

struct TopAnswersView: View {
    let statistics: Statistics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 標題
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundColor(.yellow)
                Text("熱門答案排行")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
            }
            
            if statistics.topAnswers.isEmpty {
                // 空狀態
                EmptyChartView(message: "還沒有任何答案記錄")
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(statistics.topAnswers.prefix(10).enumerated()), id: \.element.id) { index, answer in
                        TopAnswerRow(
                            rank: index + 1,
                            answer: answer,
                            totalQuestions: statistics.totalQuestions
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

// MARK: - 答案排行項目
struct TopAnswerRow: View {
    let rank: Int
    let answer: AnswerStatistic
    let totalQuestions: Int
    
    private var percentage: Double {
        totalQuestions > 0 ? Double(answer.count) / Double(totalQuestions) * 100 : 0
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .secondary
        }
    }
    
    private var rankIcon: String {
        switch rank {
        case 1: return "crown.fill"
        case 2: return "medal.fill"
        case 3: return "medal.fill"
        default: return "\(rank).circle.fill"
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // 排名圖示
            ZStack {
                Circle()
                    .fill(rankColor.opacity(0.2))
                    .frame(width: 36, height: 36)
                
                if rank <= 3 {
                    Image(systemName: rankIcon)
                        .font(.system(size: 18))
                        .foregroundColor(rankColor)
                } else {
                    Text("\(rank)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(rankColor)
                }
            }
            
            // 答案內容
            VStack(alignment: .leading, spacing: 4) {
                Text(answer.answer)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                HStack(spacing: 6) {
                    // 類型標籤
                    HStack(spacing: 4) {
                        Circle()
                            .fill(answer.type.color)
                            .frame(width: 6, height: 6)
                        
                        Text(answer.type.rawValue)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("•")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("\(answer.count) 次")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // 百分比
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.1f%%", percentage))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(answer.type.color)
                
                // 百分比條
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.secondary.opacity(0.2))
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(answer.type.color)
                            .frame(width: geometry.size.width * (percentage / 100))
                    }
                }
                .frame(width: 50, height: 4)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .systemBackground))
        )
    }
}

#Preview {
    ScrollView {
        TopAnswersView(
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
                topAnswers: [
                    AnswerStatistic(answer: "很有可能", count: 8, type: .positive),
                    AnswerStatistic(answer: "現在無法預測", count: 7, type: .neutral),
                    AnswerStatistic(answer: "前景不太好", count: 6, type: .negative),
                    AnswerStatistic(answer: "是的", count: 5, type: .positive),
                    AnswerStatistic(answer: "待會再問", count: 4, type: .neutral),
                    AnswerStatistic(answer: "想的美", count: 3, type: .negative),
                    AnswerStatistic(answer: "肯定是的", count: 3, type: .positive),
                    AnswerStatistic(answer: "很可疑", count: 3, type: .negative)
                ]
            )
        )
        .padding()
    }
}
