import MapKit

@MainActor
@Observable
class LocationSearchService {
    var results: [MKMapItem] = []
    var isSearching = false

    /// 搜尋地點，優先搜附近，找不到再 fallback 到全台灣
    func search(query: String, near location: CLLocationCoordinate2D? = nil) async {
        guard !query.isEmpty else {
            results = []
            return
        }

        isSearching = true

        // 如果有使用者位置，先搜附近（約 10km 範圍）
        if let location {
            let nearbyResults = await performSearch(
                query: query,
                center: location,
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
            if !nearbyResults.isEmpty {
                results = nearbyResults
                isSearching = false
                return
            }
        }

        // Fallback: 搜尋整個台灣
        results = await performSearch(
            query: query,
            center: CLLocationCoordinate2D(latitude: 23.5, longitude: 121.0),
            span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)
        )

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
        request.resultTypes = .pointOfInterest

        let search = MKLocalSearch(request: request)
        if let response = try? await search.start() {
            return response.mapItems
        }
        return []
    }

    func clear() {
        results = []
    }
}
