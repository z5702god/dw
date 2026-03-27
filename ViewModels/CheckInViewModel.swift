import Foundation

@Observable
final class CheckInViewModel {
    var isLoading = false
    var showResult = false
    var lastResult: CheckInResult?
    var errorMessage: String?

    private let pointsService = PointsService.shared
    private let checkInRepo = CheckInRepository.shared
    private let authRepo = AuthRepository.shared

    var currentUserId: String? { authRepo.currentUserId }
    var totalPoints: Int { authRepo.appUser?.totalPoints ?? 0 }

    func hasCheckedIn(mealType: MealType) -> Bool {
        guard let userId = currentUserId else { return false }
        return checkInRepo.hasCheckedIn(userId: userId, mealType: mealType, date: Date())
    }

    func partnerHasCheckedIn(mealType: MealType) -> Bool {
        let partnerCheckIns = checkInRepo.todayCheckIns.filter { $0.userId != currentUserId }
        return partnerCheckIns.contains { $0.mealType == mealType }
    }

    func checkIn(mealType: MealType) async {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await pointsService.checkIn(mealType: mealType)
            lastResult = result
            showResult = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func todayPointsEarned() -> Int {
        guard let userId = currentUserId else { return 0 }
        return checkInRepo.checkInsForUser(userId).reduce(0) { $0 + $1.pointsEarned }
    }
}
