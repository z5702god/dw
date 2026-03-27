import FirebaseFirestore

final class PointsService {
    static let shared = PointsService()

    private let checkInRepo = CheckInRepository.shared
    private let authRepo = AuthRepository.shared

    /// On-time window in seconds (30 minutes)
    private let onTimeWindow: TimeInterval = 30 * 60

    /// Points for on-time check-in
    private let onTimePoints = 10

    /// Points for late check-in
    private let latePoints = 3

    private init() {}

    func checkIn(mealType: MealType) async throws -> CheckInResult {
        guard let userId = authRepo.currentUserId,
              let settings = authRepo.appUser?.reminderSettings else {
            throw PointsError.notLoggedIn
        }

        // Check if already checked in
        guard !checkInRepo.hasCheckedIn(userId: userId, mealType: mealType, date: Date()) else {
            throw PointsError.alreadyCheckedIn
        }

        // Calculate if on time
        let scheduledTimeString = settings.time(for: mealType)
        let isOnTime = isWithinWindow(scheduledTime: scheduledTimeString)
        let points = isOnTime ? onTimePoints : latePoints

        // Save check-in
        let checkIn = CheckIn(
            userId: userId,
            mealType: mealType,
            date: CheckInRepository.dateString(from: Date()),
            checkedInAt: Date(),
            pointsEarned: points,
            onTime: isOnTime
        )
        try await checkInRepo.saveCheckIn(checkIn)

        // Increment user points
        try await FirebaseConfig.userDocument(userId).updateData([
            "totalPoints": FieldValue.increment(Int64(points))
        ])

        return CheckInResult(onTime: isOnTime, pointsEarned: points)
    }

    func redeemReward(rewardId: String, cost: Int) async throws {
        guard let userId = authRepo.currentUserId,
              let user = authRepo.appUser else {
            throw PointsError.notLoggedIn
        }

        guard user.totalPoints >= cost else {
            throw PointsError.insufficientPoints
        }

        // Deduct points
        try await FirebaseConfig.userDocument(userId).updateData([
            "totalPoints": FieldValue.increment(Int64(-cost))
        ])

        // Mark reward as redeemed
        try await RewardRepository.shared.redeemReward(id: rewardId)
    }

    private func isWithinWindow(scheduledTime: String) -> Bool {
        let components = scheduledTime.split(separator: ":").compactMap { Int($0) }
        guard components.count == 2 else { return false }

        let calendar = Calendar.current
        let now = Date()

        var scheduledComponents = calendar.dateComponents([.year, .month, .day], from: now)
        scheduledComponents.hour = components[0]
        scheduledComponents.minute = components[1]

        guard let scheduledDate = calendar.date(from: scheduledComponents) else { return false }

        return abs(now.timeIntervalSince(scheduledDate)) <= onTimeWindow
    }
}

struct CheckInResult {
    let onTime: Bool
    let pointsEarned: Int
}

enum PointsError: LocalizedError {
    case notLoggedIn
    case alreadyCheckedIn
    case insufficientPoints

    var errorDescription: String? {
        switch self {
        case .notLoggedIn: return "請先登入"
        case .alreadyCheckedIn: return "這餐已經打卡過了"
        case .insufficientPoints: return "點數不足"
        }
    }
}
