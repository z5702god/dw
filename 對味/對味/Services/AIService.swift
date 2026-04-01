import Foundation

@MainActor
@Observable
final class AIService {
    static let shared = AIService()
    private init() {}

    var isLoading = false

    // MARK: - 生成心得

    /// 根據餐點資訊自動產生簡短心得
    func generateReview(name: String, rating: MealRating, mood: MealMood?, mealPlace: MealPlace) async -> String? {
        let moodText = mood?.displayName ?? "普通"
        let prompt = """
        你是美食評論助手，用繁體中文寫30-50字簡短心得，語氣自然親切。
        餐點名稱：\(name)
        評價：\(rating.displayName)
        心情：\(moodText)
        用餐地點：\(mealPlace.displayName)
        """
        return await callClaude(prompt: prompt)
    }

    // MARK: - 美食法庭仲裁

    /// 針對兩人想吃的東西做出搞笑判決
    func arbitrate(userAName: String, userAWant: String, userBName: String, userBWant: String) async -> String? {
        let prompt = """
        你是搞笑美食法官，寫100字以內的判決書，要有理有據但荒謬好笑。
        原告 \(userAName) 想吃：\(userAWant)
        被告 \(userBName) 想吃：\(userBWant)
        請做出最終判決！
        """
        return await callClaude(prompt: prompt)
    }

    // MARK: - Claude API

    private func callClaude(prompt: String) async -> String? {
        guard AIConfig.isAvailable else {
            #if DEBUG
            print("[AIService] API key 未設定，跳過呼叫")
            #endif
            return nil
        }

        isLoading = true
        defer { isLoading = false }

        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue(AIConfig.claudeAPIKey, forHTTPHeaderField: "x-api-key")

        let body: [String: Any] = [
            "model": "claude-haiku-4-5-20251001",
            "max_tokens": 256,
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                #if DEBUG
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                print("[AIService] API 錯誤，狀態碼：\(statusCode)")
                #endif
                return nil
            }

            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let content = json["content"] as? [[String: Any]],
                  let text = content.first?["text"] as? String else {
                #if DEBUG
                print("[AIService] 無法解析回應")
                #endif
                return nil
            }

            return text
        } catch {
            #if DEBUG
            print("[AIService] 請求失敗：\(error.localizedDescription)")
            #endif
            return nil
        }
    }
}
