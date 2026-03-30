import SwiftUI
import MapKit

@MainActor
@Observable
final class WishlistViewModel {
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

    private let repo = WishlistRepository.shared
    private let authRepo = AuthRepository.shared

    /// 進入搜尋模式，用當前文字搜尋
    func enterSearchMode() {
        isSearchMode = true
        Task { await locationSearch.search(query: searchQuery) }
    }

    /// 退出搜尋模式
    func exitSearchMode() {
        isSearchMode = false
        locationSearch.clear()
    }

    /// 搜尋模式中輸入時搜尋
    func performSearch() async {
        guard isSearchMode else { return }
        await locationSearch.search(query: searchQuery)
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

    /// 清除選擇的地點
    func clearLocation() {
        selectedLocation = nil
        latitude = nil
        longitude = nil
        city = nil
        address = nil
    }

    /// 儲存想去清單項目
    func saveItem() async -> Bool {
        guard !name.isEmpty, let userId = authRepo.currentUserId else { return false }

        isLoading = true
        do {
            let item = WishlistItem(
                name: name,
                address: address,
                latitude: latitude,
                longitude: longitude,
                city: city,
                addedBy: userId,
                isVisited: false
            )
            try await repo.addItem(item)
            isLoading = false
            return true
        } catch {
            #if DEBUG
            print("[WishlistViewModel] Failed to save item: \(error.localizedDescription)")
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
            print("[WishlistViewModel] Failed to delete item: \(error.localizedDescription)")
            #endif
        }
    }

    /// 標記為已去過
    func markVisited(id: String, mealId: String) async {
        do {
            try await repo.markAsVisited(id: id, mealId: mealId)
        } catch {
            #if DEBUG
            print("[WishlistViewModel] Failed to mark visited: \(error.localizedDescription)")
            #endif
        }
    }

    /// 取消已去過標記
    func unmarkVisited(id: String) async {
        do {
            try await repo.unmarkVisited(id: id)
        } catch {
            #if DEBUG
            print("[WishlistViewModel] Failed to unmark visited: \(error.localizedDescription)")
            #endif
        }
    }
}
