import Foundation
import FirebaseFirestore

final class AchievementService {
    static let shared = AchievementService()

    private let db = Firestore.firestore()
    private let authRepo = AuthRepository.shared
    private let mealRepo = MealRepository.shared
    private let rewardRepo = RewardRepository.shared

    private init() {}

    // MARK: - Check All Achievements

    /// 檢查所有未解鎖的成就，回傳新解鎖的成就列表
    func checkAll(unlockedIds: Set<String>) -> [Achievement] {
        let meals = mealRepo.meals
        let user = authRepo.appUser
        let rewards = rewardRepo.rewards

        var newlyUnlocked: [Achievement] = []

        for achievement in AchievementDefinitions.all {
            guard !unlockedIds.contains(achievement.id) else { continue }

            if evaluate(achievement.condition, meals: meals, user: user, rewards: rewards) {
                newlyUnlocked.append(achievement)
            }
        }

        return newlyUnlocked
    }

    // MARK: - Evaluate Condition

    private func evaluate(
        _ condition: AchievementCondition,
        meals: [Meal],
        user: AppUser?,
        rewards: [Reward]
    ) -> Bool {
        guard let userId = authRepo.currentUserId else { return false }

        switch condition {
        case .mealCount(let target):
            let myMeals = meals.filter { $0.userId == userId }
            return myMeals.count >= target

        case .regionCount(let target):
            let myMeals = meals.filter { $0.userId == userId }
            let uniqueCities = Set(myMeals.compactMap { $0.city })
            return uniqueCities.count >= target

        case .firstPoint:
            return (user?.totalPoints ?? 0) >= 1

        case .streak(let target):
            let streak = calculateCurrentStreak(meals: meals, userId: userId)
            return streak >= target

        case .monthlyPerfect:
            return checkMonthlyPerfect(meals: meals, userId: userId)

        case .firstDuo:
            return checkFirstDuo(meals: meals, userId: userId)

        case .sameRating(let target):
            return countSameRatingDuos(meals: meals, userId: userId) >= target

        case .bothRecommend(let target):
            return countBothRecommend(meals: meals, userId: userId) >= target

        case .duoMealCount(let target):
            return countDuoMeals(meals: meals, userId: userId) >= target

        case .monthlySync:
            return checkMonthlySync(meals: meals, userId: userId)

        case .firstRedeem:
            return rewards.contains { $0.status == .redeemed || $0.status == .completed }

        case .completedRewards(let target):
            return rewards.filter { $0.status == .completed }.count >= target

        case .totalPoints(let target):
            return (user?.totalPoints ?? 0) >= target

        case .totalRedemptions(let target):
            let redeemed = rewards.filter { $0.status == .redeemed || $0.status == .completed }
            return redeemed.count >= target

        // 國際美食
        case .firstInternational:
            return !internationalMeals(meals: meals, userId: userId).isEmpty

        case .countryCount(let target):
            return uniqueCountries(meals: meals, userId: userId).count >= target

        case .internationalMealCount(let target):
            return internationalMeals(meals: meals, userId: userId).count >= target

        case .coupleCountryCount(let target):
            return coupleCountries(meals: meals, userId: userId).count >= target

        case .singleCountryMealCount(let target):
            return maxSingleCountryCount(meals: meals, userId: userId) >= target
        }
    }

    // MARK: - Progress Value (for UI)

    func progressValue(for achievement: Achievement, unlockedIds: Set<String>) -> (current: Int, target: Int)? {
        if unlockedIds.contains(achievement.id) { return nil }
        guard let userId = authRepo.currentUserId else { return nil }

        let meals = mealRepo.meals
        let user = authRepo.appUser
        let rewards = rewardRepo.rewards

        switch achievement.condition {
        case .mealCount(let target):
            let count = meals.filter { $0.userId == userId }.count
            return (count, target)

        case .regionCount(let target):
            let count = Set(meals.filter { $0.userId == userId }.compactMap { $0.city }).count
            return (count, target)

        case .streak(let target):
            let streak = calculateCurrentStreak(meals: meals, userId: userId)
            return (streak, target)

        case .sameRating(let target):
            let count = countSameRatingDuos(meals: meals, userId: userId)
            return (count, target)

        case .bothRecommend(let target):
            let count = countBothRecommend(meals: meals, userId: userId)
            return (count, target)

        case .duoMealCount(let target):
            let count = countDuoMeals(meals: meals, userId: userId)
            return (count, target)

        case .completedRewards(let target):
            let count = rewards.filter { $0.status == .completed }.count
            return (count, target)

        case .totalPoints(let target):
            return (user?.totalPoints ?? 0, target)

        case .totalRedemptions(let target):
            let count = rewards.filter { $0.status == .redeemed || $0.status == .completed }.count
            return (count, target)

        case .countryCount(let target):
            let count = uniqueCountries(meals: meals, userId: userId).count
            return (count, target)

        case .internationalMealCount(let target):
            let count = internationalMeals(meals: meals, userId: userId).count
            return (count, target)

        case .coupleCountryCount(let target):
            let count = coupleCountries(meals: meals, userId: userId).count
            return (count, target)

        case .singleCountryMealCount(let target):
            let count = maxSingleCountryCount(meals: meals, userId: userId)
            return (count, target)

        case .firstPoint, .monthlyPerfect, .firstDuo, .monthlySync, .firstRedeem, .firstInternational:
            return nil
        }
    }

