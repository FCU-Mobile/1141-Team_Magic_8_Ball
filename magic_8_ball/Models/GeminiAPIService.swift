//
//  GeminiAPIService.swift
//  magic_8_ball
//
//  Gemini API 服務類別
//

import Foundation

/// Gemini API 回應結構
struct GeminiResponse: Codable {
    let candidates: [Candidate]

    struct Candidate: Codable {
        let content: Content

        struct Content: Codable {
            let parts: [Part]

            struct Part: Codable {
                let text: String
            }
        }
    }
}

/// Gemini API 請求結構
struct GeminiRequest: Codable {
    let contents: [Content]

    struct Content: Codable {
        let parts: [Part]

        struct Part: Codable {
            let text: String
        }
    }
}

/// Gemini API 錯誤類型
enum GeminiAPIError: LocalizedError {
    case invalidURL
    case noAPIKey
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "無效的 API URL"
        case .noAPIKey:
            return "請設定 Gemini API Key"
        case .invalidResponse:
            return "無效的 API 回應"
        case .networkError(let error):
            return "網路錯誤: \(error.localizedDescription)"
        case .decodingError(let error):
            return "資料解析錯誤: \(error.localizedDescription)"
        }
    }
}

/// Gemini API 服務類別
@MainActor
class GeminiAPIService: ObservableObject {
    static let shared = GeminiAPIService()

    // ⚠️ 請在 Info.plist 或環境變數中設定您的 API Key
    private let apiKey: String
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-lite:generateContent"

    private init() {
        // 方法1: 從環境變數讀取 (推薦，最簡單)
        if let envKey = ProcessInfo.processInfo.environment["GEMINI_API_KEY"],
           !envKey.isEmpty {
            self.apiKey = envKey
            print("✅ 已從環境變數載入 Gemini API Key")
        }
        // 方法2: 從 Info.plist 讀取
        else if let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
                let plist = NSDictionary(contentsOfFile: path),
                let key = plist["GEMINI_API_KEY"] as? String,
                !key.isEmpty && key != "YOUR_GEMINI_API_KEY_HERE" {
            self.apiKey = key
            print("✅ 已從 Info.plist 載入 Gemini API Key")
        }
        // 方法3: 開發測試用硬編碼
        else {
            self.apiKey = "" // ⚠️ 臨時測試用，請填入您的 API Key

            if apiKey.isEmpty {
                print("⚠️ 未找到 API Key，請設定：")
                print("   推薦：在 Xcode Scheme 中設定環境變數 GEMINI_API_KEY")
                print("   或者：在 Info.plist 中添加 GEMINI_API_KEY")
                print("   或者：在此處直接填入（僅開發用）")
            } else {
                print("✅ 已使用硬編碼 API Key（請勿用於生產環境）")
            }
        }
    }

    /// 生成結合原始答案的專屬回應
    func generatePersonalizedAnswer(
        question: String,
        originalAnswer: (AnswerType, String, String),
        userName: String?
    ) async throws -> String {

        guard !apiKey.isEmpty else {
            throw GeminiAPIError.noAPIKey
        }

        let name = userName ?? "朋友"
        let prompt = createPrompt(question: question, originalAnswer: originalAnswer, userName: name)

        return try await callGeminiAPI(prompt: prompt)
    }

    /// 創建專屬的 Prompt
    private func createPrompt(question: String, originalAnswer: (AnswerType, String, String), userName: String) -> String {
        let answerType = originalAnswer.0
        let chineseAnswer = originalAnswer.1
        let englishAnswer = originalAnswer.2

        let prompt = """
        你是一個神奇的占卜師，請根據以下資訊為 \(userName) 生成一個溫暖且有趣的占卜回應：

        問題：\(question)

        原始答案：
        - 中文：\(chineseAnswer)
        - 英文：\(englishAnswer)
        - 類型：\(answerType.rawValue)

        請用繁體中文回應，要求：
        1. 融合原始答案的核心含義
        2. 針對具體問題給出建議
        3. 保持神秘而溫暖的占卜師語調
        4. 長度控制在 30-50 字
        5. 可以適當加入 emoji 增加趣味性

        回應格式：直接回傳占卜內容，不需要其他格式。
        """

        return prompt
    }

    /// 調用 Gemini API
    private func callGeminiAPI(prompt: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else {
            throw GeminiAPIError.invalidURL
        }

        let request = GeminiRequest(
            contents: [
                GeminiRequest.Content(
                    parts: [GeminiRequest.Content.Part(text: prompt)]
                )
            ]
        )

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            print("❌ 請求編碼失敗: \(error)")
            throw GeminiAPIError.decodingError(error)
        }

        do {
            print("🚀 正在呼叫 Gemini API...")
            let (data, response) = try await URLSession.shared.data(for: urlRequest)

            // 檢查 HTTP 狀態碼
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP 狀態碼: \(httpResponse.statusCode)")

                if httpResponse.statusCode != 200 {
                    let errorString = String(data: data, encoding: .utf8) ?? "未知錯誤"
                    print("❌ API 錯誤回應: \(errorString)")
                    throw GeminiAPIError.networkError(NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorString]))
                }
            }

            let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
            print("✅ API 回應解析成功")

            guard let firstCandidate = geminiResponse.candidates.first,
                  let firstPart = firstCandidate.content.parts.first else {
                print("❌ API 回應結構異常")
                throw GeminiAPIError.invalidResponse
            }

            let result = firstPart.text.trimmingCharacters(in: .whitespacesAndNewlines)
            print("🎯 AI 生成內容: \(result.prefix(50))...")
            return result

        } catch let error as DecodingError {
            print("❌ 回應解析失敗: \(error)")
            throw GeminiAPIError.decodingError(error)
        } catch let error as GeminiAPIError {
            throw error
        } catch {
            print("❌ 網路請求失敗: \(error)")
            throw GeminiAPIError.networkError(error)
        }
    }
}
