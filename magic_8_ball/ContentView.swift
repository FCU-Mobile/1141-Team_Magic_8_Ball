//
//  ContentView.swift
//  magic_8_ball
//
//

import SwiftUI
import SwiftData

struct ContentView: View {
    // SwiftData 查詢
    @Query private var users: [User]
    @Query(sort: \AnswerRecord.timestamp, order: .reverse)
    private var records: [AnswerRecord]
    @Environment(\.modelContext) private var modelContext
    
    @State private var question = ""
    @State private var currentAnswer: (AnswerType, String, String) = (.neutral, "", "")
    @State private var showAnswer = false
    @State private var showHistory = false
    @State private var showUserCreation = false
    
    // 錯誤處理
    @State private var showError = false
    @State private var errorMessage = ""
    
    /// 當前用戶（動態查詢）
    var currentUser: User? {
        users.first  // 因為限制僅 1 個用戶
    }
    
    var body: some View {
        VStack(spacing: 30) {
            // 標題和歷史記錄按鈕
            HStack {
                Spacer()
                
                Text("神奇八號球")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    showHistory = true
                }) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            Text("問一個問題，點擊按鈕獲得答案")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("你的問題：")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                TextField("在這裡輸入你的問題...", text: $question)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.body)
            }
            .padding(.horizontal)
            
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.black, Color.gray]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 200)
                    .shadow(radius: 10)
                
                if showAnswer {
                    Text("\(currentAnswer.1)\n\(currentAnswer.2)")
                        .font(.system(size: 18, weight: .bold))
                        .shadow(radius: 5)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(20)
                        .background(
                            EquilateralTriangle()
                                .stroke(Color.blue, lineWidth: 3)
                                .fill(currentAnswer.0.color.opacity(0.1))
                                .frame(width: 180, height: 180)
                                .rotationEffect(.degrees(180))
                        )
                        .transition(.scale)
                } else {
                    Text("８")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            // Ask button
            Button(action: getAnswer) {
                HStack {
                    Image(systemName: "sparkles")
                    Text("獲得答案")
                    Image(systemName: "sparkles")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 15)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(25)
                .shadow(radius: 5)
            }
            .disabled(question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
            
            if showAnswer {
                Button("再問一次") {
                    resetAnswer()
                }
                .font(.subheadline)
                .foregroundColor(.blue)
                .padding(.top, 10)
            }
            
            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(uiColor: .systemBackground),
                    Color(uiColor: .secondarySystemBackground)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .onAppear {
            // 檢查是否需要顯示用戶建立畫面
            if users.isEmpty {
                showUserCreation = true
            }
            
            // 測試用詳細日誌
            print("=== SwiftData 狀態檢查 ===")
            print("📊 用戶數量: \(users.count)")
            print("📊 記錄數量: \(records.count)")
            
            if let user = users.first {
                print("👤 用戶資訊:")
                print("   - ID: \(user.id)")
                print("   - 名稱: \(user.name)")
                print("   - 建立時間: \(user.createdAt)")
                print("   - 記錄數量: \(user.records.count)")
            } else {
                print("⚠️ 沒有找到用戶")
            }
            
            print("📝 最近的記錄:")
            if records.isEmpty {
                print("   ⚠️ 沒有任何記錄")
            } else {
                for (index, record) in records.prefix(3).enumerated() {
                    print("   \(index + 1). \(record.question) → \(record.answer)")
                }
            }
            print("========================")
        }
        .sheet(isPresented: $showUserCreation) {
            UserCreationView()
        }
        .sheet(isPresented: $showHistory) {
            HistoryView()
        }
        .alert("錯誤", isPresented: $showError) {
            Button("確定", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private func getAnswer() {
        withAnimation(.easeOut(duration: 0.5)) {
            showAnswer = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            currentAnswer = AnswerType.allAnswers.randomElement() ?? (.neutral, "請再試一次", "Please try again")
            
            // 儲存到 SwiftData
            saveAnswer(question: question, answer: currentAnswer.1, answerType: currentAnswer.0)
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showAnswer = true
            }
        }
    }
    
    /// 儲存答案到 SwiftData
    private func saveAnswer(question: String, answer: String, answerType: AnswerType) {
        // 確保有用戶才儲存
        guard let user = currentUser else {
            print("⚠️ 無法儲存：尚未建立用戶")
            errorMessage = "無法儲存記錄：尚未建立用戶"
            showError = true
            return
        }
        
        do {
            let record = AnswerRecord(
                question: question,
                answer: answer,
                answerType: answerType,
                user: user
            )
            modelContext.insert(record)
            try modelContext.save()
            print("✅ 答案記錄已儲存")
        } catch {
            print("❌ 儲存失敗: \(error.localizedDescription)")
            errorMessage = "儲存失敗: \(error.localizedDescription)"
            showError = true
        }
    }
    
    private func resetAnswer() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showAnswer = false
        }
        question = ""
    }
}

// 新增歷史記錄視圖
struct HistoryView: View {
    @Query(sort: \AnswerRecord.timestamp, order: .reverse)
    private var records: [AnswerRecord]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    /// 根據答案類型返回顏色
    private func colorForAnswerType(_ type: AnswerType) -> Color {
        return type.color
    }
}

struct EquilateralTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // 半徑
        let radius = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        // 計算三個頂點
        let angle = Double.pi * 2 / 3  // 120度 (等邊三角形)
        let points: [CGPoint] = (0..<3).map { i in
            let theta = Double(i) * angle - Double.pi / 2  // 讓一個頂點朝上
            return CGPoint(
                x: center.x + CGFloat(cos(theta)) * radius,
                y: center.y + CGFloat(sin(theta)) * radius
            )
        }
        
        // 畫三角形
        path.move(to: points[0])
        path.addLine(to: points[1])
        path.addLine(to: points[2])
        path.addLine(to: points[0])
        
        return path
    }
}

#Preview {
    ContentView()
}