    // MARK: - Unlock Achievements (Firestore)

    /// 寫入解鎖紀錄到 User document + 加點（fire-and-forget）
    func unlockAchievements(_ achievements: [Achievement]) async {
        guard let userId = authRepo.currentUserId else { return }

        var updates: [String: Any] = [:]
        var totalBonusPoints = 0

        for achievement in achievements {
            updates["unlockedAchievements.\(achievement.id)"] = Date().timeIntervalSince1970
            if authRepo.appUser?.isKathy == true {
                totalBonusPoints += achievement.tier.pointsReward
            }
        }

        if totalBonusPoints > 0 {
            updates["totalPoints"] = FieldValue.increment(Int64(totalBonusPoints))
        }

        do {
            try await FirebaseConfig.userDocument(userId).updateData(updates)
            #if DEBUG
            print("[AchievementService] ✅ Unlocked \(achievements.count) achievements: \(achievements.map { $0.title })")
            #endif
        } catch {
            #if DEBUG
            print("[AchievementService] ❌ Failed to unlock: \(error)")
            #endif
        }
    }

    // MARK: - Migration (首次啟動)

    /// 掃描現有資料，批次解鎖符合條件的成就
    func runMigration(unlockedIds: Set<String>) async -> [Achievement] {
        let newlyUnlocked = checkAll(unlockedIds: unlockedIds)
        if !newlyUnlocked.isEmpty {
            await unlockAchievements(newlyUnlocked)
        }
        return newlyUnlocked
    }

    // MARK: - Streak Calculation

