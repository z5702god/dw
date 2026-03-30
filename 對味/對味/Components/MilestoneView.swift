import SwiftUI

struct MilestoneView: View {
    let mealCount: Int
    let onDismiss: () -> Void

    @State private var appeared = false
    @State private var emojiOffsets: [CGFloat] = (0..<12).map { _ in CGFloat.random(in: -180...180) }
    @State private var emojiPhases: [CGFloat] = (0..<12).map { _ in CGFloat.random(in: 0...1) }

    private let emojis = ["🍜", "🍣", "🥘", "🍕", "❤️", "🎉", "✨", "🍰", "🥂", "💕", "🎊", "🍳"]

    var milestoneMessage: String {
        switch mealCount {
        case 1: return "你們的第一餐！"
        case 10: return "一起吃了 10 餐！"
        case 50: return "50 餐的美味旅程！"
        case 100: return "100 餐！太厲害了！"
        default: return "第 \(mealCount) 餐"
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.black.opacity(appeared ? 0.6 : 0)
                    .ignoresSafeArea()
                    .onTapGesture { onDismiss() }

                // Floating emojis
                ForEach(0..<emojis.count, id: \.self) { index in
                    Text(emojis[index])
                        .font(.system(size: 28))
                        .offset(
                            x: emojiOffsets[index],
                            y: appeared ? -geometry.size.height * emojiPhases[index] : 400
                        )
                        .opacity(appeared ? 0.8 : 0)
                        .animation(
                            .easeOut(duration: 2.5).delay(Double(index) * 0.1),
                            value: appeared
                        )
                }

                // Center card
                VStack(spacing: 16) {
                    Text("\(mealCount)")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundStyle(.appPrimary)

                    Text(milestoneMessage)
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)

                    Text("繼續記錄你們的美味時光")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(40)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.regularMaterial)
                        .shadow(radius: 20)
                )
                .scaleEffect(appeared ? 1.0 : 0.5)
                .opacity(appeared ? 1.0 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: appeared)
            }
        }
        .sensoryFeedback(.success, trigger: appeared)
        .onAppear {
            appeared = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                onDismiss()
            }
        }
    }
}
