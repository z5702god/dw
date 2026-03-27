import Foundation

@Observable
final class RewardViewModel {
    var showingAddReward = false
    var newRewardTitle = ""
    var newRewardCost = 50
    var isLoading = false
    var errorMessage: String?

    private let rewardRepo = RewardRepository.shared
    private let pointsService = PointsService.shared
    private let authRepo = AuthRepository.shared

    var availableRewards: [Reward] { rewardRepo.availableRewards }
    var redeemedRewards: [Reward] { rewardRepo.redeemedRewards }
    var totalPoints: Int { authRepo.appUser?.totalPoints ?? 0 }

    func addReward() async {
        guard !newRewardTitle.isEmpty, let userId = authRepo.currentUserId else { return }

        let reward = Reward(
            title: newRewardTitle,
            pointsCost: newRewardCost,
            createdBy: userId,
            isRedeemed: false
        )

        do {
            try await rewardRepo.addReward(reward)
            newRewardTitle = ""
            newRewardCost = 50
            showingAddReward = false
        } catch {
            errorMessage = "新增失敗：\(error.localizedDescription)"
        }
    }

    func redeemReward(_ reward: Reward) async {
        guard let rewardId = reward.id else { return }

        isLoading = true
        errorMessage = nil

        do {
            try await pointsService.redeemReward(rewardId: rewardId, cost: reward.pointsCost)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func deleteReward(_ reward: Reward) async {
        guard let id = reward.id else { return }
        try? await rewardRepo.deleteReward(id: id)
    }
}
