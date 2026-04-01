import Foundation

struct TasteProfile: Codable, Equatable {
    var dontEat: [String]
    var allergies: [String]
    var spiceLevel: String
    var favoriteCuisines: [String]
    var coffeePreference: String?
    var drinkPreference: String?
    var dessertPreference: String?
    var notes: String?

    static let empty = TasteProfile(
        dontEat: [],
        allergies: [],
        spiceLevel: "小辣",
        favoriteCuisines: [],
        coffeePreference: nil,
        drinkPreference: nil,
        dessertPreference: nil,
        notes: nil
    )

    /// 辣度選項
    static let spiceLevels = ["不吃辣", "微辣", "小辣", "中辣", "大辣", "地獄辣"]

    /// 常見料理類型
    static let cuisineOptions = ["台式", "日式", "韓式", "義式", "美式", "泰式", "越式", "印度", "港式", "法式", "墨西哥", "中式"]
}
