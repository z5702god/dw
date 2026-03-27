import SwiftUI

struct UserAvatar: View {
    let name: String
    var size: CGFloat = 28

    var body: some View {
        Text(String(name.prefix(1)))
            .font(.system(size: size * 0.5, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(avatarColor)
            )
            .accessibilityLabel(name)
    }

    private var avatarColor: Color {
        // Simple deterministic color based on name
        let hash = abs(name.hashValue)
        let colors: [Color] = [.orange, .blue, .purple, .pink, .teal]
        return colors[hash % colors.count]
    }
}

#Preview {
    HStack {
        UserAvatar(name: "Luke")
        UserAvatar(name: "Amy")
    }
}
