import SwiftUI
import Kingfisher

struct MealCardView: View {
    let meal: Meal

    var body: some View {
        HStack(spacing: 12) {
            // Photo thumbnail (Apple Music list size)
            if let firstPhoto = meal.photoURLs.first, let url = URL(string: firstPhoto) {
                KFImage(url)
                    .placeholder { ProgressView() }
                    .fade(duration: 0.2)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.tertiarySystemFill))
                    .frame(width: 60, height: 60)
                    .overlay {
                        Image(systemName: "fork.knife")
                            .foregroundStyle(.tertiary)
                    }
            }

            // Info
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(meal.displayTitle)
                        .font(.headline)
                        .lineLimit(1)

                    Spacer()

                    RatingBadge(rating: meal.rating)
                }

                Text(meal.review)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                HStack(spacing: 4) {
                    Image(systemName: meal.mealSlot.icon)
                    Text(meal.mealSlot.displayName)
                    if let city = meal.city {
                        Text("·")
                        Text(city.displayName)
                    }
                }
                .font(.caption)
                .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}
