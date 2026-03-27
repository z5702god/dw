import SwiftUI

struct RewardListView: View {
    @State private var viewModel = RewardViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Balance card
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("可用點數")
                                .font(.system(size: 13))
                                .foregroundStyle(.appTextSecondary)
                            Text("\(viewModel.totalPoints)")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundStyle(.appTextPrimary)
                                .tracking(-1)
                        }
                        Spacer()
                        Image(systemName: "star")
                            .font(.system(size: 36))
                            .foregroundStyle(.appPrimary)
                    }
                    .padding(20)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Available rewards section
                    VStack(alignment: .leading, spacing: 6) {
                        Text("可兌換")
                            .font(.system(size: 13))
                            .foregroundStyle(.appTextSecondary)

                        VStack(spacing: 0) {
                            ForEach(Array(viewModel.availableRewards.enumerated()), id: \.element.id) { index, reward in
                                RewardRow(
                                    reward: reward,
                                    canRedeem: viewModel.totalPoints >= reward.pointsCost,
                                    onRedeem: { Task { await viewModel.redeemReward(reward) } }
                                )

                                if index < viewModel.availableRewards.count - 1 {
                                    Divider()
                                        .padding(.leading, 16)
                                }
                            }
                        }
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Redeemed section
                    if !viewModel.redeemedRewards.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("已兌換")
                                .font(.system(size: 13))
                                .foregroundStyle(.appTextSecondary)

                            VStack(spacing: 0) {
                                ForEach(viewModel.redeemedRewards) { reward in
                                    HStack {
                                        Text(reward.title)
                                            .font(.system(size: 17))
                                            .foregroundStyle(.appTextTertiary)
                                        Spacer()
                                        Text("\(reward.pointsCost) 點")
                                            .font(.system(size: 15))
                                            .foregroundStyle(Color(hex: "D1D1D6"))
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14))
                                            .foregroundStyle(Color(hex: "D1D1D6"))
                                    }
                                    .padding(.horizontal, 16)
                                    .frame(height: 44)
                                }
                            }
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.ratingBad)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .background(.appBackground)
            .navigationTitle("獎勵")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showingAddReward = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(.appPrimary)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddReward) {
                RewardFormView(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Reward Row (iOS native list row)
struct RewardRow: View {
    let reward: Reward
    let canRedeem: Bool
    let onRedeem: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(reward.title)
                .font(.system(size: 17))
                .foregroundStyle(.appTextPrimary)

            Spacer()

            Text("\(reward.pointsCost) 點")
                .font(.system(size: 15))
                .foregroundStyle(.appTextSecondary)

            Button(action: onRedeem) {
                Text("兌換")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 28)
                    .background(canRedeem ? Color.appPrimary : Color(hex: "E5E5EA"))
                    .clipShape(RoundedRectangle(cornerRadius: 7))
            }
            .disabled(!canRedeem)
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
    }
}

#Preview {
    RewardListView()
}
