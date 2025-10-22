//
//  magic_8_ball_widgetBundle.swift
//  magic_8_ball_widget
//
//  Created by YuehBenjamin on 2025/10/21.
//

import WidgetKit
import SwiftUI

@main
struct magic_8_ball_widgetBundle: WidgetBundle {
    var body: some Widget {
        magic_8_ball_widget()
        if #available(iOSApplicationExtension 18.0, *) {
            magic_8_ball_widgetControl()
        }
        if #available(iOSApplicationExtension 16.1, *) {
            magic_8_ball_widgetLiveActivity()
        }
    }
}
