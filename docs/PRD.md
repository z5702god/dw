# PRD: 對味 — 情侶飲食日誌

> Version: 1.0
> Date: 2026-03-27
> Author: Luke
> Status: Released

---

## 1. 產品概述

### 1.1 一句話描述

一款情侶共用的 iOS 飲食紀錄 App，集結飲食日誌、美食地圖、每日紀錄與點數獎勵系統，讓異地情侶能共享美食體驗並以溫暖的方式鼓勵按時吃飯。

### 1.2 背景與動機

- 兩人分別在 **台北** 和 **台中**，各自發現好吃的餐廳時缺乏共同紀錄的工具
- 希望將美食心得結合地圖，下次見面時可以一起去吃
- 需要一個溫暖但有效的方式鼓勵俐瑤按時吃飯
- 市面上的飲食紀錄 App 缺乏「情侶共享」和「互動激勵」的功能

### 1.3 目標用戶

| 角色 | 描述 | 帳號 | 系統角色 |
|------|------|------|----------|
| **Luke** | 在台北，負責兌現獎勵、共同紀錄美食 | luke@dw.com | rewardFulfiller（兌現獎勵） |
| **俐瑤** | 在台中，賺取點數、共同紀錄美食 | kathy@dw.com | pointsEarner（賺點數） |
| **測試帳號** | App Store 審核用 | test@dw.com / test123 | — |

> 本產品 V1 僅供兩人使用，不開放註冊。

---

## 2. 產品目標與成功指標

### 2.1 核心目標

1. **共享美食紀錄** — 兩人的飲食心得即時同步，建立共同的美食回憶
2. **美食地圖探索** — 以地圖形式呈現去過的餐廳，方便未來規劃約會
3. **鼓勵按時吃飯** — 透過遊戲化機制（晚餐記錄 + 點數 + 獎勵）讓按時吃飯變成有趣的事

### 2.2 成功指標（V1）

| 指標 | 目標 |
|------|------|
| 每週新增飲食紀錄數 | >= 10 則（兩人合計） |
| 俐瑤每日晚餐記錄率 | >= 80% |
| 獎勵兌換頻率 | 每月至少 1 次 |

---

## 3. 功能需求

### 3.1 Feature 1: 用戶驗證（Auth）

**優先級：P0（必要）**

| 項目 | 說明 |
|------|------|
| 登入方式 | Email + 密碼 |
| 帳號建立 | 由開發者在 Firebase Console 預先建立（Luke、俐瑤、測試帳號） |
| 自動登入 | App 記住登入狀態，下次開啟不需重新登入 |
| 登出 | 在設定頁面提供登出按鈕，點擊後顯示確認 Alert |
| 帳號刪除 | 設定頁面提供刪除帳號功能（Apple 審核要求） |

**不包含（V1）：**
- 註冊功能
- 忘記密碼
- 社交帳號登入
- 邀請碼配對機制

#### 用戶流程

```
啟動 App
  ├─ 已登入 → 直接進入主畫面（TabView）
  └─ 未登入 → 登入頁面
                ├─ 輸入 Email + 密碼 → 登入成功 → 主畫面
                └─ 輸入錯誤 → 顯示錯誤訊息
```

---

### 3.2 Feature 2: 飲食紀錄 / 回味（Timeline）

**優先級：P0（必要）**

#### 3.2.1 紀錄內容

| 欄位 | 類型 | 必填 | 說明 |
|------|------|------|------|
| 用餐類型 | MealPlace 列舉 | 自動 | 外食（restaurant）/ 自煮（home），根據是否選擇餐廳自動判定 |
| 餐別 | MealSlot 列舉 | 自動 | 早餐（< 11 點）/ 午餐（< 16 點）/ 晚餐（>= 16 點），依當前時間自動判定 |
| 餐廳名稱 | 文字 | 外食時必填 | 可手動輸入或透過 MapKit 搜尋選擇 |
| 食物名稱 | 文字 | 自煮時必填 | 直接輸入食物名稱 |
| 照片 | 圖片（最多 5 張） | 否 | 從相簿選取 |
| 心得 | 長文字 | 否 | 飲食感想、推薦菜色等（可選） |
| 推薦評價 | 列舉 | 是 | 推薦 / 普通 / 踩雷 |
| 城市 | 列舉 | 自動 | 全台 22 縣市，選擇餐廳時自動帶入 |
| 地址 | 文字 | 自動 | 選擇餐廳時自動帶入 |
| 位置座標 | 經緯度 | 自動 | 選擇餐廳時自動帶入 |
| 紀錄者 | 用戶 ID | 自動 | 當前登入用戶 |
| 建立時間 | 時間戳 | 自動 | 伺服器時間 |

