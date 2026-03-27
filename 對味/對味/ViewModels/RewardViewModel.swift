import Foundation
import FirebaseFirestore

@MainActor
@Observable
final class RewardViewModel {
    var isLoading = false
    var errorMessage: String?
    var showRedemptionAlert = false
    var newlyRedeemedReward: Reward?
    private var hasLoadedInitialData = false
    private var previousRedeemedCount = 0

    private let rewardRepo = RewardRepository.shared
    private let pointsService = PointsService.shared
    private let authRepo = AuthRepository.shared

    var isKathy: Bool { authRepo.appUser?.isKathy ?? false }
    var isLuke: Bool { authRepo.appUser?.isLuke ?? false }

    var availableRewards: [Reward] { rewardRepo.availableRewards }
    var redeemedRewards: [Reward] { rewardRepo.redeemedRewards }
    var completedRewards: [Reward] { rewardRepo.completedRewards }
    var totalPoints: Int { authRepo.appUser?.totalPoints ?? 0 }

    // MARK: - Emoji Helper

    func rewardEmoji(for title: String) -> String {
        if title.contains("電影") { return "🎬" }
        if title.contains("按摩") { return "💆" }
        if title.contains("旅遊") || title.contains("機票") { return "✈️" }
        if title.contains("晚餐") || title.contains("餐") { return "🍽️" }
        if title.contains("禮物") { return "🎁" }
        if title.contains("休假") || title.contains("假") { return "🏖️" }
        return "🎁"
    }

    // MARK: - Actions

    /// Kathy redeems a reward
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

    /// Luke completes/fulfills a reward
    func completeReward(_ reward: Reward) async {
        guard let rewardId = reward.id,
              let userId = authRepo.currentUserId else { return }
        isLoading = true
        do {
            try await rewardRepo.completeReward(id: rewardId, completedBy: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    /// Detect new redemptions for Luke's notification
    func checkForNewRedemptions() {
        guard isLuke else { return }
        let currentCount = redeemedRewards.count
        if hasLoadedInitialData && currentCount > previousRedeemedCount {
            if let newest = redeemedRewards.sorted(by: { ($0.redeemedAt ?? .distantPast) > ($1.redeemedAt ?? .distantPast) }).first {
                newlyRedeemedReward = newest
                showRedemptionAlert = true
            }
        }
        previousRedeemedCount = currentCount
        hasLoadedInitialData = true
    }

    private var hasSeeded = false

    func seedDefaultRewardsIfNeeded() async {
        guard !hasSeeded else { return }
        hasSeeded = true

        // Wait briefly for Firestore listener to deliver initial data
        for _ in 0..<5 {
            try? await Task.sleep(for: .milliseconds(200))
            if !rewardRepo.rewards.isEmpty { break }
        }

        #if DEBUG
        print("[RewardViewModel] Total rewards: \(rewardRepo.rewards.count), available: \(rewardRepo.availableRewards.count)")
        #endif

        // If there are already enough available rewards, skip
        guard rewardRepo.availableRewards.count < 3 else { return }

        let defaults: [(String, Int)] = [
            ("免費看電影一次", 10),
            ("國外旅遊來回機票", 200),
            ("超舒服泰式按摩券一張", 30),
        ]

        let existingTitles = Set(rewardRepo.rewards.map { $0.title })
        for (title, cost) in defaults {
            if !existingTitles.contains(title) {
                let reward = Reward(title: title, pointsCost: cost, createdBy: "system", status: .available)
                do {
                    try await rewardRepo.addReward(reward)
                    #if DEBUG
                    print("[RewardViewModel] Seeded reward: \(title)")
                    #endif
                } catch {
                    #if DEBUG
                    print("[RewardViewModel] Failed to seed reward '\(title)': \(error.localizedDescription)")
                    #endif
                }
            }
        }
    }

    func deleteReward(_ reward: Reward) async {
        guard let id = reward.id else { return }
        try? await rewardRepo.deleteReward(id: id)
    }
}
