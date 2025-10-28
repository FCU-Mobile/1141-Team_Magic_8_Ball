//
//  Magic8BallView.swift
//  magic_8_ball
//
//  神奇八號球主視圖
//

import SwiftUI
import SwiftData

// MARK: - Environment Key for currentUser
private struct CurrentUserKey: EnvironmentKey {
    static let defaultValue: User? = nil
}

extension EnvironmentValues {
    var currentUser: User? {
        get { self[CurrentUserKey.self] }
        set { self[CurrentUserKey.self] = newValue }
    }
}

struct Magic8BallView: View {
    // SwiftData 查詢
    @Query private var users: [User]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.currentUser) private var currentUser

    @State private var question = ""
    @State private var currentAnswer: (AnswerType, String, String) = (.neutral, "", "")
    @State private var showAnswer = false
    @State private var showUserCreation = false

    // 錯誤處理
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
//                Text(personalizedGreeting)
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)

                VStack(alignment: .leading, spacing: 8) {
                    Text(personalizedGreeting)
                        .font(.headline)
                        .foregroundColor(.primary)

                    TextField("在這裡輸入你的問題...", text: $question)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.body)
                }
                .padding(.horizontal)

                // 八號球
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
            .navigationTitle("神奇八號球")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // 檢查是否需要顯示用戶建立畫面
                if users.isEmpty {
                    showUserCreation = true
                }

                // 測試用詳細日誌
                print("=== SwiftData 狀態檢查 ===")
                print("📊 用戶數量: \(users.count)")

                if let user = users.first {
                    print("👤 用戶資訊:")
                    print("   - ID: \(user.id)")
                    print("   - 名稱: \(user.name)")
                    print("   - 建立時間: \(user.createdAt)")
                    print("   - 記錄數量: \(user.records.count)")
                } else {
                    print("⚠️ 沒有找到用戶")
                }
                print("========================")
            }
            .sheet(isPresented: $showUserCreation) {
                UserCreationView()
            }
            .alert("錯誤", isPresented: $showError) {
                Button("確定", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Computed Properties

    /// 個人化問候語
    private var personalizedGreeting: String {
        if let user = users.first {
            return "\(user.name)，問一個問題，點擊按鈕獲得答案"
        } else {
            return "問一個問題，點擊按鈕獲得答案"
        }
    }

    // MARK: - 功能函數

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
        // 直接使用查詢到的第一個用戶
        guard let user = users.first else {
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
            print("✅ 答案記錄已儲存到 SwiftData")
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

// MARK: - 三角形形狀

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
    // 取用預設用戶
    let previewUser = User(name: "預覽用戶")
    Magic8BallView()
        .environment(\.currentUser, previewUser)
        .modelContainer(for: [User.self, AnswerRecord.self], inMemory: true)
}
