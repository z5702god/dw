import Foundation

enum AchievementDefinitions {
    static let all: [Achievement] = exploration + habit + couple + reward

    // MARK: - 飲食探索 (6)

    static let exploration: [Achievement] = [
        Achievement(
            id: "meals_1",
            title: "第一口",
            description: "記錄第 1 餐",
            icon: "fork.knife.circle.fill",
            tier: .bronze,
            category: .exploration,
            condition: .mealCount(1)
        ),
        Achievement(
            id: "meals_10",
            title: "美食新手",
            description: "記錄滿 10 餐",
            icon: "leaf.fill",
            tier: .bronze,
            category: .exploration,
            condition: .mealCount(10)
        ),
        Achievement(
            id: "meals_50",
            title: "半百饕客",
            description: "記錄滿 50 餐",
            icon: "flame.fill",
            tier: .silver,
            category: .exploration,
            condition: .mealCount(50)
        ),
        Achievement(
            id: "meals_100",
            title: "百味人生",
            description: "記錄滿 100 餐",
            icon: "crown.fill",
            tier: .gold,
            category: .exploration,
            condition: .mealCount(100)
        ),
        Achievement(
            id: "regions_5",
            title: "城市獵人",
            description: "在 5 個不同城市記錄",
            icon: "map.fill",
            tier: .silver,
            category: .exploration,
            condition: .regionCount(5)
        ),
        Achievement(
            id: "regions_10",
            title: "美食探險家",
            description: "在 10 個不同城市記錄",
            icon: "globe.asia.australia.fill",
            tier: .gold,
            category: .exploration,
            condition: .regionCount(10)
        ),
    ]

    // MARK: - 打卡習慣 (5)

    static let habit: [Achievement] = [
        Achievement(
            id: "first_point",
            title: "準時小天使",
            description: "首次準時記錄晚餐得點",
            icon: "clock.badge.checkmark",
            tier: .bronze,
            category: .habit,
            condition: .firstPoint
        ),
        Achievement(
            id: "streak_3",
            title: "三日不懈",
            description: "連續 3 天記錄",
            icon: "flame",
            tier: .bronze,
            category: .habit,
            condition: .streak(3)
        ),
        Achievement(
            id: "streak_7",
            title: "一週達人",
            description: "連續 7 天記錄",
            icon: "flame.fill",
            tier: .silver,
            category: .habit,
            condition: .streak(7)
        ),
        Achievement(
            id: "monthly_perfect",
            title: "月度全勤",
            description: "單月每天都有記錄",
            icon: "calendar.badge.checkmark",
            tier: .gold,
            category: .habit,
            condition: .monthlyPerfect
        ),
        Achievement(
            id: "streak_30",
            title: "打卡傳說",
            description: "連續 30 天記錄",
            icon: "bolt.shield.fill",
            tier: .diamond,
            category: .habit,
            condition: .streak(30)
        ),
    ]

    // MARK: - 情侶互動 (5)

    static let couple: [Achievement] = [
        Achievement(
            id: "first_duo",
            title: "初次約會",
            description: "第一次兩人記錄同一餐",
            icon: "heart.circle.fill",
            tier: .bronze,
            category: .couple,
            condition: .firstDuo
        ),
        Achievement(
            id: "same_rating_3",
            title: "心有靈犀",
            description: "同一餐兩人評分相同 3 次",
            icon: "link.circle.fill",
            tier: .silver,
            category: .couple,
            condition: .sameRating(3)
        ),
        Achievement(
            id: "both_recommend_10",
            title: "對味鑑定師",
            description: "兩人都推薦的餐廳滿 10 間",
            icon: "star.circle.fill",
            tier: .gold,
            category: .couple,
            condition: .bothRecommend(10)
        ),
        Achievement(
            id: "duo_meals_100",
            title: "百日宴",
            description: "一起記錄滿 100 餐",
            icon: "trophy.fill",
            tier: .gold,
            category: .couple,
            condition: .duoMealCount(100)
        ),
        Achievement(
            id: "monthly_sync",
            title: "同步率 100%",
            description: "單月兩人記錄天數都 ≥ 20 天",
            icon: "diamond.fill",
            tier: .diamond,
            category: .couple,
            condition: .monthlySync
        ),
    ]

    // MARK: - 獎勵相關 (4)

    static let reward: [Achievement] = [
        Achievement(
            id: "first_redeem",
            title: "許願新手",
            description: "第一次兌換獎勵",
            icon: "wand.and.stars",
            tier: .bronze,
            category: .reward,
            condition: .firstRedeem
        ),
        Achievement(
            id: "completed_5",
            title: "願望成真",
            description: "獎勵被完成 5 次",
            icon: "hands.sparkles.fill",
            tier: .silver,
            category: .reward,
            condition: .completedRewards(5)
        ),
        Achievement(
            id: "points_100",
            title: "點數大亨",
            description: "累積 100 點",
            icon: "dollarsign.circle.fill",
            tier: .silver,
            category: .reward,
            condition: .totalPoints(100)
        ),
        Achievement(
            id: "all_rewards",
            title: "圓夢達人",
            description: "累計兌換獎勵 10 次",
            icon: "sparkles",
            tier: .diamond,
            category: .reward,
            condition: .totalRedemptions(10)
        ),
    ]

    static func find(by id: String) -> Achievement? {
        all.first { $0.id == id }
    }
}
