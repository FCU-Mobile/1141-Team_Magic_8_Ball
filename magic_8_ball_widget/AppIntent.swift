//
//  AppIntent.swift
//  magic_8_ball_widget
//
//  Created by YuehBenjamin on 2025/10/21.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "This is an example widget." }

    @Parameter(title: "記錄點什麼吧", default: "😃")
    var favoriteEmoji: String
}
