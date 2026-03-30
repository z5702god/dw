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

    /// 建立一筆兌換紀錄（原獎勵保持 available，可重複兌換）
    func redeemReward(reward: Reward, redeemedBy: String) async throws {
        let data: [String: Any] = [
            "title": reward.title,
            "pointsCost": reward.pointsCost,
            "createdBy": reward.createdBy,
            "status": RewardStatus.redeemed.rawValue,
            "redeemedBy": redeemedBy,
            "redeemedAt": FieldValue.serverTimestamp(),
            "createdAt": FieldValue.serverTimestamp()
        ]
        try await FirebaseConfig.rewardsCollection.addDocument(data: data)
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
