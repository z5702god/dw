import SwiftUI

struct AchievementCardView: View {
    let achievement: Achievement
    let isUnlocked: Bool
    let progress: (current: Int, target: Int)?

    var body: some View {
        VStack(spacing: 8) {
            // Icon with tier glow
            ZStack {
                if isUnlocked {
                    Circle()
                        .fill(achievement.tier.glowColor)
                        .frame(width: 56, height: 56)
                        .blur(radius: 10)
                }

                Image(systemName: achievement.icon)
                    .font(.system(size: 24))
                    .foregroundStyle(isUnlocked ? achievement.tier.color : .gray.opacity(0.5))
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(isUnlocked
                                ? achievement.tier.color.opacity(0.15)
                                : Color(.systemGray5))
                    )
                    .overlay(
                        Circle()
                            .stroke(isUnlocked ? achievement.tier.color.opacity(0.6) : .clear, lineWidth: 2)
                    )
            }

            // Title
            Text(achievement.title)
                .font(.caption2.bold())
                .lineLimit(1)
                .foregroundStyle(isUnlocked ? .primary : .secondary)

            // Progress or tier
            if isUnlocked {
                Text(achievement.tier.displayName)
                    .font(.system(size: 9, weight: .semibold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(achievement.tier.color.opacity(0.2))
                    .foregroundStyle(achievement.tier.color)
                    .clipShape(Capsule())
            } else if let progress {
                Text("\(progress.current)/\(progress.target)")
                    .font(.system(size: 9))
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}
