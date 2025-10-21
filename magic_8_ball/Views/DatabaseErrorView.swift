//
//  DatabaseErrorView.swift
//  magic_8_ball
//
//

import SwiftUI

/// 資料庫錯誤畫面
/// 當 ModelContainer 初始化失敗時顯示
struct DatabaseErrorView: View {
    var body: some View {
        VStack(spacing: 30) {
            // 錯誤圖示
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 80))
                .foregroundColor(.orange)
                .padding(.top, 60)
            
            // 錯誤標題
            Text("資料庫初始化失敗")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // 錯誤說明
            Text("無法啟動應用程式的資料庫系統")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            // 解決方案列表
            VStack(alignment: .leading, spacing: 15) {
                Text("可能的解決方案：")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                SolutionRow(
                    icon: "arrow.clockwise",
                    text: "重新啟動應用程式"
                )
                
                SolutionRow(
                    icon: "internaldrive",
                    text: "檢查裝置儲存空間是否足夠"
                )
                
                SolutionRow(
                    icon: "trash",
                    text: "嘗試重新安裝應用程式"
                )
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(uiColor: .secondarySystemBackground))
            )
            .padding(.horizontal, 30)
            
            Spacer()
            
            // 重新啟動按鈕
            Button(action: restartApp) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("重新啟動")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(15)
                .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
    }
    
    /// 重新啟動應用程式
    /// 注意：iOS 不允許程式化關閉應用程式，此方法提示用戶手動重啟
    private func restartApp() {
        // 在實際環境中，iOS 不允許程式自行關閉
        // 這個按鈕主要是提供用戶操作提示
        print("⚠️ 請手動關閉並重新開啟應用程式")
        
        // 可選：顯示提示訊息
        // 在實際應用中，可以使用 Alert 或其他 UI 提示用戶手動重啟
    }
}

/// 解決方案列項目
struct SolutionRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.blue)
                .frame(width: 30)
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    DatabaseErrorView()
}
