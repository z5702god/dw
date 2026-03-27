# UI Pencil Design Alignment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update all SwiftUI views to precisely match the Pencil design file (pencil-new.pen) across 5 screens.

**Architecture:** Pure view-layer changes — no ViewModel/Repository/Model changes needed. Each view file is updated independently to match the Pencil design's spacing, sizing, layout, and styling.

**Tech Stack:** SwiftUI, iOS 17+, SF Symbols (mapped from Pencil's Lucide icons)

---

## Pencil → SF Symbol Icon Mapping

| Pencil (Lucide) | SF Symbol | Usage |
|-----------------|-----------|-------|
| book-open | book | Tab: 日誌 |
| map-pin | map | Tab: 地圖 |
| circle-check-big | checkmark.circle | Tab: 打卡 |
| gift | gift | Tab: 獎勵 |
| sunrise | sunrise | 早餐 |
| sun | sun.max | 午餐 |
| moon | moon.stars | 晚餐 |
| star | star.fill | 獎勵點數 |
| utensils | fork.knife | 地圖 pin |
| plus | plus | 新增按鈕 |

---

### Task 1: LoginView — Match Welcome Screen Design

**Files:**
- Modify: `對味/對味/Views/Auth/LoginView.swift`

**Design spec (Pencil frame: kqIEX "1. Welcome"):**
- White background, content bottom-aligned (not centered)
- Hero: 280x280 circle with couple illustration (use fork.knife SF Symbol as fallback)
- Text group: gap 12, title 40pt bold tracking -1.5, subtitle 20pt #8E8E93, description 16pt #AEAEB2 center-aligned lineHeight 1.5
- Button group: at bottom, padding [0,32,60,32], orange button height 54, cornerRadius 14, full width, "登入" 17pt semibold white
- Overall VStack gap 32 between sections

**Differences from current code:**
1. Hero circle: 220 → 280
2. Layout: centered (Spacer top+bottom) → bottom-aligned (single Spacer at top, fixed bottom padding 60)
3. Bottom padding: `.padding(.bottom, 60)` already exists but Spacer above button pushes content to center

- [ ] **Step 1: Update LoginView layout and sizing**

```swift
// In LoginView body:
// 1. Change hero circle size from 220 to 280
// 2. Change icon font size from 64 to 80
// 3. Remove the Spacer() between text group and login section
// 4. Keep only the top Spacer() so content flows to bottom
// 5. Ensure bottom padding is 60
```

- [ ] **Step 2: Build and verify on simulator**

Run: Xcode Cmd+B, then visually compare with Pencil screenshot

- [ ] **Step 3: Commit**

---

### Task 2: TimelineView + MealCardView — Match Timeline Screen Design

**Files:**
- Modify: `對味/對味/Views/Timeline/TimelineView.swift`
- Modify: `對味/對味/Views/Timeline/MealCardView.swift`

**Design spec (Pencil frame: qe1dv "2. Timeline"):**
- Background: #F2F2F7
- Large title "飲食日誌"
- Filter chips: height 32, cornerRadius 16, padding horizontal 14, gap 8
  - Active: fill #FF9500, text white 14pt semibold
  - Inactive: fill #E5E5EA, text #3C3C43 14pt medium
- Cards: white fill, cornerRadius 12, padding 12, gap 14 between photo and info
  - Photo: 72x72, cornerRadius 10
  - Title: 17pt semibold #1C1C1E + RatingBadge on right
  - Review: 14pt #8E8E93, lineHeight 1.35, letterSpacing -0.15
  - Meta: 12pt #AEAEB2 "城市 · 日期 · 用戶名"
- Card list: gap 10, padding horizontal 20, padding top 16

**Differences from current code:**
- FilterChip uses Capsule() shape → should be cornerRadius 16 (matches Capsule visually, OK)
- FilterChip height not explicitly set → should be height 32
- Card review line spacing 2 → should match lineHeight 1.35 (lineSpacing ~5)
- Overall structure is already very close

- [ ] **Step 1: Update FilterChip height and padding**

```swift
// FilterChip: add explicit .frame(height: 32) and adjust padding
```

- [ ] **Step 2: Update MealCardView review text line spacing**

```swift
// Change .lineSpacing(2) to .lineSpacing(5) to match lineHeight 1.35
```

- [ ] **Step 3: Build and verify**

- [ ] **Step 4: Commit**

---

### Task 3: CheckInView — Match Check-In Screen Design

**Files:**
- Modify: `對味/對味/Views/CheckIn/CheckInView.swift`

**Design spec (Pencil frame: M8KGf "3. Check-In"):**
- Large title "打卡"
- Points Ring Card: white fill, cornerRadius 12, padding 24, gap 24
  - Ring: 100x100 circle, stroke 10px, background #F2F2F7, foreground #FF9500
  - Ring center: points number 28pt bold, "點" 13pt below
  - Right info: "總點數" 13pt medium #8E8E93, points "320 點" 22pt bold, today earned 14pt medium #34C759
- Section label: "今日打卡" 13pt #8E8E93
- Meal rows: white bg, cornerRadius 12, each row height 60, padding horizontal 16, gap 14
  - Icon: 24x24 (早餐 sunrise=sunrise #FF9500, 午餐 sun=sun.max #FF9500, 晚餐 moon=moon.stars #AF52DE)
  - Name: 17pt #1C1C1E + partner status 13pt below
  - Right: "打卡" button (60x32, cornerRadius 8, #FF9500) or checkmark circle 28pt #34C759
- Dividers: #C6C6C820 (very light), full width within card

**Differences from current code:**
- Current uses `Divider().padding(.leading, 54)` → design shows full-width dividers with very light color
- Current divider color is default → should be #C6C6C820
- Everything else matches well

- [ ] **Step 1: Update divider style in meal list**

```swift
// Replace Divider().padding(.leading, 54) with:
// Rectangle().fill(Color(hex: "C6C6C8").opacity(0.125)).frame(height: 0.5)
```

- [ ] **Step 2: Build and verify**

- [ ] **Step 3: Commit**

---

### Task 4: RewardListView — Match Rewards Screen Design

**Files:**
- Modify: `對味/對味/Views/Rewards/RewardListView.swift`

**Design spec (Pencil frame: ljWg7 "4. Rewards"):**
- Large title "獎勵" with + button (30x30 orange circle with white plus icon)
- Balance card: white fill, cornerRadius 12, padding 20
  - Left: "可用點數" 13pt #8E8E93, points "320" 34pt bold tracking -1
  - Right: star icon 36pt #FF9500
- Available section: "可兌換" 13pt #8E8E93 label
  - White card, cornerRadius 12
  - Rows: height 52, padding horizontal 16, gap 12
  - Row: title 17pt + Spacer + "50 點" 15pt + 兌換 button (52x28, cornerRadius 7)
  - Dividers between rows with left padding 16
- Redeemed section: "已兌換" 13pt #8E8E93 label
  - Row: height 44, strikethrough text + points + checkmark

**Differences from current code:**
- Plus button style: current uses `plus.circle.fill` SF Symbol → design uses custom 30x30 orange circle. Current is fine for iOS native feel.
- Star icon: current uses `star` → could use `star.fill` for more visual impact
- Everything else matches well

- [ ] **Step 1: Update star icon to star.fill**

```swift
// Change Image(systemName: "star") to Image(systemName: "star.fill")
```

- [ ] **Step 2: Build and verify**

- [ ] **Step 3: Commit**

---

### Task 5: FoodMapView + MapFilterView — Match Map Screen Design

**Files:**
- Modify: `對味/對味/Views/Map/FoodMapView.swift`
- Modify: `對味/對味/Views/Map/MapFilterView.swift`

**Design spec (Pencil frame: H0Mma "5. Food Map"):**
- Full map background, no navigation title (inline hidden)
- Floating controls at top with padding [8,16]:
  - City segmented control: custom styled with rounded corners (9), height 36, fill #E5E5EA80
    - Active segment: white fill with shadow, 13pt semibold #1C1C1E
    - Inactive: no fill, 13pt medium #8E8E93
  - Filter chips: gap 6, each chip has colored dot (8px) + text 12pt, cornerRadius 14, height 28
    - Chip bg: #FFFFFFDD (white with opacity), shadow
    - No "selected fills with rating color" state in default view — just white chips with dots

**Differences from current code:**
- Navigation title: current has "美食地圖" inline → design has no nav title visible
- Segmented picker: current uses `.pickerStyle(.segmented)` → design shows custom styled. Standard iOS segmented control is close enough.
- Filter chips: current MapFilterView matches design well (colored dots + text + white bg)
- Map controls padding: current `.padding(.top, 8)` → design has padding [8,16]

- [ ] **Step 1: Hide navigation title and adjust map controls padding**

```swift
// In FoodMapView:
// 1. Remove .navigationTitle("美食地圖") or set .navigationBarHidden(true)
// 2. Update controls padding to match design
```

- [ ] **Step 2: Update MapFilterView chip height**

```swift
// Ensure chips have explicit height 28 and cornerRadius 14
```

- [ ] **Step 3: Build and verify**

- [ ] **Step 4: Commit**

---

### Task 6: Final Build + Full Visual Verification

**Files:** None (verification only)

- [ ] **Step 1: Clean build**

Run: Xcode Cmd+Shift+K (clean) then Cmd+B

- [ ] **Step 2: Run on simulator**

Run: Cmd+R, test all 5 screens:
1. Welcome/Login screen — bottom-aligned, 280px hero
2. Timeline — filter chips, meal cards
3. Check-In — ring card, meal rows
4. Rewards — balance card, reward list
5. Map — floating controls, pins

- [ ] **Step 3: Compare each screen with Pencil design screenshots**

Use `get_screenshot` on each Pencil frame and visually compare

- [ ] **Step 4: Final commit**
