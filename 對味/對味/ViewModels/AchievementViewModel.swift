import SwiftUI
import FirebaseFirestore

@MainActor
@Observable
final class AchievementViewModel {
    private let authRepo = AuthRepository.shared
    private let mealRepo = MealRepository.shared
    private let achievementService = AchievementService.shared

    var unlockedIds: Set<String> {
        authRepo.appUser?.unlockedAchievementIds ?? []
    }

    var unlockedCount: Int {
        unlockedIds.count
    }

    var totalCount: Int {
        AchievementDefinitions.all.count
    }

    var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(unlockedCount) / Double(totalCount)
    }

    func isUnlocked(_ achievement: Achievement) -> Bool {
        unlockedIds.contains(achievement.id)
    }

    func unlockedDate(for achievement: Achievement) -> Date? {
        guard let timestamp = authRepo.appUser?.unlockedAchievements?[achievement.id] else { return nil }
        return Date(timeIntervalSince1970: timestamp)
    }

    func progressValue(for achievement: Achievement) -> (current: Int, target: Int)? {
        achievementService.progressValue(for: achievement, unlockedIds: unlockedIds)
    }

    func achievementsByCategory(_ category: AchievementCategory) -> [Achievement] {
        AchievementDefinitions.all.filter { $0.category == category }
    }

    /// 檢查並解鎖所有符合條件的成就
    func checkAndUnlockAll() async {
        // 等待餐點資料載入（最多等 5 秒）
        var waitCount = 0
        while mealRepo.meals.isEmpty && waitCount < 50 {
            try? await Task.sleep(for: .milliseconds(100))
            waitCount += 1
        }

        // 等待 user 載入
        waitCount = 0
        while authRepo.appUser == nil && waitCount < 50 {
            try? await Task.sleep(for: .milliseconds(100))
            waitCount += 1
        }

        #if DEBUG
        print("[AchievementVM] checkAndUnlockAll — meals: \(mealRepo.meals.count), user: \(authRepo.appUser?.displayName ?? "nil"), unlocked: \(unlockedIds)")
        #endif

        let newlyUnlocked = achievementService.checkAll(unlockedIds: unlockedIds)

        #if DEBUG
        print("[AchievementVM] newlyUnlocked: \(newlyUnlocked.map { $0.title })")
        #endif

        if !newlyUnlocked.isEmpty {
            await achievementService.unlockAchievements(newlyUnlocked)
        }
    }

    /// 首次啟動遷移
    func runMigrationIfNeeded() async -> [Achievement] {
        // 等待餐點資料載入
        var waitCount = 0
        while mealRepo.meals.isEmpty && waitCount < 50 {
            try? await Task.sleep(for: .milliseconds(100))
            waitCount += 1
        }

        while authRepo.appUser == nil && waitCount < 50 {
            try? await Task.sleep(for: .milliseconds(100))
            waitCount += 1
        }

        #if DEBUG
        print("[AchievementVM] Migration — meals: \(mealRepo.meals.count), unlocked: \(unlockedIds)")
        #endif

        return await achievementService.runMigration(unlockedIds: unlockedIds)
    }
}
