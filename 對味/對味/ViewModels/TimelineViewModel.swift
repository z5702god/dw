import Foundation

struct MealGroup: Identifiable {
    let id: Date
    let title: String
    let meals: [Meal]
}

@MainActor
@Observable
final class TimelineViewModel {
    var selectedRating: MealRating?

    private let mealRepo = MealRepository.shared

    var filteredMeals: [Meal] {
        mealRepo.meals(filteredBy: selectedRating)
    }

    var groupedMeals: [MealGroup] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredMeals) { meal in
            calendar.startOfDay(for: meal.createdAt ?? .distantPast)
        }
        return grouped.keys.sorted(by: >).map { date in
            MealGroup(id: date, title: dateTitle(for: date), meals: grouped[date]!)
        }
    }

    private func dateTitle(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "今天" }
        if calendar.isDateInYesterday(date) { return "昨天" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh-TW")
        if calendar.isDate(date, equalTo: Date(), toGranularity: .year) {
            formatter.dateFormat = "M月d日 EEEE"
        } else {
            formatter.dateFormat = "yyyy年M月d日"
        }
        return formatter.string(from: date)
    }

    func deleteMeal(_ meal: Meal) async {
        guard let id = meal.id else { return }
        try? await mealRepo.deleteMeal(id: id)
    }
}
