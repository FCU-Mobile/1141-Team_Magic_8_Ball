//
//  EmptyChartView.swift
//  magic_8_ball
//
//  空狀態圖表視圖
//

import SwiftUI

struct EmptyChartView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 40))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .systemBackground))
        )
    }
}

#Preview {
    EmptyChartView(message: "還沒有任何提問記錄")
        .padding()
}
