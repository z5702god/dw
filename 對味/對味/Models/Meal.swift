import Foundation
import FirebaseFirestore
import CoreLocation

// MARK: - Meal Place (外食 vs 自煮)
enum MealPlace: String, Codable, CaseIterable {
    case restaurant = "restaurant"
    case home = "home"

    var displayName: String {
        switch self {
        case .restaurant: return "外食"
        case .home: return "自煮"
        }
    }

    var icon: String {
        switch self {
        case .restaurant: return "fork.knife"
        case .home: return "house"
        }
    }
}

// MARK: - Meal Slot (餐別)
enum MealSlot: String, Codable, CaseIterable {
    case breakfast = "breakfast"
    case lunch = "lunch"
    case dinner = "dinner"

    var displayName: String {
        switch self {
        case .breakfast: return "早餐"
        case .lunch: return "午餐"
        case .dinner: return "晚餐"
        }
    }

    var icon: String {
        switch self {
        case .breakfast: return "sun.rise"
        case .lunch: return "sun.max"
        case .dinner: return "moon.stars"
        }
    }
}

// MARK: - Meal Mood (心情標籤)
enum MealMood: String, Codable, CaseIterable {
    case happy = "happy"
    case date = "date"
    case missing = "missing"
    case daily = "daily"

    var displayName: String {
        switch self {
        case .happy: return "開心"
        case .date: return "約會"
        case .missing: return "想念"
        case .daily: return "日常"
        }
    }

    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .date: return "💕"
        case .missing: return "🥺"
        case .daily: return "🍽️"
        }
    }
}

// MARK: - Meal Model
struct Meal: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var mealPlace: MealPlace
    var mealSlot: MealSlot
    var restaurantName: String?    // 外食時的餐廳名
    var foodName: String?          // 自煮時的食物名
    var review: String
    var rating: MealRating
    var photoURLs: [String]
    var latitude: Double?
    var longitude: Double?
    var city: City?
    var address: String?
    var mood: MealMood?            // V1.2: 心情標籤
    var partnerReview: String?     // V1.2: 對方的心得
    var partnerReviewedAt: Date?   // V1.2: 對方留心得的時間
    @ServerTimestamp var createdAt: Date?

    var coordinate: CLLocationCoordinate2D? {
        guard let latitude, let longitude else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// 顯示用的標題
    var displayTitle: String {
        switch mealPlace {
        case .restaurant: return restaurantName ?? "未命名餐廳"
        case .home: return foodName ?? "自煮料理"
        }
    }

    // 向後相容：舊資料沒有 mealPlace/mealSlot
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decode(DocumentID<String>.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        mealPlace = try container.decodeIfPresent(MealPlace.self, forKey: .mealPlace) ?? .restaurant
        mealSlot = try container.decodeIfPresent(MealSlot.self, forKey: .mealSlot) ?? .dinner
        restaurantName = try container.decodeIfPresent(String.self, forKey: .restaurantName)
        foodName = try container.decodeIfPresent(String.self, forKey: .foodName)
        review = try container.decode(String.self, forKey: .review)
        rating = try container.decode(MealRating.self, forKey: .rating)
        photoURLs = try container.decode([String].self, forKey: .photoURLs)
        latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        city = try container.decodeIfPresent(City.self, forKey: .city)
        address = try container.decodeIfPresent(String.self, forKey: .address)
        mood = try container.decodeIfPresent(MealMood.self, forKey: .mood)
        partnerReview = try container.decodeIfPresent(String.self, forKey: .partnerReview)
        partnerReviewedAt = try container.decodeIfPresent(Date.self, forKey: .partnerReviewedAt)
        _createdAt = try container.decode(ServerTimestamp<Date>.self, forKey: .createdAt)
    }

    // 程式碼建立用
    init(userId: String, mealPlace: MealPlace, mealSlot: MealSlot, restaurantName: String? = nil, foodName: String? = nil, review: String, rating: MealRating, photoURLs: [String], latitude: Double? = nil, longitude: Double? = nil, city: City? = nil, address: String? = nil, mood: MealMood? = nil) {
        self.userId = userId
        self.mealPlace = mealPlace
        self.mealSlot = mealSlot
        self.restaurantName = restaurantName
        self.foodName = foodName
        self.review = review
        self.rating = rating
        self.photoURLs = photoURLs
        self.latitude = latitude
        self.longitude = longitude
        self.city = city
        self.address = address
        self.mood = mood
    }
}

