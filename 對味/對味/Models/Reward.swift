import Foundation
import FirebaseFirestore

enum RewardStatus: String, Codable {
    case available = "available"
    case redeemed = "redeemed"
    case completed = "completed"
}

struct Reward: Codable, Identifiable {
    @DocumentID var id: String?
    var title: String
    var pointsCost: Int
    var createdBy: String
    var status: RewardStatus
    var redeemedAt: Date?
    var redeemedBy: String?
    var completedAt: Date?
    var completedBy: String?
    @ServerTimestamp var createdAt: Date?

    // Programmatic init for creating new rewards
    init(id: String? = nil, title: String, pointsCost: Int, createdBy: String, status: RewardStatus = .available) {
        self.id = id
        self.title = title
        self.pointsCost = pointsCost
        self.createdBy = createdBy
        self.status = status
        self.redeemedAt = nil
        self.redeemedBy = nil
        self.completedAt = nil
        self.completedBy = nil
        self.createdAt = nil
    }

    // Backward-compatible decoding: migrate old `isRedeemed` bool to `status`
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decode(DocumentID<String>.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        pointsCost = try container.decode(Int.self, forKey: .pointsCost)
        createdBy = try container.decode(String.self, forKey: .createdBy)
        redeemedAt = try container.decodeIfPresent(Date.self, forKey: .redeemedAt)
        redeemedBy = try container.decodeIfPresent(String.self, forKey: .redeemedBy)
        completedAt = try container.decodeIfPresent(Date.self, forKey: .completedAt)
        completedBy = try container.decodeIfPresent(String.self, forKey: .completedBy)
        if let ts = try? container.decode(ServerTimestamp<Date>.self, forKey: .createdAt) {
            _createdAt = ts
        } else {
            _createdAt = .init(wrappedValue: nil)
        }

        // Try decoding new `status` field first; fall back to old `isRedeemed` bool
        if let decodedStatus = try? container.decode(RewardStatus.self, forKey: .status) {
            status = decodedStatus
        } else if let isRedeemed = try? container.decode(Bool.self, forKey: .isRedeemed) {
            status = isRedeemed ? .redeemed : .available
        } else {
            status = .available
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id, title, pointsCost, createdBy, status
        case redeemedAt, redeemedBy, completedAt, completedBy, createdAt
        case isRedeemed // legacy key for backward compat decoding only
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(pointsCost, forKey: .pointsCost)
        try container.encode(createdBy, forKey: .createdBy)
        try container.encode(status, forKey: .status)
        try container.encodeIfPresent(redeemedAt, forKey: .redeemedAt)
        try container.encodeIfPresent(redeemedBy, forKey: .redeemedBy)
        try container.encodeIfPresent(completedAt, forKey: .completedAt)
        try container.encodeIfPresent(completedBy, forKey: .completedBy)
        try container.encode(_createdAt, forKey: .createdAt)
    }
}
