import Foundation
import FirebaseFirestore

enum CoupleRole: String, Codable {
    case pointsEarner   // Kathy — 賺點數的人
    case rewardFulfiller // Luke — 兌現獎勵的人
}

struct AppUser: Codable, Identifiable {
    @DocumentID var id: String?
    var email: String
    var displayName: String
    var coupleId: String
    var totalPoints: Int
    var roleRawValue: String?

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case displayName
        case coupleId
        case totalPoints
        case roleRawValue = "role"
    }

    var role: CoupleRole {
        if let raw = roleRawValue, let parsed = CoupleRole(rawValue: raw) {
            return parsed
        }
        #if DEBUG
        print("[AppUser] ⚠️ No role field for user \(id ?? "unknown"), defaulting to rewardFulfiller")
        #endif
        return .rewardFulfiller
    }

    var isKathy: Bool { role == .pointsEarner }
    var isLuke: Bool { role == .rewardFulfiller }
}

typealias MealType = MealSlot
