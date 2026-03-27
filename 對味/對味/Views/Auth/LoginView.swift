import SwiftUI

struct LoginView: View {
    @State private var viewModel = AuthViewModel()
    @State private var showLoginForm = false
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case email, password
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 32) {
                // Hero illustration area — full-width borderless
                Image("WelcomeIllustration")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1.2, contentMode: .fit)

                // Title group
                VStack(spacing: 12) {
                    Text("對味")
                        .font(.system(.largeTitle, design: .rounded, weight: .black))
                        .foregroundStyle(.primary)

                    Text("一起發現好味道")
                        .font(.title3)
                        .foregroundStyle(.secondary)

                    Text("記錄每一餐的美好，\n在地圖上標記你們的美食旅程。")
                        .font(.body)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }

                // Login section
                if showLoginForm {
                    VStack(spacing: 14) {
                        TextField("Email", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .textFieldStyle(.roundedBorder)
                            .focused($focusedField, equals: .email)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .password }

                        SecureField("密碼", text: $viewModel.password)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.password)
                            .focused($focusedField, equals: .password)
                            .submitLabel(.go)
                            .onSubmit {
                                focusedField = nil
                                Task { await viewModel.signIn() }
                            }

                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.ratingBad)
                        }

                        Button {
                            focusedField = nil
                            Task { await viewModel.signIn() }
                        } label: {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                                    .frame(maxWidth: .infinity, minHeight: 22)
                            } else {
                                Text("登入")
                                    .frame(maxWidth: .infinity, minHeight: 22)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .tint(.appPrimary)
                        .disabled(viewModel.isLoading)
                    }
                    .padding(20)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .transition(.opacity.combined(with: .scale))
                } else {
                    Button {
                        withAnimation(.spring(duration: 0.4)) {
                            showLoginForm = true
                        }
                    } label: {
                        Text("開始記錄")
                            .frame(maxWidth: .infinity, minHeight: 22)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .tint(.appPrimary)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 60)
        .background(Color(.systemBackground))
        .sensoryFeedback(.selection, trigger: showLoginForm)
        .scrollDismissesKeyboard(.interactively)
    }
}

#Preview {
    LoginView()
}
