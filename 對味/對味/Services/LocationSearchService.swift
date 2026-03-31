import MapKit

@MainActor
@Observable
class LocationSearchService {
    var results: [MKMapItem] = []
    var isSearching = false

    /// 搜尋地點：附近結果排前面，全台結果補在後面
    func search(query: String, near location: CLLocationCoordinate2D? = nil) async {
        guard !query.isEmpty else {
            results = []
            return
        }

        isSearching = true

        var allResults: [MKMapItem] = []

        // 如果有使用者位置，先搜附近（約 10km 範圍），結果排前面
        if let location {
            let nearbyResults = await performSearch(
                query: query,
                center: location,
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
            allResults.append(contentsOf: nearbyResults)
        }

        // 再搜全台灣補充結果
        let taiwanResults = await performSearch(
            query: query,
            center: CLLocationCoordinate2D(latitude: 23.5, longitude: 121.0),
            span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)
        )

        // 合併去重（附近的排前面）
        let existingNames = Set(allResults.map { uniqueKey(for: $0) })
        for item in taiwanResults {
            if !existingNames.contains(uniqueKey(for: item)) {
                allResults.append(item)
            }
        }

        results = allResults
        isSearching = false
    }

    private func performSearch(
        query: String,
        center: CLLocationCoordinate2D,
        span: MKCoordinateSpan
    ) async -> [MKMapItem] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = MKCoordinateRegion(center: center, span: span)

        let search = MKLocalSearch(request: request)
        if let response = try? await search.start() {
            return response.mapItems
        }
        return []
    }

    /// 用名稱+座標作為唯一 key 去重
    private func uniqueKey(for item: MKMapItem) -> String {
        let name = item.name ?? ""
        let lat = String(format: "%.4f", item.placemark.coordinate.latitude)
        let lon = String(format: "%.4f", item.placemark.coordinate.longitude)
        return "\(name)_\(lat)_\(lon)"
    }

    func clear() {
        results = []
    }
}
