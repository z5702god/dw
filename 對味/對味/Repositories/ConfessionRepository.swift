import FirebaseFirestore

@Observable
final class ConfessionRepository {
    static let shared = ConfessionRepository()

    var confessions: [Confession] = []
    private var listener: ListenerRegistration?

    private init() {}

    func startListening() {
        guard listener == nil else { return }
        listener = FirebaseConfig.confessionsCollection
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    #if DEBUG
                    print("[ConfessionRepository] Firestore listener error: \(error.localizedDescription)")
                    #endif
                    return
                }
                guard let documents = snapshot?.documents else { return }
                self?.confessions = documents.compactMap { try? $0.data(as: Confession.self) }
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
        confessions = []
    }

    // MARK: - 告解

    func confess(category: ConfessionCategory) async throws {
        guard let uid = AuthRepository.shared.currentUserId else { return }
        let confession = Confession(
            confessedBy: uid,
            category: category
        )
        try await FirebaseConfig.confessionsCollection.addDocument(from: confession)
        #if DEBUG
        print("[ConfessionRepository] Confessed: \(category.displayName)")
        #endif
    }

    // MARK: - 回應

    func respond(id: String, response: String) async throws {
        try await FirebaseConfig.confessionsCollection.document(id).updateData([
            "response": response,
            "respondedAt": FieldValue.serverTimestamp()
        ])
        #if DEBUG
        print("[ConfessionRepository] Responded: \(response) to \(id)")
        #endif
    }

    // MARK: - Computed

    /// 對方的告解，尚未回應
    var pendingForMe: [Confession] {
        guard let uid = AuthRepository.shared.currentUserId else { return [] }
        return confessions.filter { $0.confessedBy != uid && $0.response == nil }
    }

    /// 本月告解次數
    var monthlyCount: Int {
        let calendar = Calendar.current
        let now = Date()
        return confessions.filter { confession in
            guard let date = confession.createdAt else { return false }
            return calendar.isDate(date, equalTo: now, toGranularity: .month)
        }.count
    }
}
