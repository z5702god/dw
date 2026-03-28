import FirebaseFirestore

@Observable
final class RewardRepository {
    static let shared = RewardRepository()

    var rewards: [Reward] = []
    private var listener: ListenerRegistration?

    private init() {
        startListening()
    }

    func stopListening() {
        listener?.remove()
        listener = nil
        rewards = []
    }

    func startListening() {
        guard listener == nil else { return }
        listener = FirebaseConfig.rewardsCollection
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    #if DEBUG
                    print("[RewardRepository] Firestore listener error: \(error.localizedDescription)")
                    #endif
                    return
                }
                guard let documents = snapshot?.documents else { return }
                self?.rewards = documents.compactMap { doc in
                    do {
                        return try doc.data(as: Reward.self)
                    } catch {
                        #if DEBUG
                        print("[RewardRepository] Failed to decode reward \(doc.documentID): \(error)")
                        #endif
                        return nil
                    }
                }
            }
    }

    var availableRewards: [Reward] {
        rewards.filter { $0.status == .available }
    }

    var redeemedRewards: [Reward] {
        rewards.filter { $0.status == .redeemed }
    }

    var completedRewards: [Reward] {
        rewards.filter { $0.status == .completed }
    }

    func addReward(_ reward: Reward) async throws {
        try await FirebaseConfig.rewardsCollection.addDocument(from: reward)
    }

    func redeemReward(id: String, redeemedBy: String) async throws {
        try await FirebaseConfig.rewardsCollection.document(id).updateData([
            "status": RewardStatus.redeemed.rawValue,
            "redeemedAt": FieldValue.serverTimestamp(),
            "redeemedBy": redeemedBy
        ])
    }

    func completeReward(id: String, completedBy: String) async throws {
        try await FirebaseConfig.rewardsCollection.document(id).updateData([
            "status": RewardStatus.completed.rawValue,
            "completedAt": FieldValue.serverTimestamp(),
            "completedBy": completedBy
        ])
    }

    func deleteReward(id: String) async throws {
        try await FirebaseConfig.rewardsCollection.document(id).delete()
    }
}
