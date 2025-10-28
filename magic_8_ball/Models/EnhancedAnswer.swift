//
//  EnhancedAnswer.swift
//  magic_8_ball
//
//  增強的答案模型，結合原始答案和 AI 生成內容
//

import Foundation
import SwiftUI

/// 增強的答案結構
struct EnhancedAnswer {
    let originalAnswer: (AnswerType, String, String)
    let aiGeneratedContent: String?
    let isLoading: Bool
    let error: Error?

    /// 建立僅包含原始答案的實例
    static func original(_ answer: (AnswerType, String, String)) -> EnhancedAnswer {
        EnhancedAnswer(
            originalAnswer: answer,
            aiGeneratedContent: nil as String?,
            isLoading: false,
            error: nil as Error?
        )
    }

    /// 建立載入中的實例
    static func loading(_ answer: (AnswerType, String, String)) -> EnhancedAnswer {
        EnhancedAnswer(
            originalAnswer: answer,
            aiGeneratedContent: nil as String?,
            isLoading: true,
            error: nil as Error?
        )
    }

    /// 建立完成的實例
    static func completed(_ answer: (AnswerType, String, String), aiContent: String) -> EnhancedAnswer {
        EnhancedAnswer(
            originalAnswer: answer,
            aiGeneratedContent: aiContent,
            isLoading: false,
            error: nil as Error?
        )
    }

    /// 建立錯誤的實例
    static func failed(_ answer: (AnswerType, String, String), error: Error) -> EnhancedAnswer {
        EnhancedAnswer(
            originalAnswer: answer,
            aiGeneratedContent: nil as String?,
            isLoading: false,
            error: error
        )
    }
}
