import Foundation
import FirebaseFirestore

struct Reward: Codable, Identifiable {
    @DocumentID var id: String?
    var title: String
    var pointsCost: Int
    var createdBy: String
    var isRedeemed: Bool
    var redeemedAt: Date?
    @ServerTimestamp var createdAt: Date?
}