#### 3.2.2 時間軸列表（回味頁）

- 顯示兩人所有飲食紀錄，**按日期分組**（今天 / 昨天 / M月d日 星期X）
- 每則紀錄顯示：縮圖、名稱、心得摘要、評價標籤、城市、日期
- 頂部提供篩選器：全部 / 推薦 / 普通 / 踩雷（水平滑動 FilterChip）
- 點擊進入詳細頁面
- 支援左滑刪除（僅可刪除自己的紀錄）

#### 3.2.3 詳細頁面

- 照片輪播（支援左右滑動）
- 名稱 + 評價標籤
- 城市 + 日期
- 完整心得文字

#### 3.2.4 新增紀錄

- 表單包含：食物/餐廳名稱、「搜尋附近餐廳」按鈕（手動觸發 MapKit 搜尋）、照片選擇器、評價選擇（Segmented）、心得文字框（可選）
- 直接輸入名稱記為在家用餐（MealPlace.home），透過搜尋選擇餐廳則記為外食（MealPlace.restaurant）
- 照片上傳時壓縮至 JPEG 品質 0.7、最大邊 1200px
- 儲存時顯示上傳進度
- 儲存成功後：若獲得點數則顯示慶祝動畫（confetti），否則自動關閉表單

---

### 3.3 Feature 3: 美食地圖（Food Map）

**優先級：P0（必要）**

#### 3.3.1 地圖顯示

- 使用 Apple MapKit（SwiftUI Map API，iOS 17+）
- 每筆飲食紀錄在地圖上以標記（Annotation）顯示
- 標記顏色依評價區分：
  - 推薦 → 綠色
  - 普通 → 橘色
  - 踩雷 → 紅色

#### 3.3.2 城市切換

- 頂部提供城市選擇器，支援全台 22 縣市
- 切換時地圖自動移動至對應城市的預設中心點

#### 3.3.3 篩選功能

- 可按評價篩選：全部 / 推薦 / 普通 / 踩雷
- 篩選器以水平滑動的 Chip 呈現，覆蓋在地圖上方

#### 3.3.4 互動

- 點擊地圖標記 → 彈出半頁 Sheet 顯示該餐廳的詳細紀錄
- Sheet 支援拖動展開至全螢幕

---

### 3.4 Feature 4: 今日（Record）

**優先級：P0（必要）**

#### 3.4.1 頁面結構

| 區塊 | 說明 |
|------|------|
| 問候語 | 依時段顯示「早安/午安/晚安 {用戶名稱}」 |
| 對方動態 | 顯示「{對方名稱} 今天記錄了 N 筆」 |
| 今天的紀錄 | 列出自己今日已記錄的餐點，空白時顯示插圖 + 提示文字 |
| 今日挑戰 | **僅俐瑤可見**：顯示目前點數 + 晚餐記錄挑戰狀態 |

#### 3.4.2 晚餐挑戰（僅俐瑤）

| 規則 | 說明 |
|------|------|
| 獲點條件 | 俐瑤在 20:00 前記錄當日晚餐 |
| 點數 | +1 點 |
| 重複限制 | 每日僅限 1 次晚餐點數 |
| 狀態顯示 | 未記錄 + 未過時 → 顯示倒數計時；已記錄且準時 → 「+1 點！晚餐準時記錄」；已過時未記錄 → 鼓勵文字 |

#### 3.4.3 新增紀錄

- 右上角 + 按鈕，開啟新增紀錄表單（同 Feature 2）

---

### 3.5 Feature 5: 獎勵系統（Rewards）

**優先級：P0（必要）**

#### 3.5.1 角色分工

| 角色 | 看到的 UI | 可執行的操作 |
|------|-----------|-------------|
| **俐瑤**（pointsEarner） | 點數總覽 + 可兌換獎勵列表 + 已許願列表 + 已完成列表 | 兌換獎勵（扣點） |
| **Luke**（rewardFulfiller） | 待兌現列表 + 已完成列表 | 將獎勵標記為已完成 |

