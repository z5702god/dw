import SwiftUI

struct RewardListView: View {
    @State private var viewModel = RewardViewModel()
    @State private var rewardRepo = RewardRepository.shared
    @State private var rewardToRedeem: Reward?
    @State private var showRedeemConfirm = false
    @State private var rewardToComplete: Reward?
    @State private var showCompleteConfirm = false
    @State private var redeemTrigger = false

    var body: some View {
        NavigationStack {
            List {
                if viewModel.isKathy {
                    kathySections
                } else {
                    lukeSections
                }

                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.ratingBad)
                    }
                }
            }
            .listRowSeparatorTint(Color(.separator))
            .listStyle(.insetGrouped)
            .animation(.default, value: rewardRepo.availableRewards.count)
            .animation(.default, value: rewardRepo.redeemedRewards.count)
            .animation(.default, value: rewardRepo.completedRewards.count)
            .navigationTitle(viewModel.isKathy ? "獎勵" : "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if viewModel.isLuke {
                    ToolbarItem(placement: .principal) {
                        Text("俐瑤的獎勵")
                            .font(.headline)
                    }
                }
                if viewModel.isKathy {
                    ToolbarItem(placement: .principal) {
                        Text("獎勵")
                            .font(.headline)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        AchievementWallView()
                    } label: {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(.appPrimary)
                    }
                }
            }
            .task { await viewModel.seedDefaultRewardsIfNeeded() }
            .onChange(of: rewardRepo.redeemedRewards.count) {
                viewModel.checkForNewRedemptions()
            }
            // MARK: - Alerts
            .alert("俐瑤兌換了獎勵！", isPresented: $viewModel.showRedemptionAlert) {
                Button("好的") {
                    viewModel.showRedemptionAlert = false
                }
            } message: {
                if let reward = viewModel.newlyRedeemedReward {
                    Text(reward.title)
                }
            }
            .alert("想兌換這個獎勵嗎？", isPresented: $showRedeemConfirm) {
                Button("取消", role: .cancel) {
                    rewardToRedeem = nil
                }
                Button("兌換") {
                    if let reward = rewardToRedeem {
                        Task {
                            await viewModel.redeemReward(reward)
                            redeemTrigger.toggle()
                        }
                    }
                    rewardToRedeem = nil
                }
            } message: {
                if let reward = rewardToRedeem {
                    Text("確定兌換「\(reward.title)」？將扣除 \(reward.pointsCost) 點")
                }
            }
            .alert("獎勵已經兌現了嗎？", isPresented: $showCompleteConfirm) {
                Button("取消", role: .cancel) {
                    rewardToComplete = nil
                }
                Button("完成") {
                    if let reward = rewardToComplete {
                        Task { await viewModel.completeReward(reward) }
                    }
                    rewardToComplete = nil
                }
            } message: {
                if let reward = rewardToComplete {
                    Text("確定已完成「\(reward.title)」？")
                }
            }
            .sensoryFeedback(.impact(weight: .light), trigger: showRedeemConfirm)
            .sensoryFeedback(.success, trigger: redeemTrigger)
        }
    }

    // MARK: - Kathy Sections

    @ViewBuilder
    private var kathySections: some View {
        // Points summary
        Section {
            VStack(spacing: 12) {
                HStack {
                    Image("StarMascot")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Text("我的愛心點數")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("\(viewModel.totalPoints)")
                            .font(.system(.largeTitle, design: .rounded, weight: .bold))
                            .foregroundStyle(.appPrimary)
                        + Text(" 點")
                            .font(.system(.body, design: .rounded, weight: .medium))
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
            }
        }

        // Available rewards
        Section {
            if rewardRepo.availableRewards.isEmpty {
                Text("載入中...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(rewardRepo.availableRewards) { reward in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 10) {
                            Image(systemName: viewModel.rewardIcon(for: reward.title))
                                .font(.title2)
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.appPrimary)
                                .frame(width: 40, height: 40)
                                .background(Color(.tertiarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 10))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(rewardMainTitle(reward.title))
                                    .font(.body.weight(.medium))
                                    .lineLimit(1)
                                if let sub = rewardSubtitle(reward.title) {
                                    Text(sub)
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                                Text("\(reward.pointsCost) 點")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Button("兌換") {
                                rewardToRedeem = reward
                                showRedeemConfirm = true
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.appPrimary)
                            .controlSize(.small)
                            .disabled(viewModel.totalPoints < reward.pointsCost)
                        }
                    }
                }
            }
        } header: {
            Text("想要什麼獎勵？")
        }

        // Pending rewards
        if !rewardRepo.redeemedRewards.isEmpty {
            Section {
                ForEach(rewardRepo.redeemedRewards) { reward in
                    HStack(spacing: 10) {
                        Image(systemName: viewModel.rewardIcon(for: reward.title))
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.appPrimary)
                            .frame(width: 40, height: 40)
                            .background(Color(.tertiarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                        Text(reward.title)
                            .font(.body)
                            .lineLimit(2)

                        Spacer()

                        HStack(spacing: 3) {
                            Text("已送出願望")
                            Image(systemName: "sparkles")
                                .foregroundStyle(.appPrimary)
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
            } header: {
                HStack(spacing: 4) {
                    Text("已許願")
                    Image(systemName: "sparkles")
                        .foregroundStyle(.appPrimary)
                }
            }
        }

        // Completed rewards
        if !rewardRepo.completedRewards.isEmpty {
            completedSection
        }
    }

    // MARK: - Luke Sections

    @ViewBuilder
    private var lukeSections: some View {
        // Pending section — Luke can complete these
        if !rewardRepo.redeemedRewards.isEmpty {
            Section("待兌現") {
                ForEach(rewardRepo.redeemedRewards) { reward in
                    HStack(spacing: 12) {
                        Text(viewModel.rewardEmoji(for: reward.title))
                            .font(.title2)
                            .frame(width: 36, height: 36)
                            .background(Color(.tertiarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(reward.title)
                                .font(.body)
                            Text("\(reward.pointsCost) 點")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Button("完成") {
                            rewardToComplete = reward
                            showCompleteConfirm = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.appPrimary)
                        .controlSize(.small)
                    }
                }
            }
        }

        // Completed section
        if !rewardRepo.completedRewards.isEmpty {
            completedSection
        }

        // Empty state for Luke
        if rewardRepo.redeemedRewards.isEmpty && rewardRepo.completedRewards.isEmpty {
            Section {
                VStack(spacing: 8) {
                    Image("GiftIllustration")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 140)
                    Text("還沒有等待兌現的獎勵呢")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            }
        }
    }

    // MARK: - Shared Completed Section

    @ViewBuilder
    private var completedSection: some View {
        Section("已完成") {
            ForEach(rewardRepo.completedRewards) { reward in
                HStack(spacing: 12) {
                    Image(systemName: viewModel.rewardIcon(for: reward.title))
                        .font(.title2)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.appPrimary)
                        .frame(width: 36, height: 36)
                        .background(Color(.tertiarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .opacity(0.5)

                    Text(reward.title)
                        .font(.body)
                        .foregroundStyle(.tertiary)

                    Spacer()

                    if let completedAt = reward.completedAt {
                        Text(completedAt.formatted(.dateTime.month().day()))
                            .font(.footnote)
                            .foregroundStyle(.tertiary)
                    }

                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }

    // MARK: - Title Parsing

    /// 「排隊美食（Luke 去排，再遠都要）」→ 主標題「排隊美食」
    private func rewardMainTitle(_ title: String) -> String {
        if let range = title.range(of: "（") ?? title.range(of: "(") {
            return String(title[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
        }
        return title
    }

    /// 「排隊美食（Luke 去排，再遠都要）」→ 副標題「Luke 去排，再遠都要」
    private func rewardSubtitle(_ title: String) -> String? {
        let openParen: Character = title.contains("（") ? "（" : "("
        let closeParen: Character = title.contains("）") ? "）" : ")"
        guard let start = title.firstIndex(of: openParen),
              let end = title.firstIndex(of: closeParen) else { return nil }
        let sub = String(title[title.index(after: start)..<end]).trimmingCharacters(in: .whitespaces)
        return sub.isEmpty ? nil : sub
    }
}

#Preview {
    RewardListView()
}
