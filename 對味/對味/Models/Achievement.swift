import Foundation
import SwiftUI
import FirebaseFirestore

// MARK: - Achievement Tier (稀有度)

enum AchievementTier: String, CaseIterable, Comparable {
    case bronze, silver, gold, diamond

    var pointsReward: Int {
        switch self {
        case .bronze: return 3
        case .silver: return 8
        case .gold: return 15
        case .diamond: return 30
        }
    }

    var displayName: String {
        switch self {
        case .bronze: return "銅"
        case .silver: return "銀"
        case .gold: return "金"
        case .diamond: return "鑽石"
        }
    }

    var color: Color {
        switch self {
        case .bronze: return Color(red: 0.72, green: 0.45, blue: 0.20)
        case .silver: return Color(red: 0.66, green: 0.66, blue: 0.72)
        case .gold: return Color(red: 1.0, green: 0.84, blue: 0.0)
        case .diamond: return Color(red: 0.58, green: 0.44, blue: 0.86)
        }
    }

    var glowColor: Color {
        switch self {
        case .bronze: return Color(red: 0.72, green: 0.45, blue: 0.20).opacity(0.5)
        case .silver: return Color(red: 0.66, green: 0.66, blue: 0.72).opacity(0.5)
        case .gold: return Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.5)
        case .diamond: return Color(red: 0.58, green: 0.44, blue: 0.86).opacity(0.6)
        }
    }

    private var sortOrder: Int {
        switch self {
        case .bronze: return 0
        case .silver: return 1
        case .gold: return 2
        case .diamond: return 3
        }
    }

    static func < (lhs: AchievementTier, rhs: AchievementTier) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }
}

// MARK: - Achievement Category (分類)

enum AchievementCategory: String, CaseIterable {
    case exploration // 飲食探索
    case habit       // 打卡習慣
    case couple      // 情侶互動
    case reward      // 獎勵相關

    var displayName: String {
        switch self {
        case .exploration: return "飲食探索"
        case .habit: return "打卡習慣"
        case .couple: return "情侶互動"
        case .reward: return "獎勵相關"
        }
    }

    var icon: String {
        switch self {
        case .exploration: return "fork.knife"
        case .habit: return "clock.badge.checkmark"
        case .couple: return "heart.fill"
        case .reward: return "gift.fill"
        }
    }
}

// MARK: - Achievement Condition (判定條件)

enum AchievementCondition {
    case mealCount(Int)
    case regionCount(Int)
    case firstPoint
    case streak(Int)
    case monthlyPerfect
    case firstDuo
    case sameRating(Int)
    case bothRecommend(Int)
    case duoMealCount(Int)
    case monthlySync
    case firstRedeem
    case completedRewards(Int)
    case totalPoints(Int)
    case totalRedemptions(Int)

    /// 用於進度顯示的目標值
    var targetValue: Int? {
        switch self {
        case .mealCount(let n): return n
        case .regionCount(let n): return n
        case .streak(let n): return n
        case .sameRating(let n): return n
        case .bothRecommend(let n): return n
        case .duoMealCount(let n): return n
        case .completedRewards(let n): return n
        case .totalPoints(let n): return n
        case .totalRedemptions(let n): return n
        case .firstPoint, .monthlyPerfect, .firstDuo, .monthlySync, .firstRedeem:
            return nil
        }
    }
}

// MARK: - Achievement (成就定義)

struct Achievement: Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let tier: AchievementTier
    let category: AchievementCategory
    let condition: AchievementCondition

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Achievement, rhs: Achievement) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Unlocked Achievement (Firestore 紀錄)

struct UnlockedAchievement: Codable, Identifiable {
    @DocumentID var id: String?
    var achievementId: String
    var unlockedAt: Date
    var pointsAwarded: Int

    enum CodingKeys: String, CodingKey {
        case id
        case achievementId
        case unlockedAt
        case pointsAwarded
    }
}