#### 3.5.2 獎勵清單

- 3 個預設獎勵在首次載入時自動 seed 到 Firestore
- 獎勵包含：名稱 + 所需點數
- 每個獎勵自動配對 emoji 圖示

#### 3.5.3 獎勵狀態流程

```
available（可兌換）→ redeemed（已許願）→ completed（已完成）
```

| 狀態 | 說明 |
|------|------|
| available | 俐瑤可見兌換按鈕，點數足夠時可兌換 |
| redeemed（已許願） | 俐瑤看到「已送出願望」；Luke 看到「待兌現」+ 完成按鈕 |
| completed | 雙方皆可見已完成列表，顯示完成日期 |

#### 3.5.4 兌換機制

| 規則 | 說明 |
|------|------|
| 兌換條件 | 當前點數 >= 獎勵所需點數 |
| 兌換動作 | 使用 **Firestore Transaction** 原子性扣點，確保不會超扣 |
| 點數不足 | 兌換按鈕 disabled |
| 確認流程 | 兌換前彈出確認 Alert |

#### 3.5.5 Luke 端通知

- 當俐瑤兌換獎勵後，Luke 端即時偵測到新的 redeemed 獎勵，彈出 Alert 通知

---

### 3.6 Feature 6: 設定（Settings）

**優先級：P1（重要）**

| 設定項目 | 說明 |
|----------|------|
| 用戶資訊 | 顯示頭像（姓名首字）、名稱、Email（唯讀）|
| 帳號刪除 | 按鈕，確認 Alert 後刪除帳號及所有資料（Apple 審核要求） |
| 登出 | 按鈕，確認 Alert 後登出 |
| 版本資訊 | 顯示 App 版本號 |

> 設定頁面從回味頁面的 toolbar gear icon 進入（Sheet 呈現）。

---

## 4. 資訊架構 (IA)

### 4.1 Tab 結構

```
App（對味）
├── Tab 1: 回味（Timeline）
│   ├── 飲食紀錄列表（按日期分組：今天/昨天/日期）
│   ├── 篩選（全部/推薦/普通/踩雷）
│   ├── → 紀錄詳細頁
│   ├── → 新增紀錄表單（Sheet）
│   └── → 設定頁面（Sheet，從 toolbar gear icon 進入）
│       ├── 用戶資訊
│       ├── 刪除帳號
│       └── 登出
│
├── Tab 2: 地圖（Map）
│   ├── 美食地圖（城市切換：全台 22 縣市）
│   ├── 篩選（推薦/普通/踩雷）
│   └── → 點擊標記 → 紀錄詳細頁（Sheet）
│
├── Tab 3: 今日（Record）
│   ├── 問候語 + 對方紀錄狀態
│   ├── 今天的紀錄列表
│   ├── 今日挑戰（俐瑤限定：晚餐 + 點數）
│   └── → 新增紀錄表單（Sheet）
│
└── Tab 4: 獎勵（Rewards）
    ├── [俐瑤] 點數總覽 + 可兌換獎勵 + 已許願 + 已完成
    └── [Luke] 待兌現 + 已完成
```

---

## 5. 技術架構

### 5.1 技術棧

| 層面 | 技術 |
|------|------|
| 平台 | iOS 17.0+ |
| 語言 | Swift 5.9+ |
| UI 框架 | SwiftUI |
| 架構模式 | MVVM + `@Observable` |
| 後端 | Firebase |
| 驗證 | Firebase Authentication（Email/Password）|
| 資料庫 | Cloud Firestore |
| 檔案儲存 | Firebase Storage |
| 地圖 | Apple MapKit（SwiftUI Map API + MKLocalSearch） |
| 圖片快取 | Kingfisher |
| 套件管理 | Swift Package Manager |

### 5.2 Firestore 資料結構

