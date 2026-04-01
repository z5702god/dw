import FirebaseFirestore

@Observable
final class DreamRepository {
    static let shared = DreamRepository()

    var items: [DreamRestaurant] = []
    private var listener: ListenerRegistration?

    private init() {}

    /// 目前使用者的祕密收藏
    func myItems(userId: String?) -> [DreamRestaurant] {
        guard let userId else { return [] }
        return items.filter { $0.addedBy == userId }
    }

    /// 配對成功：兩人都收藏了同名餐廳（正規化比較）
    var matchedRestaurants: [DreamRestaurant] {
        // 按正規化名稱分組
        let grouped = Dictionary(grouping: items) { $0.normalizedName }
        // 取出有兩位不同使用者的項目（回傳最早的那筆）
        return grouped.values.compactMap { group in
            let uniqueUsers = Set(group.map(\.addedBy))
            guard uniqueUsers.count >= 2 else { return nil }
            return group.sorted { ($0.createdAt ?? .distantPast) < ($1.createdAt ?? .distantPast) }.first
        }
        .sorted { ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast) }
    }

    func startListening() {
        guard listener == nil else { return }
        listener = FirebaseConfig.dreamCollection
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    #if DEBUG
                    print("[DreamRepository] Firestore listener error: \(error.localizedDescription)")
                    #endif
                    return
                }
                guard let documents = snapshot?.documents else { return }
                self?.items = documents.compactMap { doc in
                    do {
                        return try doc.data(as: DreamRestaurant.self)
                    } catch {
                        #if DEBUG
                        print("[DreamRepository] Failed to decode dream item \(doc.documentID): \(error)")
                        #endif
                        return nil
                    }
                }
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
        items = []
    }

    func addItem(_ item: DreamRestaurant) async throws {
        try await FirebaseConfig.dreamCollection.addDocument(from: item)
    }

    func deleteItem(id: String) async throws {
        try await FirebaseConfig.dreamCollection.document(id).delete()
    }
}
