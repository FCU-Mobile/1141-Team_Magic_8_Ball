//
//  magic_8_ball_widget.swift
//  magic_8_ball_widget
//
//  Created by YuehBenjamin on 2025/10/21.
//

import WidgetKit
import SwiftUI
import SwiftData
import AppIntents

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), answer: "點擊八號球獲得答案")
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        // 從 UserDefaults 讀取最新答案
        let answer = getLatestAnswer()
        return SimpleEntry(date: Date(), configuration: configuration, answer: answer)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        // 從 UserDefaults 讀取最新答案
        let answer = getLatestAnswer()
        let entry = SimpleEntry(date: Date(), configuration: configuration, answer: answer)
        // 使用 .never 策略，只在 Intent 執行後刷新
        return Timeline(entries: [entry], policy: .never)
    }
    
    // 從 UserDefaults 讀取最新的答案
    private func getLatestAnswer() -> String {
        let defaults = UserDefaults.standard
        if let answer = defaults.string(forKey: "LatestWidgetAnswer") {
            print("✅ Widget讀取答案: \(answer)")
            return answer
        }
        return "點擊八號球獲得答案"
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let answer: String
}

struct magic_8_ball_widgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            switch family {
            case .systemMedium:
                // 中尺寸：橫向佈局，球在左邊，字在右邊
                HStack(spacing: 16) {
                    Button(intent: RandomAnswerIntent()) {
                        ZStack {
                            Circle()
                                .fill(Color.black)
                                .frame(width: 80, height: 80)
                                .shadow(radius: 8)
                            Circle()
                                .fill(Color.white)
                                .frame(width: 36, height: 36)
                            Text("8")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    Text(entry.answer)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.sRGB, red: 40/255, green: 0/255, blue: 60/255, opacity: 1))
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .transition(.scale.combined(with: .opacity))
                        .id(entry.answer)
                }
                .padding()
                
            case .systemLarge:
                // 大尺寸：垂直佈局，球和字都放大
                VStack(spacing: 20) {
                    Button(intent: RandomAnswerIntent()) {
                        ZStack {
                            Circle()
                                .fill(Color.black)
                                .frame(width: 120, height: 120)
                                .shadow(radius: 10)
                            Circle()
                                .fill(Color.white)
                                .frame(width: 54, height: 54)
                            Text("8")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    Text(entry.answer)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color(.sRGB, red: 40/255, green: 0/255, blue: 60/255, opacity: 1))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .lineLimit(4)
                        .transition(.scale.combined(with: .opacity))
                        .id(entry.answer)
                }
                .padding()
                
            default:
                // 預設（不應該執行到這裡）
                EmptyView()
            }
        }
        .containerBackground(for: .widget) {
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color(red: 0.85, green: 0.8, blue: 1.0)]),
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

struct magic_8_ball_widget: Widget {
    let kind: String = "magic_8_ball_widget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            magic_8_ball_widgetEntryView(entry: entry)
        }
        .configurationDisplayName("Magic 8 Ball")
        .description("點擊八號球獲得占卜答案")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

#Preview(as: .systemSmall) {
    magic_8_ball_widget()
} timeline: {
    SimpleEntry(date: .now, configuration: ConfigurationAppIntent(), answer: "這是必然")
}
