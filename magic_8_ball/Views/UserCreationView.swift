//
//  UserCreationView.swift
//  magic_8_ball
//
//

import SwiftUI
import SwiftData

/// 用戶建立畫面
/// 首次啟動或無用戶時顯示，引導用戶建立帳號
struct UserCreationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // 表單欄位
    @State private var userName: String = ""
    @State private var selectedBirthday: Date?
    @State private var selectedGender: String?
    @State private var showBirthdayPicker: Bool = false
    
    // 錯誤處理
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    // 性別選項
    private let genderOptions = ["男", "女", "其他"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    // 標題區塊
                    VStack(spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .purple]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .padding(.top, 40)
                        
                        Text("建立你的帳號")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("讓 Magic 8 Ball 認識你")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    // 表單區塊
                    VStack(spacing: 20) {
                        // 名稱輸入（必填）
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Label("名稱", systemImage: "person.fill")
                                    .font(.headline)
                                Text("*")
                                    .foregroundColor(.red)
                                    .font(.headline)
                            }
                            
                            TextField("請輸入你的名稱", text: $userName)
                                .textFieldStyle(.roundedBorder)
                                .autocapitalization(.words)
                                .submitLabel(.done)
                        }
                        
                        // 生日選擇（可選）
                        VStack(alignment: .leading, spacing: 8) {
                            Label("生日", systemImage: "calendar")
                                .font(.headline)
                            
                            HStack {
                                if let birthday = selectedBirthday {
                                    Text(birthday, style: .date)
                                        .foregroundColor(.primary)
                                } else {
                                    Text("未設定")
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    showBirthdayPicker.toggle()
                                }) {
                                    Image(systemName: showBirthdayPicker ? "chevron.up" : "chevron.down")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(uiColor: .secondarySystemBackground))
                            )
                            
                            if showBirthdayPicker {
                                DatePicker(
                                    "選擇生日",
                                    selection: Binding(
                                        get: { selectedBirthday ?? Date() },
                                        set: { selectedBirthday = $0 }
                                    ),
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.graphical)
                                .labelsHidden()
                                
                                if selectedBirthday != nil {
                                    Button("清除生日") {
                                        selectedBirthday = nil
                                        showBirthdayPicker = false
                                    }
                                    .font(.caption)
                                    .foregroundColor(.red)
                                }
                            }
                        }
                        
                        // 性別選擇（可選）
                        VStack(alignment: .leading, spacing: 8) {
                            Label("性別", systemImage: "person.2.fill")
                                .font(.headline)
                            
                            Picker("選擇性別", selection: $selectedGender) {
                                Text("未設定").tag(nil as String?)
                                ForEach(genderOptions, id: \.self) { gender in
                                    Text(gender).tag(gender as String?)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                    .padding(.horizontal)
                    
                    // 說明文字
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text("生日和性別為可選項目，可稍後設定")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.green)
                            Text("你的資料僅儲存在本機裝置")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // 建立按鈕
                    Button(action: createUser) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("建立帳號")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: userName.isEmpty ? [.gray] : [.blue, .purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(15)
                        .shadow(color: userName.isEmpty ? .clear : .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .disabled(userName.isEmpty)
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .alert("建立失敗", isPresented: $showError) {
                Button("確定", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    /// 建立新用戶
    private func createUser() {
        // 驗證名稱不為空
        let trimmedName = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else {
            errorMessage = "請輸入名稱"
            showError = true
            return
        }
        
        // 建立用戶
        let user = User(
            name: trimmedName,
            birthday: selectedBirthday,
            gender: selectedGender
        )
        
        // 插入 ModelContext
        modelContext.insert(user)
        
        // 儲存到 SwiftData
        do {
            try modelContext.save()
            print("✅ 用戶建立成功: \(trimmedName)")
            
            // 關閉畫面
            dismiss()
        } catch {
            // 顯示錯誤
            errorMessage = "建立失敗: \(error.localizedDescription)"
            showError = true
            print("❌ 用戶建立失敗: \(error)")
        }
    }
}

// MARK: - Preview

#Preview {
    UserCreationView()
        .modelContainer(for: User.self, inMemory: true)
}
