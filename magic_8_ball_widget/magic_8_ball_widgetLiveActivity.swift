//
//  magic_8_ball_widgetLiveActivity.swift
//  magic_8_ball_widget
//
//  Created by YuehBenjamin on 2025/10/21.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct magic_8_ball_widgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // 運勢答案
        var answer: String
        var englishAnswer: String
    }
    // 固定屬性：用戶名稱或標題
    var name: String
}

struct magic_8_ball_widgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: magic_8_ball_widgetAttributes.self) { context in
            // Lock screen/banner UI
            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 44, height: 44)
                        .shadow(radius: 6)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                    Text("8")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                }
                Text("要不要看看今天運勢？")
                    .font(.headline)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .activityBackgroundTint(Color(.systemBackground))
            .activitySystemActionForegroundColor(Color.black)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    HStack(alignment: .center, spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Color.black)
                                .frame(width: 28, height: 28)
                            Circle()
                                .fill(Color.white)
                                .frame(width: 12, height: 12)
                            Text("8")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                        }
                        Text("要不要看看今天運勢？")
                            .font(.subheadline)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                    }
                }
            } compactLeading: {
                Text("8")
            } compactTrailing: {
                Text("")
            } minimal: {
                Text("8")
            }
            .widgetURL(URL(string: "magic8ball://fortune"))
            .keylineTint(Color.purple)
        }
    }
}

extension magic_8_ball_widgetAttributes {
    fileprivate static var preview: magic_8_ball_widgetAttributes {
        magic_8_ball_widgetAttributes(name: "World")
    }
}

extension magic_8_ball_widgetAttributes.ContentState {
    fileprivate static var fortune: magic_8_ball_widgetAttributes.ContentState {
        magic_8_ball_widgetAttributes.ContentState(answer: "展望良好", englishAnswer: "Outlook good")
    }
    fileprivate static var badLuck: magic_8_ball_widgetAttributes.ContentState {
        magic_8_ball_widgetAttributes.ContentState(answer: "很懷疑", englishAnswer: "Very doubtful")
    }
}

#Preview("Notification", as: .content, using: magic_8_ball_widgetAttributes.preview) {
   magic_8_ball_widgetLiveActivity()
} contentStates: {
    magic_8_ball_widgetAttributes.ContentState.fortune
    magic_8_ball_widgetAttributes.ContentState.badLuck
}
