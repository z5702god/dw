import SwiftUI

struct AchievementUnlockView: View {
    let achievement: Achievement
    let onDismiss: () -> Void

    @State private var appeared = false
    @State private var showConfetti = false
    @State private var glowPulse = false

    private var confettiCount: Int {
        switch achievement.tier {
        case .bronze: return 8
        case .silver: return 14
        case .gold: return 20
        case .diamond: return 30
        }
    }

    private var animationDuration: Double {
        switch achievement.tier {
        case .bronze: return 1.5
        case .silver: return 2.0
        case .gold: return 2.5
        case .diamond: return 3.5
        }
    }

    private var confettiColors: [Color] {
        switch achievement.tier {
        case .bronze:
            return [achievement.tier.color, .orange, .brown]
        case .silver:
            return [achievement.tier.color, .white, .blue.opacity(0.5)]
        case .gold:
            return [achievement.tier.color, .orange, .yellow, .red]
        case .diamond:
            return [.purple, .blue, .pink, .cyan, .indigo, .mint]
        }
    }

    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            // Confetti layer
            if showConfetti {
                ForEach(0..<confettiCount, id: \.self) { index in
                    ConfettiParticle(
                        color: confettiColors[index % confettiColors.count],
                        index: index
                    )
                }
            }

            VStack(spacing: 20) {
                Spacer()

                // Achievement icon with glow
                ZStack {
                    // Glow rings (intensity by tier)
                    if achievement.tier >= .silver {
                        Circle()
                            .fill(achievement.tier.glowColor)
                            .frame(width: 160, height: 160)
                            .scaleEffect(glowPulse ? 1.4 : 0.8)
                            .opacity(glowPulse ? 0 : 0.5)
                    }

                    if achievement.tier >= .gold {
                        Circle()
                            .fill(achievement.tier.glowColor)
                            .frame(width: 130, height: 130)
                            .scaleEffect(glowPulse ? 1.2 : 0.9)
                            .opacity(glowPulse ? 0.2 : 0.4)
                    }

                    Circle()
                        .fill(achievement.tier.color.opacity(0.2))
                        .frame(width: 100, height: 100)

                    Image(systemName: achievement.icon)
                        .font(.system(size: 50))
                        .foregroundStyle(achievement.tier.color)
                        .scaleEffect(appeared ? 1.0 : 0.1)
                        .shadow(color: achievement.tier.glowColor, radius: glowPulse ? 25 : 10)
                }

                // Achievement title
                Text(achievement.title)
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                    .scaleEffect(appeared ? 1.0 : 0.5)
                    .opacity(appeared ? 1 : 0)

                // Description
                Text(achievement.description)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 10)

                // Tier + points
                HStack(spacing: 12) {
                    Text(achievement.tier.displayName)
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(achievement.tier.color.opacity(0.3))
                        .foregroundStyle(achievement.tier.color)
                        .clipShape(Capsule())

                    Text("+\(achievement.tier.pointsReward) 點")
                        .font(.subheadline.bold())
                        .foregroundStyle(.appPrimary)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 15)

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                appeared = true
            }
            withAnimation(.easeOut(duration: 0.3).delay(0.2)) {
                showConfetti = true
            }
            if achievement.tier >= .silver {
                withAnimation(
                    .easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true)
                ) {
                    glowPulse = true
                }
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(animationDuration))
            onDismiss()
        }
        .sensoryFeedback(sensoryFeedbackForTier, trigger: appeared)
    }

    private var sensoryFeedbackForTier: SensoryFeedback {
        switch achievement.tier {
        case .bronze: return .impact(weight: .light)
        case .silver: return .impact(weight: .medium)
        case .gold, .diamond: return .success
        }
    }
}

// MARK: - Achievement Unlock Queue Manager

@MainActor
@Observable
final class AchievementUnlockQueue {
    var currentAchievement: Achievement?
    private var queue: [Achievement] = []

    var isShowing: Bool {
        currentAchievement != nil
    }

    func enqueue(_ achievements: [Achievement]) {
        queue.append(contentsOf: achievements)
        showNextIfNeeded()
    }

    func dismissCurrent() {
        currentAchievement = nil
        // 稍等一下再顯示下一個
        Task {
            try? await Task.sleep(for: .milliseconds(300))
            showNextIfNeeded()
        }
    }

    private func showNextIfNeeded() {
        guard currentAchievement == nil, !queue.isEmpty else { return }
        currentAchievement = queue.removeFirst()
    }
}
