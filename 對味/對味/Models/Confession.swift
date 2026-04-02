import Foundation
import FirebaseFirestore

// MARK: - 告解類別
enum ConfessionCategory: String, Codable, CaseIterable, Identifiable {
    var id: String { rawValue }
    case snack = "snack"
    case nightSnack = "night_snack"
    case dessert = "dessert"
    case drink = "drink"

    var displayName: String {
        switch self {
        case .snack: return "零食"
        case .nightSnack: return "宵夜"
        case .dessert: return "甜點"
        case .drink: return "手搖"
        }
    }

    var emoji: String {
        switch self {
        case .snack: return "🍪"
        case .nightSnack: return "🍜"
        case .dessert: return "🍰"
        case .drink: return "🧋"
        }
    }

    var icon: String {
        switch self {
        case .snack: return "leaf.fill"
        case .nightSnack: return "moon.stars.fill"
        case .dessert: return "birthday.cake.fill"
        case .drink: return "cup.and.saucer.fill"
        }
    }
}

// MARK: - 告解紀錄
struct Confession: Codable, Identifiable {
    @DocumentID var id: String?
    var confessedBy: String
    var category: ConfessionCategory
    var response: String?       // "forgive" or "wantSome"
    var respondedAt: Date?
    @ServerTimestamp var createdAt: Date?
}
