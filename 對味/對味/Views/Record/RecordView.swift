import SwiftUI

struct RecordView: View {
    @State private var showingMealForm = false
    @State private var showMilestone = false
    @State private var milestoneCount = 0
    @State private var lastKnownMealCount = 0

    private let mealRepo = MealRepository.shared
    private let authRepo = AuthRepository.shared

    private static let milestoneThresholds: Set<Int> = [1, 10, 50, 100]

    // MARK: - Computed Properties

    private var currentUserId: String? {
        authRepo.currentUserId
    }

    /// Current user's meals recorded today
    private var myTodayMeals: [Meal] {
        let calendar = Calendar.current
        return mealRepo.meals.filter { meal in
            meal.userId == currentUserId &&
            calendar.isDateInToday(meal.createdAt ?? .distantPast)
        }
    }

    /// Partner's meals recorded today
    private var partnerTodayMeals: [Meal] {
        let calendar = Calendar.current
        return mealRepo.meals.filter { meal in
            meal.userId != currentUserId &&
            calendar.isDateInToday(meal.createdAt ?? .distantPast)
        }
    }

    /// Dinner meal recorded today (if any)
    private var myDinnerToday: Meal? {
        myTodayMeals.first { $0.mealSlot == .dinner }
    }

    /// Whether it's before 8pm
    private var isBefore8PM: Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour < 20
    }

    /// Minutes remaining until 8pm
    private var minutesUntil8PM: Int {
        let calendar = Calendar.current
        let now = Date()
        guard let tonight8PM = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: now) else {
            return 0
        }
        let diff = calendar.dateComponents([.minute], from: now, to: tonight8PM)
        return max(0, diff.minute ?? 0)
    }

    // MARK: - Greeting

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let name = authRepo.appUser?.displayName ?? ""
        switch hour {
        case 5..<12: return "早安 \(name) ☀️"
        case 12..<18: return "午安 \(name) 🌤️"
        default: return "晚安 \(name) 🌙"
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            List {
                // MARK: Section 1 — Partner status
                Section {
                    Text(greeting)
                        .font(.title2.bold())

                    HStack(spacing: 8) {
                        Image(systemName: "person.2.fill")
                            .foregroundStyle(.appPrimary)
                        Text("\(authRepo.partnerName) 今天記錄了 \(partnerTodayMeals.count) 筆")
                            .font(.subheadline)
                    }
                }

                // MARK: Section 2 — Today's records
                Section("今天的紀錄") {
                    if myTodayMeals.isEmpty {
                        VStack(spacing: 8) {
                            Image("CookingIllustration")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 140)
                            Text("今天想吃什麼？")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    } else {
                        ForEach(myTodayMeals) { meal in
                            MealCardView(meal: meal)
                        }
                    }
                }

                // MARK: Section 3 — Points display + Dinner tracking (Kathy only)
                if authRepo.appUser?.isKathy == true {
                    Section("今日挑戰") {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("我的點數")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text("\(authRepo.appUser?.totalPoints ?? 0)")
                                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                                    .foregroundStyle(.appPrimary)
                            }
                            Spacer()
                        }
                    }

                    Section {
                        dinnerTrackingRow
                            .listRowBackground(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.systemOrange).opacity(0.06))
                                    .padding(.horizontal, 4)
                            )
                    }
                }

                // MARK: Section 4 — Monthly recap
                Section("本月回顧") {
                    MonthlyRecapView()
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
            }
            .listRowSeparatorTint(Color(.separator))
            .listStyle(.insetGrouped)
            .environment(\.defaultMinListRowHeight, 40)
            .navigationTitle("今日")
            .animation(.default, value: myTodayMeals.count)
            .animation(.default, value: partnerTodayMeals.count)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingMealForm = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .tint(.appPrimary)
                }
            }
            .sheet(isPresented: $showingMealForm) {
                MealFormView()
            }
            .sensoryFeedback(.success, trigger: showingMealForm)
            .onChange(of: mealRepo.meals.count) { oldCount, newCount in
                if newCount > oldCount && Self.milestoneThresholds.contains(newCount) {
                    milestoneCount = newCount
                    showMilestone = true
                }
            }
            .overlay {
                if showMilestone {
                    MilestoneView(mealCount: milestoneCount) {
                        withAnimation { showMilestone = false }
                    }
                    .transition(.opacity)
                }
            }
        }
    }

    // MARK: - Dinner Tracking Row

    @ViewBuilder
    private var dinnerTrackingRow: some View {
        if let dinner = myDinnerToday {
            let dinnerTime = dinner.createdAt ?? Date()
            let hour = Calendar.current.component(.hour, from: dinnerTime)
            if hour < 20 {
                Label {
                    Text("+1 點！晚餐準時記錄")
                        .foregroundStyle(.ratingRecommended)
                } icon: {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.ratingRecommended)
                }
            } else {
                Label("已記錄晚餐", systemImage: "checkmark.circle")
                    .foregroundStyle(.secondary)
            }
        } else {
            if isBefore8PM {
                let hours = minutesUntil8PM / 60
                let mins = minutesUntil8PM % 60
                let countdown = hours > 0 ? "還有 \(hours) 小時 \(mins) 分鐘" : "還有 \(mins) 分鐘"
                Label {
                    Text("8點前記錄可得 1 點（\(countdown)）")
                        .monospacedDigit()
                        .foregroundStyle(.ratingOk)
                } icon: {
                    Image(systemName: "clock.badge.exclamationmark")
                        .foregroundStyle(.ratingOk)
                }
            } else {
                Label("今天的晚餐時間過了～明天繼續加油！", systemImage: "clock")
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

#Preview {
    RecordView()
}
