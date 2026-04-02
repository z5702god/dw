import SwiftUI
import Kingfisher

struct TasteTimelineView: View {
    private let mealRepo = MealRepository.shared

    private var timelineEvents: [Meal] {
        mealRepo.meals
            .filter { $0.isTimelineEvent == true }
            .sorted { ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if timelineEvents.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 50))
                            .foregroundStyle(.appPrimary)
                            .symbolEffect(.pulse)
                        Text("還沒有特別的味道記憶")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text("在餐點詳情頁加入時間軸吧")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(timelineEvents.enumerated()), id: \.element.id) { index, meal in
                                TimelineNodeView(
                                    meal: meal,
                                    isFirst: index == 0,
                                    isLast: index == timelineEvents.count - 1
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                }
            }
            .navigationTitle("味道時間軸")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - 時間軸節點

private struct TimelineNodeView: View {
    let meal: Meal
    let isFirst: Bool
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // 左側時間軸線 + 圓點
            VStack(spacing: 0) {
                // 上半連接線
                Rectangle()
                    .fill(isFirst ? Color.clear : Color.appPrimary.opacity(0.3))
                    .frame(width: 2, height: 20)

                // 圓點 + SF Symbol
                ZStack {
                    Circle()
                        .fill(Color.appPrimary.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: meal.timelineTag?.icon ?? "star.fill")
                        .font(.body)
                        .foregroundStyle(.appPrimary)
                        .symbolRenderingMode(.hierarchical)
                }

                // 下半連接線
                Rectangle()
                    .fill(isLast ? Color.clear : Color.appPrimary.opacity(0.3))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }
            .frame(width: 36)

            // 右側卡片
            VStack(alignment: .leading, spacing: 8) {
                // 日期
                if let date = meal.createdAt {
                    Text(date.formatted(.dateTime.year().month().day()))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // 卡片
                HStack(spacing: 10) {
                    // 縮圖
                    if let firstURL = meal.photoURLs.first, let url = URL(string: firstURL) {
                        KFImage(url)
                            .placeholder { Color(.tertiarySystemFill) }
                            .resizable()
                            .scaledToFill()
                            .frame(width: 56, height: 56)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(meal.displayTitle)
                            .font(.subheadline.weight(.semibold))
                            .lineLimit(1)

                        if let tag = meal.timelineTag {
                            HStack(spacing: 3) {
                                Image(systemName: tag.icon)
                                    .font(.caption2)
                                Text(tag.displayName)
                            }
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.appPrimary.opacity(0.12))
                            .foregroundStyle(.appPrimary)
                            .clipShape(Capsule())
                        }
                    }

                    Spacer()
                }
                .padding(12)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.bottom, 12)
        }
    }
}

#Preview {
    TasteTimelineView()
}
