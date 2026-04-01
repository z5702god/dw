import FirebaseFirestore

@Observable
final class MealRepository {
    static let shared = MealRepository()

    var meals: [Meal] = []
    private var listener: ListenerRegistration?

    private init() {
        startListening()
    }

    func stopListening() {
        listener?.remove()
        listener = nil
        meals = []
    }

    func startListening() {
        guard listener == nil else { return }
        listener = FirebaseConfig.mealsCollection
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    #if DEBUG
                    print("[MealRepository] Firestore listener error: \(error.localizedDescription)")
                    #endif
                    return
                }
                guard let documents = snapshot?.documents else { return }
                self?.meals = documents.compactMap { try? $0.data(as: Meal.self) }
            }
    }

    func addMeal(_ meal: Meal) async throws {
        try await FirebaseConfig.mealsCollection.addDocument(from: meal)
    }

    func deleteMeal(id: String) async throws {
        try await FirebaseConfig.mealsCollection.document(id).delete()
    }

    func meals(filteredBy rating: MealRating?) -> [Meal] {
        guard let rating else { return meals }
        return meals.filter { $0.rating == rating }
    }

    func meals(inCity city: City) -> [Meal] {
        meals.filter { $0.city == city }
    }

    // MARK: - 味道時間軸

    func addToTimeline(mealId: String, tag: TimelineTag) async throws {
        try await FirebaseConfig.mealsCollection.document(mealId).updateData([
            "isTimelineEvent": true,
            "timelineTag": tag.rawValue
        ])
        #if DEBUG
        print("[MealRepository] Added meal \(mealId) to timeline with tag: \(tag.displayName)")
        #endif
    }

    func removeFromTimeline(mealId: String) async throws {
        try await FirebaseConfig.mealsCollection.document(mealId).updateData([
            "isTimelineEvent": false,
            "timelineTag": FieldValue.delete()
        ])
        #if DEBUG
        print("[MealRepository] Removed meal \(mealId) from timeline")
        #endif
    }

    func addPartnerReview(mealId: String, review: String) async throws {
        try await FirebaseConfig.mealsCollection.document(mealId).updateData([
            "partnerReview": review,
            "partnerReviewedAt": FieldValue.serverTimestamp()
        ])
    }
}
