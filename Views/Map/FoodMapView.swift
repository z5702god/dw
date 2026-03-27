import SwiftUI
import MapKit

struct FoodMapView: View {
    @State private var viewModel = MapViewModel()
    @State private var selectedMeal: Meal?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // MapKit (之後可換成 Google Maps)
                Map(position: $viewModel.cameraPosition) {
                    ForEach(viewModel.filteredMeals) { meal in
                        Annotation(meal.restaurantName, coordinate: meal.coordinate) {
                            RestaurantAnnotationView(rating: meal.rating)
                                .onTapGesture {
                                    selectedMeal = meal
                                }
                        }
                    }
                }
                .mapStyle(.standard)

                // Floating controls overlay
                VStack(spacing: 8) {
                    Picker("城市", selection: $viewModel.selectedCity) {
                        ForEach(City.allCases, id: \.self) { city in
                            Text(city.displayName).tag(city)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .onChange(of: viewModel.selectedCity) { _, newCity in
                        viewModel.switchCity(to: newCity)
                    }

                    MapFilterView(selectedRating: $viewModel.selectedRating)
                }
                .padding(.top, 8)
            }
            .navigationTitle("美食地圖")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedMeal) { meal in
                NavigationStack {
                    MealDetailView(meal: meal)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("完成") { selectedMeal = nil }
                            }
                        }
                }
                .presentationDetents([.medium, .large])
            }
        }
    }
}

#Preview {
    FoodMapView()
}
