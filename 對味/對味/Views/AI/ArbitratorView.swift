import SwiftUI

struct ArbitratorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var userAWant = ""
    @State private var userBWant = ""
    @State private var verdict: String?

    private let aiService = AIService.shared
    private let authRepo = AuthRepository.shared

    private var userName: String {
        authRepo.appUser?.displayName ?? "我"
    }

    private var partnerName: String {
        authRepo.partnerName
    }

    private var canSubmit: Bool {
        !userAWant.isEmpty && !userBWant.isEmpty && !aiService.isLoading
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 標題
                    VStack(spacing: 8) {
                        Image(systemName: "scalemass.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.appPrimary)
                            .symbolRenderingMode(.hierarchical)
                        Text("美食法庭")
                            .font(.title.bold())
                        Text("吃什麼吵不停？交給法官來判決！")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 16)

                    // 輸入區
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("\(userName) 想吃：")
                                .font(.subheadline.bold())
                            TextField("例如：火鍋", text: $userAWant)
                                .textFieldStyle(.roundedBorder)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("\(partnerName) 想吃：")
                                .font(.subheadline.bold())
                            TextField("例如：壽司", text: $userBWant)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                    .padding(.horizontal)

                    // 開庭按鈕
                    Button {
                        Task {
                            verdict = nil
                            let result = await aiService.arbitrate(
                                userAName: userName,
                                userAWant: userAWant,
                                userBName: partnerName,
                                userBWant: userBWant
                            )
                            verdict = result
                        }
                    } label: {
                        if aiService.isLoading {
                            ProgressView()
                                .controlSize(.small)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        } else {
                            HStack(spacing: 4) {
                                Text("開庭！")
                                Image(systemName: "scalemass.fill")
                            }
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.appPrimary)
                    .disabled(!canSubmit)
                    .padding(.horizontal)

                    // 判決結果
                    if let verdict {
                        VStack(spacing: 12) {
                            HStack(spacing: 4) {
                                Image(systemName: "hammer.fill")
                                    .foregroundStyle(.appPrimary)
                                Text("判決結果")
                            }
                            .font(.headline)
                            Text(verdict)
                                .font(.body)
                                .multilineTextAlignment(.leading)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }

                    Spacer(minLength: 40)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .animation(.easeInOut, value: verdict != nil)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("關閉") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    ArbitratorView()
}
