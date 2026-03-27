import MapKit

@Observable
final class MapViewModel {
    var selectedCity: City = .taipei
    var selectedRating: MealRating?
    var cameraPosition: MapCameraPosition

    private let mealRepo = MealRepository.shared

    init() {
        cameraPosition = .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: City.taipei.defaultLatitude,
                longitude: City.taipei.defaultLongitude
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        ))
    }

    var currentCityCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: selectedCity.defaultLatitude,
            longitude: selectedCity.defaultLongitude
        )
    }

    var filteredMeals: [Meal] {
        var result = mealRepo.meals(inCity: selectedCity)
        if let rating = selectedRating {
            result = result.filter { $0.rating == rating }
        }
        return result
    }

    func switchCity(to city: City) {
        selectedCity = city
        cameraPosition = .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: city.defaultLatitude,
                longitude: city.defaultLongitude
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        ))
    }
}
