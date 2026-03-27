import FirebaseFirestore

@Observable
final class CheckInRepository {
    static let shared = CheckInRepository()

    var todayCheckIns: [CheckIn] = []
    private var listener: ListenerRegistration?

    private init() {
        startListeningToday()
    }

    private func startListeningToday() {
        let todayString = Self.dateString(from: Date())
        listener = FirebaseConfig.checkInsCollection
            .whereField("date", isEqualTo: todayString)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else { return }
                self?.todayCheckIns = documents.compactMap { try? $0.data(as: CheckIn.self) }
            }
    }

    func saveCheckIn(_ checkIn: CheckIn) async throws {
        try FirebaseConfig.checkInsCollection.addDocument(from: checkIn)
    }

    func hasCheckedIn(userId: String, mealType: MealType, date: Date) -> Bool {
        let dateString = Self.dateString(from: date)
        return todayCheckIns.contains { checkin in
            checkin.userId == userId &&
            checkin.mealType == mealType &&
            checkin.date == dateString
        }
    }

    func checkInsForUser(_ userId: String) -> [CheckIn] {
        todayCheckIns.filter { $0.userId == userId }
    }

    static func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
