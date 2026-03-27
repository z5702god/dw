import SwiftUI

struct PointsBadge: View {
    let points: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.caption2)
            Text("\(points)")
                .font(.caption)
                .fontWeight(.semibold)
        }
        .foregroundStyle(.orange)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.orange.opacity(0.15))
        .clipShape(Capsule())
    }
}

#Preview {
    PointsBadge(points: 150)
}
