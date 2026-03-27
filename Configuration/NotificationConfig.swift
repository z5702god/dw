import UserNotifications

enum NotificationConfig {
    static func scheduleMealReminders(settings: AppUser.ReminderSettings) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        for mealType in MealType.allCases {
            let timeString = settings.time(for: mealType)
            let components = timeString.split(separator: ":").compactMap { Int($0) }
            guard components.count == 2 else { continue }

            let content = UNMutableNotificationContent()
            content.title = "吃飯時間到囉！"
            content.body = "\(mealType.displayName)時間，記得打卡！"
            content.sound = .default

            var dateComponents = DateComponents()
            dateComponents.hour = components[0]
            dateComponents.minute = components[1]

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: true
            )

            let request = UNNotificationRequest(
                identifier: "meal_reminder_\(mealType.rawValue)",
                content: content,
                trigger: trigger
            )

            center.add(request)
        }
    }

    static func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