    func calculateCurrentStreak(meals: [Meal], userId: String) -> Int {
        let calendar = Calendar.current
        let myMeals = meals.filter { $0.userId == userId }

        // 取得有記錄的所有日期（去重）
        let datesWithMeals: Set<DateComponents> = Set(
            myMeals.compactMap { meal in
                guard let date = meal.createdAt else { return nil }
                return calendar.dateComponents([.year, .month, .day], from: date)
            }
        )

        guard !datesWithMeals.isEmpty else { return 0 }

        // 從今天往回數連續天數
        var streak = 0
        var checkDate = Date()

        // 如果今天還沒有記錄，從昨天開始算
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: checkDate)
        if !datesWithMeals.contains(todayComponents) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: checkDate) else { return 0 }
            checkDate = yesterday
        }

        while true {
            let components = calendar.dateComponents([.year, .month, .day], from: checkDate)
            if datesWithMeals.contains(components) {
                streak += 1
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
                checkDate = previousDay
            } else {
                break
            }
        }

        return streak
    }

    // MARK: - Monthly Perfect Check

    private func checkMonthlyPerfect(meals: [Meal], userId: String) -> Bool {
        let calendar = Calendar.current
        let myMeals = meals.filter { $0.userId == userId }

        // 檢查上個月（已完成的日曆月）
        guard let lastMonth = calendar.date(byAdding: .month, value: -1, to: Date()) else { return false }
        let year = calendar.component(.year, from: lastMonth)
        let month = calendar.component(.month, from: lastMonth)
        guard let range = calendar.range(of: .day, in: .month, for: lastMonth) else { return false }
        let daysInMonth = range.count

        let datesInMonth: Set<Int> = Set(
            myMeals.compactMap { meal in
                guard let date = meal.createdAt,
                      calendar.component(.year, from: date) == year,
                      calendar.component(.month, from: date) == month else { return nil }
                return calendar.component(.day, from: date)
            }
        )

        return datesInMonth.count >= daysInMonth
    }

    // MARK: - Couple Checks

    private var partnerId: String? {
        guard let userId = authRepo.currentUserId else { return nil }
        switch userId {
        case "cdQV8F8j9NYyfI1Y4kKNV1hWrPB2": return "M0143zxobBXxZ6vAAgX6jq8ll1g2"
        case "M0143zxobBXxZ6vAAgX6jq8ll1g2": return "cdQV8F8j9NYyfI1Y4kKNV1hWrPB2"
        default: return nil
        }
    }

    private func checkFirstDuo(meals: [Meal], userId: String) -> Bool {
        guard let partnerId else { return false }
        let calendar = Calendar.current

        let myMealDates = Set(meals.filter { $0.userId == userId }.compactMap { meal -> DateComponents? in
            guard let date = meal.createdAt else { return nil }
            return calendar.dateComponents([.year, .month, .day], from: date)
        })

        let partnerMealDates = Set(meals.filter { $0.userId == partnerId }.compactMap { meal -> DateComponents? in
            guard let date = meal.createdAt else { return nil }
            return calendar.dateComponents([.year, .month, .day], from: date)
        })

        return !myMealDates.intersection(partnerMealDates).isEmpty
    }

    private func countSameRatingDuos(meals: [Meal], userId: String) -> Int {
        guard let partnerId else { return 0 }
        let calendar = Calendar.current

        // 按日期 + 餐廳分組配對
        struct MealKey: Hashable {
            let date: DateComponents
            let name: String
        }

        var myMeals: [MealKey: MealRating] = [:]
        var partnerMeals: [MealKey: MealRating] = [:]

        for meal in meals {
            guard let date = meal.createdAt else { continue }
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            let key = MealKey(date: dateComponents, name: meal.displayTitle)

            if meal.userId == userId {
                myMeals[key] = meal.rating
            } else if meal.userId == partnerId {
                partnerMeals[key] = meal.rating
            }
        }

        var count = 0
        for (key, myRating) in myMeals {
            if let partnerRating = partnerMeals[key], myRating == partnerRating {
                count += 1
            }
        }
        return count
    }

    private func countBothRecommend(meals: [Meal], userId: String) -> Int {
        guard let partnerId else { return 0 }
        let calendar = Calendar.current

        struct MealKey: Hashable {
            let date: DateComponents
            let name: String
        }

        var myRecommended: Set<MealKey> = []
        var partnerRecommended: Set<MealKey> = []

        for meal in meals {
            guard let date = meal.createdAt, meal.rating == .recommended else { continue }
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            let key = MealKey(date: dateComponents, name: meal.displayTitle)

            if meal.userId == userId {
                myRecommended.insert(key)
            } else if meal.userId == partnerId {
                partnerRecommended.insert(key)
            }
        }

        return myRecommended.intersection(partnerRecommended).count
    }

    private func countDuoMeals(meals: [Meal], userId: String) -> Int {
        guard let partnerId else { return 0 }
        let calendar = Calendar.current

        let myDates = Set(meals.filter { $0.userId == userId }.compactMap { meal -> DateComponents? in
            guard let date = meal.createdAt else { return nil }
            return calendar.dateComponents([.year, .month, .day], from: date)
        })

        let partnerDates = Set(meals.filter { $0.userId == partnerId }.compactMap { meal -> DateComponents? in
            guard let date = meal.createdAt else { return nil }
            return calendar.dateComponents([.year, .month, .day], from: date)
        })

        return myDates.intersection(partnerDates).count
    }

    private func checkMonthlySync(meals: [Meal], userId: String) -> Bool {
        guard let partnerId else { return false }
        let calendar = Calendar.current

        // 檢查上個月
        guard let lastMonth = calendar.date(byAdding: .month, value: -1, to: Date()) else { return false }
        let year = calendar.component(.year, from: lastMonth)
        let month = calendar.component(.month, from: lastMonth)

        func daysRecordedInMonth(by uid: String) -> Int {
            Set(
                meals.compactMap { meal -> Int? in
                    guard meal.userId == uid,
                          let date = meal.createdAt,
                          calendar.component(.year, from: date) == year,
                          calendar.component(.month, from: date) == month else { return nil }
                    return calendar.component(.day, from: date)
                }
            ).count
        }

        let myDays = daysRecordedInMonth(by: userId)
        let partnerDays = daysRecordedInMonth(by: partnerId)

        return myDays >= 20 && partnerDays >= 20
    }

    // MARK: - International Helpers

    private func internationalMeals(meals: [Meal], userId: String) -> [Meal] {
        meals.filter { $0.userId == userId && $0.country != nil && $0.country != "TW" }
    }

    private func uniqueCountries(meals: [Meal], userId: String) -> Set<String> {
        Set(internationalMeals(meals: meals, userId: userId).compactMap { $0.country })
    }

    private func coupleCountries(meals: [Meal], userId: String) -> Set<String> {
        guard let partnerId else { return [] }
        let myCountries = uniqueCountries(meals: meals, userId: userId)
        let partnerCountries = Set(
            meals.filter { $0.userId == partnerId && $0.country != nil && $0.country != "TW" }
                .compactMap { $0.country }
        )
        return myCountries.intersection(partnerCountries)
    }

    private func maxSingleCountryCount(meals: [Meal], userId: String) -> Int {
        let intlMeals = internationalMeals(meals: meals, userId: userId)
        var countByCountry: [String: Int] = [:]
        for meal in intlMeals {
            if let country = meal.country {
                countByCountry[country, default: 0] += 1
            }
        }
        return countByCountry.values.max() ?? 0
    }

    // MARK: - Update Streak in Firestore

    func updateStreak() async {
        guard let userId = authRepo.currentUserId else { return }
        let meals = mealRepo.meals
        let currentStreak = calculateCurrentStreak(meals: meals, userId: userId)
        let maxStreak = max(currentStreak, authRepo.appUser?.maxStreak ?? 0)

        do {
            try await FirebaseConfig.userDocument(userId).updateData([
                "currentStreak": currentStreak,
                "maxStreak": maxStreak
            ])
        } catch {
            #if DEBUG
            print("[AchievementService] Failed to update streak: \(error)")
            #endif
        }
    }
}
