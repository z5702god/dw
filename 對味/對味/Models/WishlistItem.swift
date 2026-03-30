import Foundation
import FirebaseFirestore
import CoreLocation

struct WishlistItem: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var address: String?
    var latitude: Double?
    var longitude: Double?
    var city: City?
    var addedBy: String
    var isVisited: Bool
    var visitedMealId: String?
    @ServerTimestamp var createdAt: Date?

    var coordinate: CLLocationCoordinate2D? {
        guard let latitude, let longitude else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
