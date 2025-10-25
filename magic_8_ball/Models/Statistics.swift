//
//  Statistics.swift
//  magic_8_ball
//
//  統計資料模型和計算邏輯
//

import Foundation
import SwiftData

/// 統計資料結構
struct Statistics {
    // MARK: - 基本統計
    let totalQuestions: Int              // 總提問數
    let positiveCount: Int               // 肯定答案數
    let neutralCount: Int                // 中性答案數
    let negativeCount: Int               // 否定答案數
    
    // MARK: - 百分比統計
    var positivePercentage: Double {
        totalQuestions > 0 ? Double(positiveCount) / Double(totalQuestions) * 100 : 0
    }
    
    var neutralPercentage: Double {
        totalQuestions > 0 ? Double(neutralCount) / Double(totalQuestions) * 100 : 0
    }
    
    var negativePercentage: Double {
        totalQuestions > 0 ? Double(negativeCount) / Double(totalQuestions) * 100 : 0
    }
    
    // MARK: - 時間統計
    let questionsToday: Int              // 今日提問數
    let questionsThisWeek: Int           // 本週提問數
    let averageQuestionsPerDay: Double   // 平均每日提問數
    let totalDaysUsed: Int               // 使用天數
    let firstQuestionDate: Date?         // 第一次提問日期
    let lastQuestionDate: Date?          // 最後提問日期
    
    // MARK: - 趨勢資料
    let dailyTrend: [DailyStatistic]     // 每日統計（過去 7 天）
    let weeklyTrend: [DailyStatistic]    // 每週統計（過去 30 天）
    
    // MARK: - 時段分析
    let questionsByHour: [Int: Int]      // 按小時統計 (0-23)
    let questionsByDayOfWeek: [Int: Int] // 按星期統計 (1-7)
    
    // MARK: - 熱門答案
    let topAnswers: [AnswerStatistic]    // Top 10 熱門答案
    
    // MARK: - 計算統計資料
    static func calculate(from records: [AnswerRecord]) -> Statistics {
        let calendar = Calendar.current
        let now = Date()
        
        // 基本統計
        let totalQuestions = records.count
        let positiveCount = records.filter { $0.answerType == .positive }.count
        let neutralCount = records.filter { $0.answerType == .neutral }.count
        let negativeCount = records.filter { $0.answerType == .negative }.count
        
        // 今日提問
        let startOfToday = calendar.startOfDay(for: now)
        let questionsToday = records.filter { $0.timestamp >= startOfToday }.count
        
        // 本週提問
        let startOfWeek = calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: now).date ?? now
        let questionsThisWeek = records.filter { $0.timestamp >= startOfWeek }.count
        
        // 使用天數和平均值
        let dates = Set(records.map { calendar.startOfDay(for: $0.timestamp) })
        let totalDaysUsed = dates.count
        let averageQuestionsPerDay = totalDaysUsed > 0 ? Double(totalQuestions) / Double(totalDaysUsed) : 0
        
        // 第一次和最後提問日期
        let sortedRecords = records.sorted { $0.timestamp < $1.timestamp }
        let firstQuestionDate = sortedRecords.first?.timestamp
        let lastQuestionDate = sortedRecords.last?.timestamp
        
        // 過去 7 天趨勢
        let dailyTrend = calculateDailyTrend(records: records, days: 7)
        
        // 過去 30 天趨勢
        let weeklyTrend = calculateDailyTrend(records: records, days: 30)
        
        // 按小時統計
        var questionsByHour: [Int: Int] = [:]
        for record in records {
            let hour = calendar.component(.hour, from: record.timestamp)
            questionsByHour[hour, default: 0] += 1
        }
        
        // 按星期統計 (1=週日, 2=週一, ..., 7=週六)
        var questionsByDayOfWeek: [Int: Int] = [:]
        for record in records {
            let weekday = calendar.component(.weekday, from: record.timestamp)
            questionsByDayOfWeek[weekday, default: 0] += 1
        }
        
        // 熱門答案統計
        let topAnswers = calculateTopAnswers(records: records)
        
        return Statistics(
            totalQuestions: totalQuestions,
            positiveCount: positiveCount,
            neutralCount: neutralCount,
            negativeCount: negativeCount,
            questionsToday: questionsToday,
            questionsThisWeek: questionsThisWeek,
            averageQuestionsPerDay: averageQuestionsPerDay,
            totalDaysUsed: totalDaysUsed,
            firstQuestionDate: firstQuestionDate,
            lastQuestionDate: lastQuestionDate,
            dailyTrend: dailyTrend,
            weeklyTrend: weeklyTrend,
            questionsByHour: questionsByHour,
            questionsByDayOfWeek: questionsByDayOfWeek,
            topAnswers: topAnswers
        )
    }
    
    // MARK: - 輔助計算方法
    
    /// 計算每日趨勢
    private static func calculateDailyTrend(records: [AnswerRecord], days: Int) -> [DailyStatistic] {
        let calendar = Calendar.current
        let now = Date()
        
        var dailyStats: [DailyStatistic] = []
        
        for dayOffset in (0..<days).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) else { continue }
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
            
            let dayRecords = records.filter { $0.timestamp >= startOfDay && $0.timestamp < endOfDay }
            
            dailyStats.append(DailyStatistic(
                date: startOfDay,
                count: dayRecords.count,
                positiveCount: dayRecords.filter { $0.answerType == .positive }.count,
                neutralCount: dayRecords.filter { $0.answerType == .neutral }.count,
                negativeCount: dayRecords.filter { $0.answerType == .negative }.count
            ))
        }
        
        return dailyStats
    }
    
    /// 計算熱門答案
    private static func calculateTopAnswers(records: [AnswerRecord]) -> [AnswerStatistic] {
        var answerCounts: [String: (count: Int, type: AnswerType)] = [:]
        
        for record in records {
            if let existing = answerCounts[record.answer] {
                answerCounts[record.answer] = (existing.count + 1, existing.type)
            } else {
                answerCounts[record.answer] = (1, record.answerType)
            }
        }
        
        return answerCounts
            .map { AnswerStatistic(answer: $0.key, count: $0.value.count, type: $0.value.type) }
            .sorted { $0.count > $1.count }
            .prefix(10)
            .map { $0 }
    }
}

// MARK: - 支援資料結構

/// 每日統計資料
struct DailyStatistic: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
    let positiveCount: Int
    let neutralCount: Int
    let negativeCount: Int
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
    
    var weekdayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        formatter.locale = Locale(identifier: "zh_TW")
        return formatter.string(from: date)
    }
}

/// 答案統計資料
struct AnswerStatistic: Identifiable {
    let id = UUID()
    let answer: String
    let count: Int
    let type: AnswerType
    
    var percentage: Double {
        // 這個會在外部計算時使用總數
        0
    }
}

/// 時段統計資料
struct HourStatistic: Identifiable {
    let id = UUID()
    let hour: Int
    let count: Int
    
    var hourString: String {
        "\(hour):00"
    }
}

/// 星期統計資料
struct WeekdayStatistic: Identifiable {
    let id = UUID()
    let weekday: Int  // 1=週日, 2=週一, ..., 7=週六
    let count: Int
    
    var weekdayString: String {
        let weekdays = ["週日", "週一", "週二", "週三", "週四", "週五", "週六"]
        return weekdays[weekday - 1]
    }
    
    var weekdayShort: String {
        let weekdays = ["日", "一", "二", "三", "四", "五", "六"]
        return weekdays[weekday - 1]
    }
}
