import FirebaseFirestore

@Observable
final class RewardRepository {
    static let shared = RewardRepository()

    var rewards: [Reward] = []
    private var listener: ListenerRegistration?

    private init() {
        startListening()
    }

    private func startListening() {
        listener = FirebaseConfig.rewardsCollection
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else { return }
                self?.rewards = documents.compactMap { try? $0.data(as: Reward.self) }
            }
    }

    var availableRewards: [Reward] {
        rewards.filter { !$0.isRedeemed }
    }

    var redeemedRewards: [Reward] {
        rewards.filter { $0.isRedeemed }
    }

    func addReward(_ reward: Reward) async throws {
        try FirebaseConfig.rewardsCollection.addDocument(from: reward)
    }

    func redeemReward(id: String) async throws {
        try await FirebaseConfig.rewardsCollection.document(id).updateData([
            "isRedeemed": true,
            "redeemedAt": FieldValue.serverTimestamp()
        ])
    }

    func deleteReward(id: String) async throws {
        try await FirebaseConfig.rewardsCollection.document(id).delete()
    }
}
