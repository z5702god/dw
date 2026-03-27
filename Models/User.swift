import Foundation
import FirebaseFirestore

struct AppUser: Codable, Identifiable {
    @DocumentID var id: String?
    var email: String
    var displayName: String
    var coupleId: String
    var totalPoints: Int
    var reminderSettings: ReminderSettings

    struct ReminderSettings: Codable {
        var breakfast: String  // "08:00"
        var lunch: String      // "12:00"
        var dinner: String     // "18:30"

        static let `default` = ReminderSettings(
            breakfast: "08:00",
            lunch: "12:00",
            dinner: "18:30"
        )

        func time(for mealType: MealType) -> String {
            switch mealType {
            case .breakfast: return breakfast
            case .lunch: return lunch
            case .dinner: return dinner
            }
        }
    }
}

enum MealType: String, Codable, CaseIterable {
    case breakfast = "breakfast"
    case lunch = "lunch"
    case dinner = "dinner"

    var displayName: String {
        switch self {
        case .breakfast: return "早餐"
        case .lunch: return "午餐"
        case .dinner: return "晚餐"
        }
    }

    var icon: String {
        switch self {
        case .breakfast: return "sun.rise"
        case .lunch: return "sun.max"
        case .dinner: return "moon.stars"
        }
    }
}
