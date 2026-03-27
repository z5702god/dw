import SwiftUI

struct LoginView: View {
    @State private var viewModel = AuthViewModel()
    @State private var showLoginForm = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Hero illustration area
            Circle()
                .fill(Color(hex: "FFF3E6"))
                .frame(width: 220, height: 220)
                .overlay {
                    Image(systemName: "fork.knife")
                        .font(.system(size: 64))
                        .foregroundStyle(.appPrimary)
                }

            // Title group
            VStack(spacing: 12) {
                Text("對味")
                    .font(.system(size: 40, weight: .bold))
                    .tracking(-1.5)
                    .foregroundStyle(.appTextPrimary)

                Text("一起發現好味道")
                    .font(.system(size: 20))
                    .foregroundStyle(.appTextSecondary)

                Text("記錄每一餐的美好，\n在地圖上標記你們的美食旅程。")
                    .font(.system(size: 16))
                    .foregroundStyle(.appTextTertiary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            Spacer()

            // Login section
            if showLoginForm {
                VStack(spacing: 14) {
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)

                    SecureField("密碼", text: $viewModel.password)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.password)

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.ratingBad)
                    }

                    Button {
                        Task { await viewModel.signIn() }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity, minHeight: 22)
                        } else {
                            Text("登入")
                                .font(.system(size: 17, weight: .semibold))
                                .frame(maxWidth: .infinity, minHeight: 22)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.appPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .disabled(viewModel.isLoading)
                }
                .padding(.horizontal, 32)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                Button {
                    withAnimation(.spring(duration: 0.4)) {
                        showLoginForm = true
                    }
                } label: {
                    Text("登入")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 54)
                        .background(.appPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 32)
            }
        }
        .padding(.bottom, 60)
        .background(.white)
    }
}

#Preview {
    LoginView()
}
