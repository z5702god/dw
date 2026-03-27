import SwiftUI

struct RewardFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: RewardViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("獎勵內容") {
                    TextField("獎勵名稱（例：一次約會）", text: $viewModel.newRewardTitle)
                }

                Section("需要點數") {
                    Stepper(value: $viewModel.newRewardCost, in: 10...1000, step: 10) {
                        Text("\(viewModel.newRewardCost) 點")
                            .font(.headline)
                            .foregroundStyle(.orange)
                    }

                    // Quick presets
                    HStack(spacing: 8) {
                        ForEach([30, 50, 100, 200], id: \.self) { value in
                            Button("\(value)") {
                                viewModel.newRewardCost = value
                            }
                            .buttonStyle(.bordered)
                            .tint(viewModel.newRewardCost == value ? .orange : .gray)
                            .controlSize(.small)
                        }
                    }
                }
            }
            .navigationTitle("新增獎勵")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("新增") {
                        Task {
                            await viewModel.addReward()
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(viewModel.newRewardTitle.isEmpty)
                }
            }
        }
    }
}
