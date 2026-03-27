import SwiftUI
import PhotosUI
import CoreLocation

@Observable
final class MealFormViewModel {
    var restaurantName = ""
    var review = ""
    var rating: MealRating = .recommended
    var city: City = .taipei
    var selectedPhotos: [PhotosPickerItem] = []
    var loadedImages: [UIImage] = []
    var latitude: Double = 25.033
    var longitude: Double = 121.565
    var isLoading = false
    var errorMessage: String?

    private let mealRepo = MealRepository.shared
    private let storageRepo = StorageRepository.shared
    private let authRepo = AuthRepository.shared

    var isValid: Bool {
        !restaurantName.isEmpty && !review.isEmpty
    }

    func loadImages() async {
        var images: [UIImage] = []
        for item in selectedPhotos {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                images.append(image)
            }
        }
        loadedImages = images
    }

    func saveMeal() async -> Bool {
        guard let userId = authRepo.currentUserId else { return false }

        isLoading = true
        errorMessage = nil

        do {
            let mealId = UUID().uuidString

            // Upload photos
            var photoURLs: [String] = []
            if !loadedImages.isEmpty {
                photoURLs = try await storageRepo.uploadPhotos(loadedImages, mealId: mealId)
            }

            let meal = Meal(
                userId: userId,
                restaurantName: restaurantName,
                review: review,
                rating: rating,
                photoURLs: photoURLs,
                latitude: latitude,
                longitude: longitude,
                city: city
            )

            try await mealRepo.addMeal(meal)
            isLoading = false
            return true
        } catch {
            errorMessage = "儲存失敗：\(error.localizedDescription)"
            isLoading = false
            return false
        }
    }

    func updateCityDefaults() {
        latitude = city.defaultLatitude
        longitude = city.defaultLongitude
    }
}
