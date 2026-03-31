import SwiftUI
import PhotosUI
import MapKit

@MainActor
@Observable
final class MealFormViewModel {
    var name = ""
    var review = ""
    var rating: MealRating = .recommended
    var mood: MealMood?
    var selectedPhotos: [PhotosPickerItem] = []
    var loadedImages: [UIImage] = []
    var isLoading = false
    var errorMessage: String?
    var pointEarned = false

    // 地點搜尋
    var searchQuery = ""
    var isSearchMode = false
    var selectedLocation: MKMapItem?
    var hasManualLocation = false
    var latitude: Double?
    var longitude: Double?
    var city: City?
    var address: String?

    let locationSearch = LocationSearchService()
    private let locationManager = LocationManager.shared

    private let mealRepo = MealRepository.shared
    private let storageRepo = StorageRepository.shared
    private let authRepo = AuthRepository.shared
    private let pointsService = PointsService.shared

    // 有選地點 = 外食，沒選 = 在家
    var mealPlace: MealPlace {
        (selectedLocation != nil || hasManualLocation) ? .restaurant : .home
    }

    var hasLocation: Bool {
        selectedLocation != nil || hasManualLocation
    }

    // 自動餐別
    var mealSlot: MealSlot {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 11 { return .breakfast }
        if hour < 16 { return .lunch }
        return .dinner
    }

    var isValid: Bool {
        !name.isEmpty
    }

    /// 進入搜尋模式，用當前文字搜尋
    func enterSearchMode() {
        isSearchMode = true
        Task { await locationSearch.search(query: searchQuery, near: locationManager.userLocation) }
    }

    /// 退出搜尋模式
    func exitSearchMode() {
        isSearchMode = false
        locationSearch.clear()
    }

    /// 搜尋模式中輸入時搜尋
    func performSearch() async {
        guard isSearchMode else { return }
        await locationSearch.search(query: searchQuery, near: locationManager.userLocation)
    }

    /// 選擇搜尋結果
    func selectLocation(_ item: MKMapItem) {
        selectedLocation = item
        name = item.name ?? ""
        latitude = item.placemark.coordinate.latitude
        longitude = item.placemark.coordinate.longitude
        address = [item.placemark.locality, item.placemark.thoroughfare, item.placemark.subThoroughfare]
            .compactMap { $0 }
            .joined(separator: "")

        // 嘗試匹配城市
        if let locality = item.placemark.administrativeArea {
            city = City.allCases.first { locality.contains($0.displayName.replacingOccurrences(of: "市", with: "").replacingOccurrences(of: "縣", with: "")) }
        }

        isSearchMode = false
        locationSearch.clear()
        searchQuery = ""
    }

    /// 手動在地圖上選擇位置
    func selectManualLocation(coordinate: CLLocationCoordinate2D, address: String?, city: City?) {
        hasManualLocation = true
        latitude = coordinate.latitude
        longitude = coordinate.longitude
        self.address = address
        self.city = city

        // 如果用戶還沒輸入名稱，保持 searchQuery 作為名稱
        if name.isEmpty && !searchQuery.isEmpty {
            name = searchQuery
        }

        isSearchMode = false
        locationSearch.clear()
        searchQuery = ""
    }

    /// 清除選擇的地點（改為在家）
    func clearLocation() {
        selectedLocation = nil
        hasManualLocation = false
        latitude = nil
        longitude = nil
        city = nil
        address = nil
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
        pointEarned = false

        do {
            let mealId = UUID().uuidString

            var photoURLs: [String] = []
            if !loadedImages.isEmpty {
                photoURLs = try await storageRepo.uploadPhotos(loadedImages, mealId: mealId)
            }

            let meal = Meal(
                userId: userId,
                mealPlace: mealPlace,
                mealSlot: mealSlot,
                restaurantName: mealPlace == .restaurant ? name : nil,
                foodName: mealPlace == .home ? name : nil,
                review: review,
                rating: rating,
                photoURLs: photoURLs,
                latitude: latitude,
                longitude: longitude,
                city: city,
                address: address,
                mood: mood
            )

            try await mealRepo.addMeal(meal)

            if let earned = try? await pointsService.awardPointIfEligible(mealSlot: mealSlot, userId: userId), earned {
                pointEarned = true
            }

            isLoading = false
            return true
        } catch {
            errorMessage = "儲存失敗：\(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
}
