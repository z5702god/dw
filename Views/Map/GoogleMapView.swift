import SwiftUI
import GoogleMaps

/// UIViewRepresentable wrapper for Google Maps SDK
struct GoogleMapView: UIViewRepresentable {
    let meals: [Meal]
    let centerCoordinate: CLLocationCoordinate2D
    let onMarkerTap: (Meal) -> Void

    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(
            withLatitude: centerCoordinate.latitude,
            longitude: centerCoordinate.longitude,
            zoom: 13
        )
        let mapView = GMSMapView(frame: .zero, camera: camera)
        mapView.delegate = context.coordinator
        mapView.settings.myLocationButton = false
        mapView.settings.compassButton = true

        // Apple-like clean map style
        mapView.mapType = .normal

        return mapView
    }

    func updateUIView(_ mapView: GMSMapView, context: Context) {
        // Update camera position when city changes
        let camera = GMSCameraPosition.camera(
            withLatitude: centerCoordinate.latitude,
            longitude: centerCoordinate.longitude,
            zoom: 13
        )
        mapView.animate(to: camera)

        // Clear existing markers and re-add
        mapView.clear()
        context.coordinator.mealsByMarker.removeAll()

        for meal in meals {
            let marker = GMSMarker()
            marker.position = meal.coordinate
            marker.title = meal.restaurantName
            marker.snippet = meal.rating.displayName
            marker.icon = markerImage(for: meal.rating)
            marker.map = mapView

            context.coordinator.mealsByMarker[marker] = meal
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onMarkerTap: onMarkerTap)
    }

    /// Generate color-coded marker icons
    private func markerImage(for rating: MealRating) -> UIImage {
        let color: UIColor = switch rating {
        case .recommended: .systemGreen
        case .ok: .systemOrange
        case .bad: .systemRed
        }

        let size = CGSize(width: 32, height: 32)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            color.setFill()
            let circle = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size).insetBy(dx: 2, dy: 2))
            circle.fill()

            // Draw utensils icon (simplified)
            UIColor.white.setFill()
            let iconRect = CGRect(x: 10, y: 8, width: 12, height: 16)
            let icon = UIBezierPath(roundedRect: iconRect, cornerRadius: 2)
            icon.fill()
        }
    }

    class Coordinator: NSObject, GMSMapViewDelegate {
        var mealsByMarker: [GMSMarker: Meal] = [:]
        let onMarkerTap: (Meal) -> Void

        init(onMarkerTap: @escaping (Meal) -> Void) {
            self.onMarkerTap = onMarkerTap
        }

        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            if let meal = mealsByMarker[marker] {
                onMarkerTap(meal)
            }
            return true
        }
    }
}
