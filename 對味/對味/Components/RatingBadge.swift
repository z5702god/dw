import SwiftUI

struct RatingBadge: View {
    let rating: MealRating

    var body: some View {
        Text(rating.displayName)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(badgeBackground)
            .foregroundStyle(badgeColor)
            .clipShape(Capsule())
            .accessibilityLabel(rating.displayName)
    }

    private var badgeBackground: Color {
        switch rating {
        case .recommended: return Color(.systemGreen).opacity(0.12)
        case .ok: return Color(.systemOrange).opacity(0.12)
        case .bad: return Color(.systemRed).opacity(0.12)
        }
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
