//
//  HistoryView.swift
//  magic_8_ball
//
//  歷史記錄視圖
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \AnswerRecord.timestamp, order: .reverse)
    private var records: [AnswerRecord]
    
    var body: some View {
        NavigationStack {
            VStack {
                if records.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("還沒有任何記錄")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Text("開始問問題來建立你的解答歷史吧！")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    Spacer()
                } else {
                    List {
                        ForEach(records) { record in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("問題：")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Text(record.timestamp, style: .time)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Text(record.question)
                                    .font(.body)
                                    .fontWeight(.medium)
                                
                                HStack {
                                    Circle()
                                        .fill(colorForAnswerType(record.answerType))
                                        .frame(width: 8, height: 8)
                                    
                                    Text(record.answer)
                                        .font(.body)
                                        .foregroundColor(colorForAnswerType(record.answerType))
                                }
                                .padding(.top, 4)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("解答記錄")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    /// 根據答案類型返回顏色
    private func colorForAnswerType(_ type: AnswerType) -> Color {
        return type.color
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: [User.self, AnswerRecord.self], inMemory: true)
}
