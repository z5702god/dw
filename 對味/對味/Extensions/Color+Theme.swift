import SwiftUI

// MARK: - Brand Colors (only custom colors that don't exist in iOS)
extension Color {
    static let appPrimary = Color(hex: "FF9500")
    static let ratingOk = Color(hex: "FF9500")
    static let wishlistGold = Color(hex: "FFB800")
}

// MARK: - Semantic Aliases (for cleaner call sites)
extension Color {
    static let appBackground = Color(.systemGroupedBackground)
    static let appCardBackground = Color(.secondarySystemGroupedBackground)
    static let appTabBar = Color(.systemBackground)
    static let ratingRecommended = Color(.systemGreen)
    static let ratingBad = Color(.systemRed)
}

// MARK: - ShapeStyle conformance for .foregroundStyle() / .background()
extension ShapeStyle where Self == Color {
    static var appPrimary: Color { Color.appPrimary }
    static var appBackground: Color { Color.appBackground }
    static var appCardBackground: Color { Color.appCardBackground }
    static var ratingRecommended: Color { Color.ratingRecommended }
    static var ratingOk: Color { Color.ratingOk }
    static var ratingBad: Color { Color.ratingBad }
    static var wishlistGold: Color { Color.wishlistGold }
}

// MARK: - Hex Initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b, a: UInt64
        switch hex.count {
        case 6:
            (r, g, b, a) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8:
            (r, g, b, a) = (int >> 24 & 0xFF, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b, a) = (0, 0, 0, 255)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
