# 成就徽章系統設計規格

## Context

對味 app 目前的獎勵系統只有「晚餐準時記錄得 1 點 → 兌換獎勵」的單一機制。為了增加用戶黏性和收集樂趣，新增成就徽章系統，讓 Kathy 和 Luke 在記錄飲食的過程中解鎖各種成就，獲得額外點數獎勵。

## 設計決策

- **架構**：方案 A — 靜態成就清單，定義寫死在 code 裡
- **理由**：只有兩人使用，更新 app 很快，不需要 Firebase 動態管理的複雜度
- **調性**：情侶互動為主題 + 遊戲化成就收集
- **點數歸屬**：成就點數只給 Kathy（pointsEarner），與現有點數系統一致。Luke 的成就純收集展示，不影響點數。未來可擴展雙方各自點數。
- **連續打卡定義**：一天內有任何一餐記錄即算「有記錄」，以裝置本地時區的日曆日為準。每次 saveMeal 後計算：若昨天也有記錄 → currentStreak +1，否則重設為 1。
- **上線遷移**：首次啟動時一次性掃描現有餐點資料，批次解鎖符合條件的成就，以 toast 彙總通知（「你已解鎖 X 個成就！」）而非逐個彈動畫。

---

## 1. 稀有度分級

| 等級 | Key | 顏色 | 點數獎勵 | 定位 |
|------|-----|------|---------|------|
| 銅 | bronze | 棕色 | +3 點 | 入門，很快能解鎖 |
| 銀 | silver | 銀灰色 | +8 點 | 中等，需要一些累積 |
| 金 | gold | 金色 | +15 點 | 困難，持續投入 |
| 鑽石 | diamond | 紫藍漸層 | +30 點 | 超稀有，長期目標 |

## 2. 成就清單（20 個）

### 🍽 飲食探索（6 個）

| ID | 名稱 | 條件 | 稀有度 |
|----|------|------|--------|
| meals_1 | 第一口 | 記錄第 1 餐 | 銅 |
| meals_10 | 美食新手 | 記錄滿 10 餐 | 銅 |
| meals_50 | 半百饕客 | 記錄滿 50 餐 | 銀 |
| meals_100 | 百味人生 | 記錄滿 100 餐 | 金 |
| regions_5 | 城市獵人 | 在 5 個不同城市/地區記錄（依 Meal.city 欄位，僅計有地點的餐點） | 銀 |
| regions_10 | 美食探險家 | 在 10 個不同城市/地區記錄 | 金 |

### ⏰ 打卡習慣（5 個）

| ID | 名稱 | 條件 | 稀有度 |
|----|------|------|--------|
| first_point | 準時小天使 | 首次準時記錄晚餐得點 | 銅 |
| streak_3 | 三日不懈 | 連續 3 天記錄 | 銅 |
| streak_7 | 一週達人 | 連續 7 天記錄 | 銀 |
| streak_30 | 打卡傳說 | 連續 30 天記錄 | 鑽石 |
| monthly_perfect | 月度全勤 | 已完成的日曆月中每天都有記錄（月底結算） | 金 |

### 💕 情侶互動（5 個）

| ID | 名稱 | 條件 | 稀有度 |
|----|------|------|--------|
| first_duo | 初次約會 | 第一次兩人記錄同一餐 | 銅 |
| same_rating_3 | 心有靈犀 | 同一餐廳同一天兩人評分相同累計 3 次 | 銀 |
| both_recommend_10 | 對味鑑定師 | 兩人都給「推薦」滿 10 間 | 金 |
| duo_meals_100 | 百日宴 | 一起記錄滿 100 餐 | 金 |
| monthly_sync | 同步率 100% | 已完成的日曆月中，兩人記錄天數相同且都 ≥ 20 天 | 鑽石 |

### 🎁 獎勵相關（4 個）

| ID | 名稱 | 條件 | 稀有度 |
|----|------|------|--------|
| first_redeem | 許願新手 | 第一次兌換獎勵 | 銅 |
| completed_5 | 願望成真 | 獎勵被完成 5 次 | 銀 |
| points_100 | 點數大亨 | 累積 100 點（含成就獎勵） | 銀 |
| all_rewards | 圓夢達人 | 累計兌換獎勵 10 次 | 鑽石 |

## 3. UI / UX 設計

### 成就頁面入口
- 在獎勵頁面（RewardListView）加一個「成就」tab 或入口按鈕

### 成就牆（Achievement Wall）
- LazyVGrid 網格排列，分類用 Section Header
- **已解鎖**：全彩 SF Symbol 圖示 + 稀有度色系邊框光暈
- **未解鎖**：灰色剪影 + 進度條（例如 "3/10 餐"）
- 點擊展開詳情卡片：名稱、描述、解鎖日期、獲得點數
- 頂部顯示「已解鎖 X / 20」+ 圓形進度環

### 解鎖慶祝動畫（依稀有度分級）
- **銅**：輕微彈跳 + 小粒子效果
- **銀**：中等撒花 + 光暈擴散
- **金**：大型撒花 + 震動回饋 + 閃光效果
- **鑽石**：全螢幕特效 + 延長動畫 + 強震動

