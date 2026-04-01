import SwiftUI
import Kingfisher

struct LandmineView: View {
    private let mealRepo = MealRepository.shared
    private let authRepo = AuthRepository.shared

    private var landmines: [Meal] {
        mealRepo.meals
            .filter { $0.rating == .bad }
            .sorted { ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if landmines.isEmpty {
                    VStack(spacing: 16) {
                        Text("🍀")
                            .font(.system(size: 60))
                        Text("還沒有踩雷，太幸運了！")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(Array(landmines.enumerated()), id: \.element.id) { index, meal in
                            NavigationLink(destination: MealDetailView(meal: meal)) {
                                LandmineRow(rank: index + 1, meal: meal)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("地雷排行榜 💣")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - 地雷列

private struct LandmineRow: View {
    let rank: Int
    let meal: Meal
    private let authRepo = AuthRepository.shared

    private var recorderName: String {
        meal.userId == authRepo.currentUserId
            ? "我"
            : authRepo.partnerName
    }

    var body: some View {
        HStack(spacing: 12) {
            // 排名
            Text("💣")
                .font(.title3)
                .overlay(alignment: .topTrailing) {
                    Text("\(rank)")
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                        .frame(width: 18, height: 18)
                        .background(Color.red)
                        .clipShape(Circle())
                        .offset(x: 6, y: -4)
                }
                .frame(width: 36)

            // 照片
            if let firstURL = meal.photoURLs.first, let url = URL(string: firstURL) {
                KFImage(url)
                    .placeholder { Color(.tertiarySystemFill) }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.tertiarySystemFill))
                    .frame(width: 50, height: 50)
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(.tertiary)
                    }
            }

            // 資訊
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.displayTitle)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)

                Text(meal.review)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text(recorderName)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    if let date = meal.createdAt {
                        Text("·")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                        Text(date.formatted(.dateTime.month().day()))
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    LandmineView()
}
