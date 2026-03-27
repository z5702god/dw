import SwiftUI

struct RatingBadge: View {
    let rating: MealRating

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: rating.icon)
                .font(.system(size: 10))
            Text(rating.displayName)
                .font(.system(size: 11, weight: .semibold))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(badgeColor.opacity(0.1))
        .foregroundStyle(badgeColor)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private var badgeColor: Color {
        switch rating {
        case .recommended: return .ratingRecommended
        case .ok: return .ratingOk
        case .bad: return .ratingBad
        }
    }
}

#Preview {
    HStack {
        RatingBadge(rating: .recommended)
        RatingBadge(rating: .ok)
        RatingBadge(rating: .bad)
    }
}
