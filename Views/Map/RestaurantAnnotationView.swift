import SwiftUI

struct RestaurantAnnotationView: View {
    let rating: MealRating

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(annotationColor)
                    .frame(width: 40, height: 40)
                    .shadow(color: .black.opacity(0.15), radius: 4, y: 2)

                Image(systemName: "fork.knife")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
            }

            Triangle()
                .fill(annotationColor)
                .frame(width: 10, height: 6)
                .offset(y: -2)
        }
    }

    private var annotationColor: Color {
        switch rating {
        case .recommended: return .ratingRecommended
        case .ok: return .ratingOk
        case .bad: return .ratingBad
        }
    }
}

// Simple triangle shape
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

#Preview {
    HStack(spacing: 20) {
        RestaurantAnnotationView(rating: .recommended)
        RestaurantAnnotationView(rating: .ok)
        RestaurantAnnotationView(rating: .bad)
    }
}
