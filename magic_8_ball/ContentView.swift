//
//  ContentView.swift
//  magic_8_ball
//
//  主進入點 - 使用 TabView 底部導航
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MainTabView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [User.self, AnswerRecord.self], inMemory: true)
}
