import Foundation

@MainActor
@Observable
final class AuthViewModel {
    var email = ""
    var password = ""
    var isLoading = false
    var errorMessage: String?

    private let authRepo = AuthRepository.shared

    var isSignedIn: Bool { authRepo.isSignedIn }

    func signIn() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "請輸入帳號和密碼"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await authRepo.signIn(email: email, password: password)
        } catch {
            errorMessage = "登入失敗：\(error.localizedDescription)"
        }

        isLoading = false
    }

    func signOut() {
        try? authRepo.signOut()
    }

    func deleteAccount() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                try await authRepo.deleteAccount()
            } catch {
                errorMessage = "刪除帳號失敗：\(error.localizedDescription)"
            }
            isLoading = false
        }
    }
}
