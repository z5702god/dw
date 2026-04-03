import SwiftUI

struct AchievementWallView: View {
    @State private var viewModel = AchievementViewModel()
    @State private var selectedAchievement: Achievement?

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 進度環
                progressHeader

                // 按分類顯示
                ForEach(AchievementCategory.allCases, id: \.self) { category in
                    categorySection(category)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("成就")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // 每次進入成就牆時檢查並解鎖符合條件的成就
            await viewModel.checkAndUnlockAll()
        }
        .sheet(item: $selectedAchievement) { achievement in
            AchievementDetailSheet(
                achievement: achievement,
                isUnlocked: viewModel.isUnlocked(achievement),
                unlockedDate: viewModel.unlockedDate(for: achievement),
                progress: viewModel.progressValue(for: achievement)
            )
            .presentationDetents([.medium])
        }
    }

    // MARK: - Progress Header

    private var progressHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 8)
                    .frame(width: 80, height: 80)

                Circle()
                    .trim(from: 0, to: viewModel.progress)
                    .stroke(
                        LinearGradient(
                            colors: [.appPrimary, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(duration: 0.8), value: viewModel.progress)

                VStack(spacing: 0) {
                    Text("\(viewModel.unlockedCount)")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                    Text("/\(viewModel.totalCount)")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }

            Text("已解鎖成就")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Category Section

    private func categorySection(_ category: AchievementCategory) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .foregroundStyle(.appPrimary)
                Text(category.displayName)
                    .font(.headline)
            }

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.achievementsByCategory(category)) { achievement in
                    AchievementCardView(
                        achievement: achievement,
                        isUnlocked: viewModel.isUnlocked(achievement),
                        progress: viewModel.progressValue(for: achievement)
                    )
                    .onTapGesture {
                        selectedAchievement = achievement
                    }
                }
            }
        }
    }
}

// MARK: - Detail Sheet

struct AchievementDetailSheet: View {
    let achievement: Achievement
    let isUnlocked: Bool
    let unlockedDate: Date?
    let progress: (current: Int, target: Int)?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Icon
                ZStack {
                    if isUnlocked {
                        Circle()
                            .fill(achievement.tier.glowColor)
                            .frame(width: 120, height: 120)
                            .blur(radius: 20)
                    }

                    Image(systemName: achievement.icon)
                        .font(.system(size: 50))
                        .foregroundStyle(isUnlocked ? achievement.tier.color : .gray)
                        .frame(width: 90, height: 90)
                        .background(
                            Circle()
                                .fill(isUnlocked
                                    ? achievement.tier.color.opacity(0.15)
                                    : Color(.systemGray5))
                        )
                }

                // Title & Description
                VStack(spacing: 6) {
                    Text(achievement.title)
                        .font(.title2.bold())

                    Text(achievement.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    // Tier badge
                    Text(achievement.tier.displayName)
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(achievement.tier.color.opacity(0.2))
                        .foregroundStyle(achievement.tier.color)
                        .clipShape(Capsule())
                }

                if isUnlocked {
                    // Unlocked info
                    VStack(spacing: 4) {
                        if let date = unlockedDate {
                            Text("解鎖於 \(date.formatted(.dateTime.year().month().day()))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Text("+\(achievement.tier.pointsReward) 點")
                            .font(.subheadline.bold())
                            .foregroundStyle(.appPrimary)
                    }
                } else if let progress {
                    // Progress
                    VStack(spacing: 8) {
                        ProgressView(value: Double(progress.current), total: Double(progress.target))
                            .tint(.appPrimary)

                        Text("\(progress.current) / \(progress.target)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 40)
                }

                Spacer()
            }
            .padding(.top, 32)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AchievementWallView()
    }
}