### 解鎖時機
- 每次 `saveMeal()` 後批次檢查所有未解鎖成就
- 多個同時解鎖時依序彈出慶祝動畫

## 4. 技術架構

### 新增檔案

| 檔案路徑 | 用途 |
|---------|------|
| `Models/Achievement.swift` | Achievement struct、AchievementTier enum、AchievementCategory enum |
| `Data/AchievementDefinitions.swift` | 靜態成就清單定義（allAchievements 陣列） |
| `Services/AchievementService.swift` | 成就檢查邏輯、解鎖判定、連續打卡計算 |
| `ViewModels/AchievementViewModel.swift` | 成就頁面 state 管理、@Observable |
| `Views/Achievement/AchievementWallView.swift` | 成就牆主頁面 |
| `Views/Achievement/AchievementCardView.swift` | 單個成就卡片元件 |
| `Components/AchievementUnlockView.swift` | 解鎖慶祝動畫（依稀有度分級） |

### 修改檔案

| 檔案路徑 | 修改內容 |
|---------|---------|
| `Models/User.swift` | AppUser 加 `currentStreak: Int`、`maxStreak: Int` 欄位 |
| `Services/PointsService.swift` | 新增成就解鎖時的加點方法 |
| `ViewModels/MealFormViewModel.swift` | saveMeal 後觸發 AchievementService.checkAll() |
| `Views/Rewards/RewardListView.swift` | 加入成就頁面入口按鈕 |

### 資料模型

```swift
struct Achievement: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String              // SF Symbol name
    let tier: AchievementTier
    let category: AchievementCategory
    let condition: AchievementCondition
}

enum AchievementTier: String, CaseIterable {
    case bronze, silver, gold, diamond

    var pointsReward: Int {
        switch self {
        case .bronze: 3
        case .silver: 8
        case .gold: 15
        case .diamond: 30
        }
    }
}

enum AchievementCategory: String, CaseIterable {
    case exploration   // 飲食探索
    case habit         // 打卡習慣
    case couple        // 情侶互動
    case reward        // 獎勵相關
}

enum AchievementCondition {
    case mealCount(Int)              // meals_1, meals_10, meals_50, meals_100
    case regionCount(Int)            // regions_5, regions_10
    case firstPoint                  // first_point
    case streak(Int)                 // streak_3, streak_7, streak_30
    case monthlyPerfect              // monthly_perfect
    case firstDuo                    // first_duo
    case sameRating(Int)             // same_rating_3
    case bothRecommend(Int)          // both_recommend_10
    case duoMealCount(Int)           // duo_meals_100
    case monthlySync                 // monthly_sync
    case firstRedeem                 // first_redeem
    case completedRewards(Int)       // completed_5
    case totalPoints(Int)            // points_100
    case totalRedemptions(Int)       // all_rewards
}

struct UnlockedAchievement: Codable {
    let achievementId: String
    let unlockedAt: Date
    let pointsAwarded: Int
}
```

### Firestore 結構

```
users/{userId}/achievements/{achievementId}
  ├── unlockedAt: Timestamp
  └── pointsAwarded: Int

users/{userId}
  ├── totalPoints: Int        (existing)
  ├── currentStreak: Int      (new)
  └── maxStreak: Int          (new)
```

### 資料取得策略

只有兩人使用，資料量小，直接使用已在記憶體中的 repository 資料：
- **餐點數量/地區**：從 `MealRepository.meals`（已有 real-time listener）計算
- **連續打卡**：從 `AppUser.currentStreak`（每次 saveMeal 更新）
- **情侶互動**：從 `MealRepository.meals` 過濾雙方記錄比對
- **獎勵相關**：從 `RewardRepository` 的 completed/redeemed 列表計算

不需額外查詢 Firestore，所有資料都已在 memory 中。

### 錯誤處理

成就解鎖是 fire-and-forget：如果 Firestore 寫入失敗，靜默忽略。下次 saveMeal 時會重新檢查並再次嘗試解鎖。不會影響核心的餐點記錄功能。

### 檢查流程

```
saveMeal()
  → AchievementService.checkAll(meals, user, rewards)
  → 對比已解鎖清單，找出新達標的成就
  → Firestore batch write: 寫入解鎖紀錄 + 增加點數
  → 回傳 [Achievement] 新解鎖列表
  → MealFormView 依序顯示 AchievementUnlockView
```

## 5. 驗證計畫

- [ ] 在模擬器記錄第 1 餐 → 確認「第一口」銅牌解鎖 + 3 點
- [ ] 連續記錄 3 天 → 確認「三日不懈」解鎖
- [ ] 同一餐兩人都記錄 → 確認「初次約會」解鎖
- [ ] 確認已解鎖成就不會重複觸發
- [ ] 確認多個同時解鎖時動畫依序顯示
- [ ] 確認成就牆正確顯示解鎖/未解鎖狀態和進度
- [ ] 確認點數正確加入 totalPoints
