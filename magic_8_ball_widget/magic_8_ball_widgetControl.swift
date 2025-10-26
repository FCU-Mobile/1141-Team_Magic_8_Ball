//
//  magic_8_ball_widgetControl.swift
//  magic_8_ball_widget
//
//  Created by YuehBenjamin on 2025/10/21.
//

import AppIntents
import SwiftUI
import WidgetKit

@available(iOSApplicationExtension 18.0, *)
struct magic_8_ball_widgetControl: ControlWidget {
    static let kind: String = "com.magic-8-ball.magic_8_ball_widget"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: Self.kind) {
            ControlWidgetButton(action: RandomAnswerIntent()) {
                Label("占卜", systemImage: "8.circle.fill")
            }
        }
        .displayName("Magic 8 Ball")
        .description("快速獲得占卜答案")
    }
}
