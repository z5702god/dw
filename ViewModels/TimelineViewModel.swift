import Foundation

@Observable
final class TimelineViewModel {
    var selectedRating: MealRating?

    private let mealRepo = MealRepository.shared

    var filteredMeals: [Meal] {
        mealRepo.meals(filteredBy: selectedRating)
    }

    func deleteMeal(_ meal: Meal) async {
        guard let id = meal.id else { return }
        try? await mealRepo.deleteMeal(id: id)
    }
}
