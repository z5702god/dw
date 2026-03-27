import SwiftUI
import MapKit

struct MealMapView: View {
    let meals: [Meal]
    let centerCoordinate: CLLocationCoordinate2D
    let onMarkerTap: (Meal) -> Void

    @State private var position: MapCameraPosition = .automatic

    /// Only show meals that have valid coordinates
    private var mappableMeals: [Meal] {
        meals.filter { $0.coordinate != nil }
    }

    var body: some View {
        Map(position: $position) {
            ForEach(mappableMeals) { meal in
                if let coordinate = meal.coordinate {
                    Annotation(meal.displayTitle, coordinate: coordinate) {
                        RestaurantAnnotationView(meal: meal)
                            .onTapGesture {
                                onMarkerTap(meal)
                            }
                    }
                }
            }
        }
        .mapStyle(.standard)
        .mapControls {
            MapCompass()
            MapScaleView()
        }
        .onChange(of: centerCoordinate.latitude) {
            moveTo(centerCoordinate)
        }
        .onChange(of: centerCoordinate.longitude) {
            moveTo(centerCoordinate)
        }
        .onAppear {
            moveTo(centerCoordinate)
        }
    }

    private func moveTo(_ coordinate: CLLocationCoordinate2D) {
        withAnimation(.easeInOut(duration: 0.5)) {
            position = .region(MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
        }
    }
}
