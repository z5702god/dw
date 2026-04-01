import Foundation
import FirebaseFirestore
import CoreLocation

struct DreamRestaurant: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var address: String?
    var latitude: Double?
    var longitude: Double?
    var city: City?
    var addedBy: String
    @ServerTimestamp var createdAt: Date?

    var coordinate: CLLocationCoordinate2D? {
        guard let latitude, let longitude else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// 用於配對比較的正規化名稱（去空白、統一小寫）
    var normalizedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
