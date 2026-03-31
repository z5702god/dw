import CoreLocation

@MainActor
@Observable
final class MapViewModel {
    var selectedCity: City = .taipeiCity
    var selectedRating: MealRating?
    var hasManuallySelectedCity = false

    private let mealRepo = MealRepository.shared
    private let locationManager = LocationManager.shared

    var currentCityCoordinate: CLLocationCoordinate2D {
        // 如果使用者手動選了城市，用城市中心
        if hasManuallySelectedCity {
            return CLLocationCoordinate2D(
                latitude: selectedCity.defaultLatitude,
                longitude: selectedCity.defaultLongitude
            )
        }
        // 否則優先用使用者實際位置
        if let userLocation = locationManager.userLocation {
            return userLocation
        }
        // Fallback: 城市中心
        return CLLocationCoordinate2D(
            latitude: selectedCity.defaultLatitude,
            longitude: selectedCity.defaultLongitude
        )
    }

    func selectCity(_ city: City) {
        selectedCity = city
        hasManuallySelectedCity = true
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