// MARK: - Meal Rating
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

// MARK: - City (全台 22 縣市)
enum City: String, Codable, CaseIterable {
    case taipeiCity = "taipei"
    case newTaipeiCity = "new_taipei"
    case taoyuanCity = "taoyuan"
    case taichungCity = "taichung"
    case tainanCity = "tainan"
    case kaohsiungCity = "kaohsiung"
    case keelungCity = "keelung"
    case hsinchuCity = "hsinchu_city"
    case chiayiCity = "chiayi_city"
    case hsinchuCounty = "hsinchu_county"
    case miaoliCounty = "miaoli"
    case changhuaCounty = "changhua"
    case nantouCounty = "nantou"
    case yunlinCounty = "yunlin"
    case chiayiCounty = "chiayi_county"
    case pingtungCounty = "pingtung"
    case yilanCounty = "yilan"
    case hualienCounty = "hualien"
    case taitungCounty = "taitung"
    case penghuCounty = "penghu"
    case kinmenCounty = "kinmen"
    case lianjiangCounty = "lianjiang"

    var displayName: String {
        switch self {
        case .taipeiCity: return "台北市"
        case .newTaipeiCity: return "新北市"
        case .taoyuanCity: return "桃園市"
        case .taichungCity: return "台中市"
        case .tainanCity: return "台南市"
        case .kaohsiungCity: return "高雄市"
        case .keelungCity: return "基隆市"
        case .hsinchuCity: return "新竹市"
        case .chiayiCity: return "嘉義市"
        case .hsinchuCounty: return "新竹縣"
        case .miaoliCounty: return "苗栗縣"
        case .changhuaCounty: return "彰化縣"
        case .nantouCounty: return "南投縣"
        case .yunlinCounty: return "雲林縣"
        case .chiayiCounty: return "嘉義縣"
        case .pingtungCounty: return "屏東縣"
        case .yilanCounty: return "宜蘭縣"
        case .hualienCounty: return "花蓮縣"
        case .taitungCounty: return "台東縣"
        case .penghuCounty: return "澎湖縣"
        case .kinmenCounty: return "金門縣"
        case .lianjiangCounty: return "連江縣"
        }
    }

    var defaultLatitude: Double {
        switch self {
        case .taipeiCity: return 25.033
        case .newTaipeiCity: return 25.012
        case .taoyuanCity: return 24.994
        case .taichungCity: return 24.147
        case .tainanCity: return 22.999
        case .kaohsiungCity: return 22.627
        case .keelungCity: return 25.128
        case .hsinchuCity: return 24.804
        case .chiayiCity: return 23.480
        case .hsinchuCounty: return 24.839
        case .miaoliCounty: return 24.560
        case .changhuaCounty: return 24.076
        case .nantouCounty: return 23.961
        case .yunlinCounty: return 23.709
        case .chiayiCounty: return 23.452
        case .pingtungCounty: return 22.669
        case .yilanCounty: return 24.757
        case .hualienCounty: return 23.991
        case .taitungCounty: return 22.756
        case .penghuCounty: return 23.571
        case .kinmenCounty: return 24.449
        case .lianjiangCounty: return 26.160
        }
    }

    var defaultLongitude: Double {
        switch self {
        case .taipeiCity: return 121.565
        case .newTaipeiCity: return 121.465
        case .taoyuanCity: return 121.301
        case .taichungCity: return 120.673
        case .tainanCity: return 120.227
        case .kaohsiungCity: return 120.301
        case .keelungCity: return 121.739
        case .hsinchuCity: return 120.972
        case .chiayiCity: return 120.449
        case .hsinchuCounty: return 121.004
        case .miaoliCounty: return 120.821
        case .changhuaCounty: return 120.542
        case .nantouCounty: return 120.685
        case .yunlinCounty: return 120.431
        case .chiayiCounty: return 120.255
        case .pingtungCounty: return 120.486
        case .yilanCounty: return 121.753
        case .hualienCounty: return 121.601
        case .taitungCounty: return 121.144
        case .penghuCounty: return 119.579
        case .kinmenCounty: return 118.377
        case .lianjiangCounty: return 119.950
        }
    }
}
