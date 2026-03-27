import Foundation
import FirebaseFirestore

struct CheckIn: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var mealType: MealType
    var date: String            // "2026-03-26" for easy querying
    var checkedInAt: Date
    var pointsEarned: Int
    var onTime: Bool
}