```
couples/
  couple_001/
    ├── user1Id: String
    ├── user2Id: String
    ├── createdAt: Timestamp
    │
    ├── meals/{mealId}
    │   ├── userId: String
    │   ├── mealPlace: "restaurant" | "home"
    │   ├── mealSlot: "breakfast" | "lunch" | "dinner"
    │   ├── restaurantName: String?          // 外食時的餐廳名
    │   ├── foodName: String?                // 自煮時的食物名
    │   ├── review: String
    │   ├── rating: "recommended" | "ok" | "bad"
    │   ├── photoURLs: [String]
    │   ├── latitude: Double?
    │   ├── longitude: Double?
    │   ├── city: String?                    // 全台 22 縣市 raw value
    │   ├── address: String?
    │   └── createdAt: Timestamp
    │
    └── rewards/{rewardId}
        ├── title: String
        ├── pointsCost: Int
        ├── createdBy: String
        ├── status: "available" | "redeemed" | "completed"
        ├── redeemedAt: Timestamp?
        ├── redeemedBy: String?
        ├── completedAt: Timestamp?
        ├── completedBy: String?
        └── createdAt: Timestamp

users/
  {userId}/
    ├── email: String
    ├── displayName: String
    ├── coupleId: String
    ├── totalPoints: Int
    └── role: "pointsEarner" | "rewardFulfiller"
```

> 注意：原 PRD 中的 `checkins` collection 已移除，晚餐點數直接透過查詢 meals 來判定。
> 獎勵使用 `status` 列舉取代原本的 `isRedeemed` 布林值。
> 用戶不再有 `reminderSettings` 欄位。

### 5.3 安全規則

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 情侶空間：只有配對的兩人可以存取
    match /couples/{coupleId}/{document=**} {
      allow read, write: if request.auth != null
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.coupleId == coupleId;
    }
    // 用戶資料：任何已登入用戶可讀，只有本人可寫
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
  }
}
```

---

## 6. 非功能需求

### 6.1 效能

| 項目 | 目標 |
|------|------|
| App 啟動時間 | < 2 秒（含 Firebase 初始化）|
| 照片上傳 | 壓縮後單張 < 500KB，5 張總計 < 5 秒（Wi-Fi）|
| 資料同步 | Firestore 即時同步，延遲 < 1 秒 |
| 地圖載入 | < 1 秒顯示所有標記（預期 < 200 筆紀錄）|

### 6.2 離線支援

- Firestore 內建離線快取，斷網時可瀏覽已載入的紀錄
- 離線新增的紀錄在恢復連線後自動同步

### 6.3 隱私與安全

- 所有資料僅限配對的兩人存取（Firestore Security Rules）
- 照片存放在 Firebase Storage，僅透過下載 URL 存取
- 不收集任何第三方分析數據（V1）
- 不需要位置權限（餐廳搜尋使用 MapKit MKLocalSearch，不需 GPS）
- 已加入 `PrivacyInfo.xcprivacy` 隱私清單
- 隱私權政策託管於 GitHub Pages

### 6.4 可靠性

- Firebase 99.95% SLA
- 點數扣除使用 Firestore Transaction 確保原子性
- 所有 `print()` 包裹在 `#if DEBUG` 中，Release 版本不輸出除錯訊息

---

## 7. 設計規範

### 7.1 品牌

| 項目 | 說明 |
|------|------|
| App 名稱 | 對味 |
| App Icon | 橘色漸層背景，愛心 + 餐具圖案 |
| 風格 | 溫暖、情侶友善的文案語調 |
| 分享署名 | 「— 來自對味 app」 |

### 7.2 色彩系統

| 用途 | 顏色 |
|------|------|
| 主色 | Orange（appPrimary）|
| 推薦 | Green |
| 普通 | Orange |
| 踩雷 | Red |
| 背景 | System Background（支援 Dark Mode）|
| 次要文字 | Secondary Label |

### 7.3 字體

- 使用系統預設字體（SF Pro）
- 數字使用 `.system(.largeTitle, design: .rounded, weight: .bold)` 圓角設計

### 7.4 圖示

使用 SF Symbols：
- 回味 Tab: `book.fill`
- 地圖 Tab: `map.fill`
- 今日 Tab: `calendar`
- 獎勵 Tab: `gift.fill`
- 設定: `gearshape`
- 早餐: `sun.rise`
- 午餐: `sun.max`
- 晚餐: `moon.stars`
- 外食: `fork.knife`
- 自煮: `house`

### 7.5 互動回饋

