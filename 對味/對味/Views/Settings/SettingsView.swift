import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var authViewModel = AuthViewModel()
    @State private var authRepo = AuthRepository.shared

    @State private var logoutTrigger = false
    @State private var showLogoutAlert = false

    var body: some View {
        NavigationStack {
            Form {
                // User info
                Section("我的帳號") {
                    if let user = authRepo.appUser {
                        HStack {
                            UserAvatar(name: user.displayName, size: 40)
                            VStack(alignment: .leading) {
                                Text(user.displayName)
                                    .font(.headline)
                                Text(user.email)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                // Logout
                Section {
                    Button("登出", role: .destructive) {
                        showLogoutAlert = true
                    }
                }

                // App version
                Section {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
            .sensoryFeedback(.warning, trigger: logoutTrigger)
            .alert("確定要登出嗎？", isPresented: $showLogoutAlert) {
                Button("取消", role: .cancel) { }
                Button("登出", role: .destructive) {
                    logoutTrigger.toggle()
                    authViewModel.signOut()
                    dismiss()
                }
            }
        }
    }
}
