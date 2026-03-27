import SwiftUI

struct CelebrationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var appeared = false
    @State private var showConfetti = false
    @State private var glowPulse = false

    // Confetti particles
    private let confettiColors: [Color] = [
        .appPrimary, .orange, .yellow, .pink, .mint, .red
    ]

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            // Confetti layer
            if showConfetti {
                ForEach(0..<20, id: \.self) { index in
                    ConfettiParticle(
                        color: confettiColors[index % confettiColors.count],
                        index: index
                    )
                }
            }

            VStack(spacing: 20) {
                Spacer()

                // Star icon with glow
                ZStack {
                    // Glow ring
                    Circle()
                        .fill(Color.appPrimary.opacity(0.15))
                        .frame(width: 140, height: 140)
                        .scaleEffect(glowPulse ? 1.3 : 0.8)
                        .opacity(glowPulse ? 0 : 0.6)

                    Circle()
                        .fill(Color.appPrimary.opacity(0.1))
                        .frame(width: 110, height: 110)
                        .scaleEffect(glowPulse ? 1.15 : 0.9)
                        .opacity(glowPulse ? 0.2 : 0.4)

                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.appPrimary)
                        .scaleEffect(appeared ? 1.0 : 0.3)
                        .shadow(color: .appPrimary.opacity(0.4), radius: glowPulse ? 20 : 8)
                }

                // +1 text with spring bounce
                Text("+1")
                    .font(.system(.largeTitle, design: .rounded, weight: .black))
                    .scaleEffect(appeared ? 1.0 : 0.1)
                    .foregroundStyle(.appPrimary)

                Text("晚餐準時記錄！")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 10)

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0)) {
                appeared = true
            }
            withAnimation(.easeOut(duration: 0.3).delay(0.2)) {
                showConfetti = true
            }
            withAnimation(
                .easeInOut(duration: 1.0)
                .repeatForever(autoreverses: true)
            ) {
                glowPulse = true
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(2.0))
            dismiss()
        }
        .sensoryFeedback(.success, trigger: appeared)
    }
}

// MARK: - Confetti Particle

struct ConfettiParticle: View {
    let color: Color
    let index: Int

    @State private var animate = false

    private var randomAngle: Double {
        Double(index) * 18.0 // Spread evenly around 360 degrees
    }

    private var randomDistance: CGFloat {
        CGFloat.random(in: 120...220)
    }

    private var randomSize: CGFloat {
        CGFloat.random(in: 5...10)
    }

    private var xOffset: CGFloat {
        animate ? cos(randomAngle * .pi / 180) * randomDistance : 0
    }

    private var yOffset: CGFloat {
        animate ? sin(randomAngle * .pi / 180) * randomDistance + 60 : 0
    }

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: randomSize, height: randomSize)
            .offset(x: xOffset, y: yOffset)
            .opacity(animate ? 0 : 1)
            .scaleEffect(animate ? 0.3 : 1.0)
            .onAppear {
                withAnimation(
                    .easeOut(duration: Double.random(in: 0.8...1.4))
                    .delay(Double.random(in: 0...0.15))
                ) {
                    animate = true
                }
            }
    }
}

#Preview {
    CelebrationView()
}
