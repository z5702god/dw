import MapKit

@MainActor
@Observable
class LocationSearchService {
    var results: [MKMapItem] = []
    var isSearching = false

    func search(query: String) async {
        guard !query.isEmpty else {
            results = []
            return
        }

        isSearching = true

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        // 搜尋範圍：台灣
        request.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 23.5, longitude: 121.0),
            span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)
        )
        request.resultTypes = .pointOfInterest

        let search = MKLocalSearch(request: request)
        if let response = try? await search.start() {
            results = response.mapItems
        } else {
            results = []
        }

        isSearching = false
    }

    func clear() {
        results = []
    }
}
