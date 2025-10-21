//
//  magic_8_ballApp.swift
//  magic_8_ball
//
//  Created by 林政佑 on 2025/8/4.
//

import SwiftUI
import SwiftData

@main
struct magic_8_ballApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: User.self)
        }
    }
}
