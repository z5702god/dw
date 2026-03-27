import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var authViewModel = AuthViewModel()
    @State private var authRepo = AuthRepository.shared

    @State private var breakfastTime = dateFromTimeString("08:00")
    @State private var lunchTime = dateFromTimeString("12:00")
    @State private var dinnerTime = dateFromTimeString("18:30")
    @State private var notificationsEnabled = true

    var body: some View {
        NavigationStack {
            Form {
                // User info
                Section("帳號") {
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

                // Reminder settings
                Section("吃飯提醒時間") {
                    Toggle("啟用提醒", isOn: $notificationsEnabled)

                    if notificationsEnabled {
                        DatePicker("早餐", selection: $breakfastTime, displayedComponents: .hourAndMinute)
                        DatePicker("午餐", selection: $lunchTime, displayedComponents: .hourAndMinute)
                        DatePicker("晚餐", selection: $dinnerTime, displayedComponents: .hourAndMinute)
                    }
                }
                .onChange(of: breakfastTime) { updateReminders() }
                .onChange(of: lunchTime) { updateReminders() }
                .onChange(of: dinnerTime) { updateReminders() }
                .onChange(of: notificationsEnabled) {
                    if notificationsEnabled {
                        updateReminders()
                    } else {
                        NotificationConfig.cancelAllReminders()
                    }
                }

                // Logout
                Section {
                    Button("登出", role: .destructive) {
                        authViewModel.signOut()
                        dismiss()
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
            .onAppear { loadSettings() }
        }
    }

    private func loadSettings() {
        guard let settings = authRepo.appUser?.reminderSettings else { return }
        breakfastTime = Self.dateFromTimeString(settings.breakfast)
        lunchTime = Self.dateFromTimeString(settings.lunch)
        dinnerTime = Self.dateFromTimeString(settings.dinner)
    }

    private func updateReminders() {
        let settings = AppUser.ReminderSettings(
            breakfast: timeString(from: breakfastTime),
            lunch: timeString(from: lunchTime),
            dinner: timeString(from: dinnerTime)
        )
        NotificationConfig.scheduleMealReminders(settings: settings)

        // Save to Firestore
        if let userId = authRepo.currentUserId {
            Task {
                try? await FirebaseConfig.userDocument(userId).updateData([
                    "reminderSettings": [
                        "breakfast": settings.breakfast,
                        "lunch": settings.lunch,
                        "dinner": settings.dinner
                    ]
                ])
            }
        }
    }

    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private static func dateFromTimeString(_ time: String) -> Date {
        let components = time.split(separator: ":").compactMap { Int($0) }
        guard components.count == 2 else { return Date() }

        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        dateComponents.hour = components[0]
        dateComponents.minute = components[1]
        return Calendar.current.date(from: dateComponents) ?? Date()
    }
}
