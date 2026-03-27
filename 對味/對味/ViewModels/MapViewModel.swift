import CoreLocation

@MainActor
@Observable
final class MapViewModel {
    var selectedCity: City = .taipeiCity
    var selectedRating: MealRating?

    private let mealRepo = MealRepository.shared

    var currentCityCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: selectedCity.defaultLatitude,
            longitude: selectedCity.defaultLongitude
        )
    }

    /// 顯示所有有座標的外食紀錄（不按城市篩選，城市只控制視角）
    var filteredMeals: [Meal] {
        var result = mealRepo.meals
            .filter { $0.mealPlace == .restaurant && $0.coordinate != nil }
        if let rating = selectedRating {
            result = result.filter { $0.rating == rating }
        }
        return result
    }
}
