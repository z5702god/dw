import SwiftUI
import Kingfisher

struct RestaurantAnnotationView: View {
    let meal: Meal

    var body: some View {
        VStack(spacing: 0) {
            // Card with photo thumbnail
            VStack(spacing: 0) {
                if let firstPhoto = meal.photoURLs.first, let url = URL(string: firstPhoto) {
                    KFImage(url)
                        .placeholder { ProgressView() }
                        .fade(duration: 0.2)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.tertiarySystemFill))
                        .frame(width: 44, height: 44)
                        .overlay {
                            Image(systemName: "fork.knife")
                                .font(.system(size: 16))
                                .foregroundStyle(.tertiary)
                        }
                }
            }
            .padding(3)
            .background(.appCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(ratingColor, lineWidth: 2.5)
            )
            .shadow(color: .black.opacity(0.15), radius: 4, y: 2)

            // Pointer triangle
            Triangle()
                .fill(ratingColor)
                .frame(width: 10, height: 6)
                .offset(y: -1)
        }
    }

    private var ratingColor: Color {
        switch meal.rating {
        case .recommended: return .ratingRecommended
        case .ok: return .ratingOk
        case .bad: return .ratingBad
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
