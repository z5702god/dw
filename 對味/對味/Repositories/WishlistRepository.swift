import FirebaseFirestore

@Observable
final class WishlistRepository {
    static let shared = WishlistRepository()

    var items: [WishlistItem] = []
    private var listener: ListenerRegistration?

    private init() {}

    var pendingItems: [WishlistItem] {
        items.filter { !$0.isVisited }
    }

    var visitedItems: [WishlistItem] {
        items.filter { $0.isVisited }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
        items = []
    }

    func startListening() {
        guard listener == nil else { return }
        listener = FirebaseConfig.wishlistCollection
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    #if DEBUG
                    print("[WishlistRepository] Firestore listener error: \(error.localizedDescription)")
                    #endif
                    return
                }
                guard let documents = snapshot?.documents else { return }
                self?.items = documents.compactMap { doc in
                    do {
                        return try doc.data(as: WishlistItem.self)
                    } catch {
                        #if DEBUG
                        print("[WishlistRepository] Failed to decode wishlist item \(doc.documentID): \(error)")
                        #endif
                        return nil
                    }
                }
            }
    }

    func addItem(_ item: WishlistItem) async throws {
        try await FirebaseConfig.wishlistCollection.addDocument(from: item)
    }

    func deleteItem(id: String) async throws {
        try await FirebaseConfig.wishlistCollection.document(id).delete()
    }

    func markAsVisited(id: String, mealId: String) async throws {
        try await FirebaseConfig.wishlistCollection.document(id).updateData([
            "isVisited": true,
            "visitedMealId": mealId
        ])
    }

    func unmarkVisited(id: String) async throws {
        try await FirebaseConfig.wishlistCollection.document(id).updateData([
            "isVisited": false,
            "visitedMealId": FieldValue.delete()
        ])
    }
}
