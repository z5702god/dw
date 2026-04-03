import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var authViewModel = AuthViewModel()
    @State private var authRepo = AuthRepository.shared

    @State private var logoutTrigger = false
    @State private var showLogoutAlert = false
    @State private var showDeleteAlert = false

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

                // 口味身分證
                Section {
                    NavigationLink {
                        TasteProfileView()
                    } label: {
                        Label("口味身分證", systemImage: "person.text.rectangle")
                    }
                }

                // About
                Section("關於") {
                    if let url = URL(string: "https://z5702god.github.io/dw/") {
                        Link(destination: url) {
                            HStack {
                                Text("隱私權政策")
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                // Delete account
                Section {
                    Button("刪除帳號") {
                        showDeleteAlert = true
                    }
                    .foregroundStyle(.red)
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
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—")
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
            .alert("確定要刪除帳號嗎？", isPresented: $showDeleteAlert) {
                Button("取消", role: .cancel) { }
                Button("確定刪除", role: .destructive) {
                    authViewModel.deleteAccount()
                    dismiss()
                }
            } message: {
                Text("刪除帳號將永久移除所有資料，此操作無法復原。確定要刪除嗎？")
            }
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
