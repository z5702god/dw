import SwiftUI
import Kingfisher

struct MealCardView: View {
    let meal: Meal

    var body: some View {
        HStack(spacing: 14) {
            // Photo thumbnail
            if let firstPhoto = meal.photoURLs.first, let url = URL(string: firstPhoto) {
                KFImage(url)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: "E5E5EA"))
                    .frame(width: 72, height: 72)
                    .overlay {
                        Image(systemName: "fork.knife")
                            .foregroundStyle(.appTextTertiary)
                    }
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                // Title + badge row
                HStack {
                    Text(meal.restaurantName)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.appTextPrimary)
                        .lineLimit(1)

                    Spacer()

                    RatingBadge(rating: meal.rating)
                }

                // Review text
                Text(meal.review)
                    .font(.system(size: 14))
                    .foregroundStyle(.appTextSecondary)
                    .lineLimit(2)
                    .lineSpacing(2)

                // Meta: city · date · user
                HStack(spacing: 6) {
                    Text("\(meal.city.displayName) · \(meal.createdAt?.formatted(.dateTime.month().day()) ?? "") · Luke")
                        .font(.system(size: 12))
                        .foregroundStyle(.appTextTertiary)
                }
            }
        }
        .padding(12)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
