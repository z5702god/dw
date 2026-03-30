import SwiftUI

struct MonthlyRecapView: View {
    @State private var viewModel = RecapViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(.white.opacity(0.9))
                Text("\(viewModel.currentMonthName)回顧")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
            }

            if viewModel.totalMealsThisMonth > 0 {
                // Main stat
                Text("一起吃了 \(viewModel.totalMealsThisMonth) 餐")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)

                // Cities
                if viewModel.citiesVisited > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.caption)
                        Text("去了 \(viewModel.citiesVisited) 個城市")
                            .font(.subheadline)
                    }
                    .foregroundStyle(.white.opacity(0.85))
                }

                // Top meal
                if let topMeal = viewModel.topRatedMeal {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                        Text("最推薦：\(topMeal.displayTitle)")
                            .font(.subheadline)
                            .lineLimit(1)
                    }
                    .foregroundStyle(.white.opacity(0.85))
                }

                // Restaurant vs Home
                HStack(spacing: 4) {
                    Text("外食 \(viewModel.restaurantCount) 次")
                    Text("·")
                    Text("自煮 \(viewModel.homeCount) 次")
                }
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
            } else {
                Text("這個月還沒有紀錄")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.vertical, 8)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [.appPrimary, .appPrimary.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .onAppear {
            viewModel.generateRecap()
        }
    }
}
