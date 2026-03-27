import Foundation

extension Date {
    var shortDateString: String {
        formatted(.dateTime.month().day())
    }

    var fullDateString: String {
        formatted(.dateTime.year().month().day())
    }

    var timeString: String {
        formatted(.dateTime.hour().minute())
    }

    var relativeDateString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "zh-Hant")
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
