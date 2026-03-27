import SwiftUI

struct CheckInView: View {
    @State private var viewModel = CheckInViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Points Ring Card (Apple Health style)
                    HStack(spacing: 24) {
                        // Ring indicator
                        ZStack {
                            Circle()
                                .stroke(Color.appBackground, lineWidth: 10)
                                .frame(width: 100, height: 100)

                            Circle()
                                .trim(from: 0, to: min(CGFloat(viewModel.totalPoints) / 500.0, 1.0))
                                .stroke(.appPrimary, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                .frame(width: 100, height: 100)
                                .rotationEffect(.degrees(-90))

                            VStack(spacing: 0) {
                                Text("\(viewModel.totalPoints)")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundStyle(.appTextPrimary)
                                Text("點")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.appTextSecondary)
                            }
                        }

                        // Points info
                        VStack(alignment: .leading, spacing: 8) {
                            Text("總點數")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.appTextSecondary)

                            Text("\(viewModel.totalPoints) 點")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(.appTextPrimary)

                            if viewModel.todayPointsEarned() > 0 {
                                Text("今日已獲得 +\(viewModel.todayPointsEarned()) 點")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(.ratingRecommended)
                            }
                        }

                        Spacer()
                    }
                    .padding(24)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Section label
                    HStack {
                        Text("今日打卡")
                            .font(.system(size: 13))
                            .foregroundStyle(.appTextSecondary)
                        Spacer()
                    }

                    // Meal check-in list (iOS grouped list style)
                    VStack(spacing: 0) {
                        ForEach(Array(MealType.allCases.enumerated()), id: \.element) { index, mealType in
                            MealCheckInRow(
                                mealType: mealType,
                                isCheckedIn: viewModel.hasCheckedIn(mealType: mealType),
                                partnerCheckedIn: viewModel.partnerHasCheckedIn(mealType: mealType)
                            ) {
                                Task { await viewModel.checkIn(mealType: mealType) }
                            }

                            if index < MealType.allCases.count - 1 {
                                Divider()
                                    .padding(.leading, 54)
                            }
                        }
                    }
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .background(.appBackground)
            .navigationTitle("打卡")
            .alert("打卡成功！", isPresented: $viewModel.showResult) {
                Button("太好了！") {}
            } message: {
                if let result = viewModel.lastResult {
                    if result.onTime {
                        Text("準時吃飯！獲得 \(result.pointsEarned) 點")
                    } else {
                        Text("雖然遲了，但至少有吃！獲得 \(result.pointsEarned) 點")
                    }
                }
            }
        }
    }
}

// MARK: - Meal Check-In Row (iOS native list row style)
struct MealCheckInRow: View {
    let mealType: MealType
    let isCheckedIn: Bool
    let partnerCheckedIn: Bool
    let onCheckIn: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: mealType.icon)
                .font(.system(size: 20))
                .foregroundStyle(mealType == .dinner ? Color(hex: "AF52DE") : .appPrimary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 1) {
                Text(mealType.displayName)
                    .font(.system(size: 17))
                    .foregroundStyle(.appTextPrimary)
                Text(partnerCheckedIn ? "對方已打卡" : "對方尚未打卡")
                    .font(.system(size: 13))
                    .foregroundStyle(partnerCheckedIn ? .ratingRecommended : .appTextSecondary)
            }

            Spacer()

            if isCheckedIn {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.ratingRecommended)
            } else {
                Button(action: onCheckIn) {
                    Text("打卡")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 60, height: 32)
                        .background(.appPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 60)
    }
}

#Preview {
    CheckInView()
}
