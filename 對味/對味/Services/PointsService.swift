import Foundation
import FirebaseFirestore

final class PointsService {
    static let shared = PointsService()

    private let authRepo = AuthRepository.shared
    private let db = Firestore.firestore()

    private init() {}

    /// 晚餐在 20:00 前記錄可獲得 1 點（僅 pointsEarner 可獲得點數）
    /// 同一天只能獲得一次晚餐點數
    func awardPointIfEligible(mealSlot: MealSlot, userId: String) async throws -> Bool {
        // 只有 pointsEarner（Kathy）可以獲得點數
        guard authRepo.appUser?.isKathy == true else { return false }

        guard mealSlot == .dinner else { return false }

        let hour = Calendar.current.component(.hour, from: Date())
        guard hour < 20 else { return false }

        // 檢查今天是否已經有晚餐紀錄（防止重複給點）
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let snapshot = try await FirebaseConfig.mealsCollection
            .whereField("userId", isEqualTo: userId)
            .whereField("mealSlot", isEqualTo: MealSlot.dinner.rawValue)
            .whereField("createdAt", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("createdAt", isLessThan: Timestamp(date: endOfDay))
            .getDocuments()

        // 如果已經有超過 1 筆晚餐紀錄（包含剛存的這筆），代表之前已給過點數
        guard snapshot.documents.count <= 1 else { return false }

        try await FirebaseConfig.userDocument(userId).updateData([
            "totalPoints": FieldValue.increment(Int64(1))
        ])

        return true
    }

    func redeemReward(rewardId: String, cost: Int) async throws {
        guard let userId = authRepo.currentUserId else {
            throw PointsError.notLoggedIn
        }

        let userRef = FirebaseConfig.userDocument(userId)

        // 使用 Firestore Transaction 確保原子性，避免 race condition
        try await db.runTransaction { transaction, errorPointer in
            let userDoc: DocumentSnapshot
            do {
                userDoc = try transaction.getDocument(userRef)
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }

            guard let currentPoints = userDoc.data()?["totalPoints"] as? Int else {
                let err = PointsError.notLoggedIn
                errorPointer?.pointee = err as NSError
                return nil
            }

            guard currentPoints >= cost else {
                let err = PointsError.insufficientPoints
                errorPointer?.pointee = err as NSError
                return nil
            }

            // 在 transaction 內扣點
            transaction.updateData([
                "totalPoints": FieldValue.increment(Int64(-cost))
            ], forDocument: userRef)

            return nil
        }

        // Transaction 成功後才標記獎勵為已兌換
        try await RewardRepository.shared.redeemReward(id: rewardId, redeemedBy: userId)
    }
}

enum PointsError: LocalizedError {
    case notLoggedIn
    case insufficientPoints

    var errorDescription: String? {
        switch self {
        case .notLoggedIn: return "請先登入"
        case .insufficientPoints: return "點數不足"
        }
    }
}