- 所有主要互動加入 `.sensoryFeedback`（觸覺回饋）
- Tab 切換：`.selection`
- 儲存成功：`.success`
- 登出/刪除：`.warning`
- 獲得點數：全螢幕慶祝動畫（CelebrationView，confetti 效果）

---

## 8. 版本規劃

### V1.0（已發佈）

- [x] 用戶驗證（預設帳號登入 + 測試帳號）
- [x] 飲食紀錄 CRUD + 時間軸（按日期分組）
- [x] 支援外食與自煮兩種記錄模式
- [x] MapKit 餐廳搜尋（手動觸發）
- [x] 美食地圖（全台 22 縣市）
- [x] 今日頁面（問候語 + 對方狀態 + 今日紀錄）
- [x] 晚餐挑戰 + 點數（俐瑤限定，20:00 前記錄得 1 點）
- [x] 獎勵系統（角色分工 + 狀態流程）
- [x] 預設獎勵自動 seed
- [x] 慶祝動畫（confetti）
- [x] 設定頁面（帳號刪除 + 登出確認）
- [x] PrivacyInfo.xcprivacy + 隱私權政策
- [x] 觸覺回饋（sensory feedback）
- [x] Debug print 保護（#if DEBUG）

### V1.1（未來考慮）

- [ ] 飲食紀錄搜尋功能
- [ ] 紀錄編輯功能
- [ ] 深色模式優化
- [ ] 更多獎勵管理功能（新增/刪除獎勵）

### V2.0（未來考慮）

- [ ] 雙人聊天功能
- [ ] 美食照片 AI 辨識（自動填入餐廳名稱）
- [ ] 「想去清單」— 標記還沒去但想嘗試的餐廳
- [ ] Widget — 桌面小工具顯示對方紀錄狀態
- [ ] 開放更多用戶配對（邀請碼機制）

---

## 9. 風險與限制

| 風險 | 影響 | 緩解措施 |
|------|------|----------|
| Firebase 免費額度限制 | Spark plan: 1GB Storage, 10GB/month transfer | 照片壓縮至 500KB 以下，兩人使用量極低 |
| iOS 17+ 最低版本 | 排除舊裝置 | 目標用戶（兩人）均使用新裝置 |
| 無 Android 版本 | 若有一方換 Android 無法使用 | V1 不處理，未來可考慮跨平台 |
| 帳號固定無法擴展 | 無法新增用戶 | V1 設計意圖，V2 可加入邀請機制 |

---

## 10. 附錄

### 10.1 Firestore 免費額度（Spark Plan）

| 資源 | 每日免費額度 |
|------|-------------|
| 文件讀取 | 50,000 次 |
| 文件寫入 | 20,000 次 |
| 文件刪除 | 20,000 次 |
| 儲存空間 | 1 GB |
| 網路流出 | 10 GB/月 |

> 以兩人每日各新增 3-5 筆紀錄計算，遠低於免費額度。

### 10.2 名詞解釋

| 名詞 | 定義 |
|------|------|
| 情侶空間（Couple Space）| Firestore 中 `couples/{coupleId}` 下的所有資料，兩人共享 |
| pointsEarner | 賺取點數的角色（俐瑤），透過按時記錄晚餐獲得點數 |
| rewardFulfiller | 兌現獎勵的角色（Luke），負責將已兌換的獎勵標記為已完成 |
| 晚餐挑戰 | 俐瑤在 20:00 前記錄晚餐可獲得 1 點 |
| 評價（Rating）| 對餐廳/食物的推薦程度：推薦 / 普通 / 踩雷 |
| 獎勵狀態 | available（可兌換）→ redeemed（已許願）→ completed（已完成） |
| MealPlace | 用餐地點類型：外食（restaurant）/ 自煮（home） |
| MealSlot | 餐別：早餐 / 午餐 / 晚餐，依當前時間自動判定 |

### 10.3 已移除功能（相較原始 PRD）

以下功能在開發過程中經評估後移除：

| 功能 | 移除原因 |
|------|----------|
| 打卡系統（Check-In） | 簡化為晚餐記錄即得點，不需獨立打卡頁面 |
| 吃飯提醒通知（Notifications） | 使用者要求移除 |
| 提醒時間設定 | 隨通知功能一併移除 |
| 三餐打卡點數（10/3 點） | 簡化為僅晚餐 1 點 |
