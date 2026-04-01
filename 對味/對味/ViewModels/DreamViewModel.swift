import SwiftUI
import MapKit

@MainActor
@Observable
final class DreamViewModel {
    var searchQuery = ""
    var isSearchMode = false
    var selectedLocation: MKMapItem?
    var isLoading = false

    // 地點資訊
    var name = ""
    var latitude: Double?
    var longitude: Double?
    var address: String?
    var city: City?

    let locationSearch = LocationSearchService()
    private let locationManager = LocationManager.shared

    private let repo = DreamRepository.shared
    private let authRepo = AuthRepository.shared

    /// 進入搜尋模式
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

        if let locality = item.placemark.administrativeArea {
            city = City.allCases.first { locality.contains($0.displayName.replacingOccurrences(of: "市", with: "").replacingOccurrences(of: "縣", with: "")) }
        }

        isSearchMode = false
        locationSearch.clear()
        searchQuery = ""
    }

    /// 清除選擇的地點
    func clearLocation() {
        selectedLocation = nil
        latitude = nil
        longitude = nil
        city = nil
        address = nil
    }

    /// 儲存夢幻餐廳
    func saveItem() async -> Bool {
        guard !name.isEmpty, let userId = authRepo.currentUserId else { return false }

        isLoading = true
        do {
            let item = DreamRestaurant(
                name: name,
                address: address,
                latitude: latitude,
                longitude: longitude,
                city: city,
                addedBy: userId
            )
            try await repo.addItem(item)
            isLoading = false
            return true
        } catch {
            #if DEBUG
            print("[DreamViewModel] Failed to save item: \(error.localizedDescription)")
            #endif
            isLoading = false
            return false
        }
    }

    /// 刪除項目
    func deleteItem(id: String) async {
        do {
            try await repo.deleteItem(id: id)
        } catch {
            #if DEBUG
            print("[DreamViewModel] Failed to delete item: \(error.localizedDescription)")
            #endif
        }
    }
}
