import SwiftUI
import Kingfisher

struct MealDetailView: View {
    let meal: Meal

    var body: some View {
        List {
            // Photos
            Section {
                if !meal.photoURLs.isEmpty {
                    TabView {
                        ForEach(meal.photoURLs, id: \.self) { urlString in
                            if let url = URL(string: urlString) {
                                KFImage(url)
                                    .placeholder { ProgressView() }
                                    .fade(duration: 0.2)
                                    .resizable()
                                    .scaledToFill()
                                    .clipped()
                            }
                        }
                    }
                    .tabViewStyle(.page)
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .transition(.opacity)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                } else {
                    // Photo placeholder
                    VStack(spacing: 12) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 36))
                            .foregroundStyle(.tertiary)
                        Text("還沒有照片")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }

            // Title + Rating + Metadata
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(meal.displayTitle)
                            .font(.title2)
                            .fontWeight(.bold)

                        Spacer()

                        RatingBadge(rating: meal.rating)
                    }

                    // Metadata row
                    HStack(spacing: 4) {
                        // Meal slot
                        Image(systemName: meal.mealSlot.icon)
                            .font(.caption)
                        Text(meal.mealSlot.displayName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        // City (only if present)
                        if let city = meal.city {
                            Text("·")
                                .foregroundStyle(.secondary)
                            Image(systemName: "mappin")
                                .font(.caption)
                            Text(city.displayName)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        // Date
                        if let date = meal.createdAt {
                            Text("·")
                                .foregroundStyle(.secondary)
                            Text(date.formatted(.dateTime.year().month().day()))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            // Review
            Section("心得") {
                Text(meal.review)
                    .font(.body)
                    .lineSpacing(4)
            }
        }
        .listRowSeparatorTint(Color(.separator))
        .listStyle(.insetGrouped)
        .navigationTitle("紀錄詳情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(
                    item: "\(meal.displayTitle) \(meal.rating.displayName)\n\(meal.review)\n\n— 來自對味 app",
                    subject: Text(meal.displayTitle),
                    message: Text(meal.review)
                )
            }
        }
    }
}
