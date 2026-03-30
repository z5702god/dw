import Foundation

@MainActor
@Observable
final class RecapViewModel {
    private let mealRepo = MealRepository.shared

    var currentMonthMeals: [Meal] = []
    var totalMealsThisMonth: Int = 0
    var topRatedMeal: Meal?
    var citiesVisited: Int = 0
    var restaurantCount: Int = 0
    var homeCount: Int = 0

    func generateRecap() {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month], from: now)

        currentMonthMeals = mealRepo.meals.filter { meal in
            guard let date = meal.createdAt else { return false }
            let mealComponents = calendar.dateComponents([.year, .month], from: date)
            return mealComponents.year == components.year && mealComponents.month == components.month
        }

        totalMealsThisMonth = currentMonthMeals.count

        // Top rated meal: recommended meals, pick the one with the longest review
        topRatedMeal = currentMonthMeals
            .filter { $0.rating == .recommended }
            .max { $0.review.count < $1.review.count }

        // Unique cities
        let uniqueCities = Set(currentMonthMeals.compactMap { $0.city })
        citiesVisited = uniqueCities.count

        // Restaurant vs home
        restaurantCount = currentMonthMeals.filter { $0.mealPlace == .restaurant }.count
        homeCount = currentMonthMeals.filter { $0.mealPlace == .home }.count
    }

    var currentMonthName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_TW")
        formatter.dateFormat = "M月"
        return formatter.string(from: Date())
    }
}
