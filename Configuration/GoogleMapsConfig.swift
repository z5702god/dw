import GoogleMaps

enum GoogleMapsConfig {
    /// Replace with your actual Google Maps API key
    /// Get one at: https://console.cloud.google.com/apis/credentials
    static let apiKey = "YOUR_GOOGLE_MAPS_API_KEY"

    /// Call this in AppDelegate.didFinishLaunchingWithOptions
    static func configure() {
        GMSServices.provideAPIKey(apiKey)
    }
}
