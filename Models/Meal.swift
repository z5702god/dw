import Foundation
import FirebaseFirestore
import CoreLocation

struct Meal: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var restaurantName: String
    var review: String
    var rating: MealRating
    var photoURLs: [String]
    var latitude: Double
    var longitude: Double
    var city: City
    @ServerTimestamp var createdAt: Date?

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

enum MealRating: String, Codable, CaseIterable {
    case recommended = "recommended"
    case ok = "ok"
    case bad = "bad"

    var displayName: String {
        switch self {
        case .recommended: return "推薦"
        case .ok: return "普通"
        case .bad: return "踩雷"
        }
    }

    var color: String {
        switch self {
        case .recommended: return "green"
        case .ok: return "orange"
        case .bad: return "red"
        }
    }

    var icon: String {
        switch self {
        case .recommended: return "hand.thumbsup.fill"
        case .ok: return "hand.thumbsup"
        case .bad: return "hand.thumbsdown.fill"
        }
    }
}

enum City: String, Codable, CaseIterable {
    case taipei = "taipei"
    case taichung = "taichung"

    var displayName: String {
        switch self {
        case .taipei: return "台北"
        case .taichung: return "台中"
        }
    }

    var defaultLatitude: Double {
        switch self {
        case .taipei: return 25.033
        case .taichung: return 24.147
        }
    }

    var defaultLongitude: Double {
        switch self {
        case .taipei: return 121.565
        case .taichung: return 120.673
        }
    }
}
