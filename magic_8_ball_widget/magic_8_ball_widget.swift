//
//  magic_8_ball_widget.swift
//  magic_8_ball_widget
//
//  Created by YuehBenjamin on 2025/10/21.
//

import WidgetKit
import SwiftUI
import AppIntents

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), answer: "點擊八號球獲得答案", englishAnswer: "Tap the 8-ball for an answer")
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let random = RandomAnswerIntent.answers.randomElement() ?? ("這是必然", "It is certain")
        return SimpleEntry(date: Date(), configuration: configuration, answer: random.0, englishAnswer: random.1)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let random = RandomAnswerIntent.answers.randomElement() ?? ("這是必然", "It is certain")
            let entry = SimpleEntry(date: entryDate, configuration: configuration, answer: random.0, englishAnswer: random.1)
            entries.append(entry)
        }
        return Timeline(entries: entries, policy: .atEnd)
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let answer: String
    let englishAnswer: String
}

struct magic_8_ball_widgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(spacing: 12) {
            Button(intent: RandomAnswerIntent()) {
                ZStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 70, height: 70)
                        .shadow(radius: 8)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 32, height: 32)
                    Text("8")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                }
            }
            .buttonStyle(.plain)
            Text(entry.answer)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(Color(.sRGB, red: 40/255, green: 0/255, blue: 60/255, opacity: 1))
                .padding(.top, 5)
            Text(entry.englishAnswer)
                .font(.footnote)
                .foregroundColor(Color(.sRGB, red: 40/255, green: 0/255, blue: 60/255, opacity: 0.7))
        }
        .padding()
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
    }
}

#Preview(as: .systemSmall) {
    magic_8_ball_widget()
} timeline: {
    SimpleEntry(date: .now, configuration: ConfigurationAppIntent(), answer: "這是必然", englishAnswer: "It is certain")
}
