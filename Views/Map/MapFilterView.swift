import SwiftUI

struct MapFilterView: View {
    @Binding var selectedRating: MealRating?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(MealRating.allCases, id: \.self) { rating in
                    Button {
                        if selectedRating == rating {
                            selectedRating = nil
                        } else {
                            selectedRating = rating
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(ratingColor(rating))
                                .frame(width: 8, height: 8)
                            Text(rating.displayName)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(selectedRating == rating ? .white : .appTextPrimary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            selectedRating == rating
                                ? AnyShapeStyle(ratingColor(rating))
                                : AnyShapeStyle(Color.white.opacity(0.9))
                        )
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func ratingColor(_ rating: MealRating) -> Color {
        switch rating {
        case .recommended: return .ratingRecommended
        case .ok: return .ratingOk
        case .bad: return .ratingBad
        }
    }
}
