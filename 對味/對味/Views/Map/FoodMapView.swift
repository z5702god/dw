import SwiftUI
import Kingfisher

struct FoodMapView: View {
    @State private var viewModel = MapViewModel()
    @State private var selectedMeal: Meal?

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // Map area — always 55% of screen
                ZStack(alignment: .top) {
                    MealMapView(
                        meals: viewModel.filteredMeals,
                        centerCoordinate: viewModel.currentCityCoordinate,
                        onMarkerTap: { meal in
                            selectedMeal = meal
                        }
                    )

                    // Floating controls
                    VStack(spacing: 10) {
                        Menu {
                            ForEach(City.allCases, id: \.self) { city in
                                Button {
                                    viewModel.selectedCity = city
                                } label: {
                                    if city == viewModel.selectedCity {
                                        Label(city.displayName, systemImage: "checkmark")
                                    } else {
                                        Text(city.displayName)
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.subheadline)
                                    .foregroundStyle(.appPrimary)
                                Text(viewModel.selectedCity.displayName)
                                    .font(.subheadline.weight(.semibold))
                                Image(systemName: "chevron.down")
                                    .font(.caption2.weight(.semibold))
                            }
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
                        }

                        HStack {
                            MapFilterView(selectedRating: $viewModel.selectedRating)
                            Spacer()
                        }
                    }
                    .padding(.top, 8)
                }
                .frame(height: geo.size.height * 0.55)

                // Divider + count
                HStack {
                    Text("附近餐廳")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text("\(viewModel.filteredMeals.count) 筆")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color(.systemBackground))

                // Restaurant list — always visible
                if viewModel.filteredMeals.isEmpty {
                    VStack(spacing: 8) {
                        Image("EmptyStateIllustration")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 80)
                        Text("一起去探索新餐廳吧")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
                } else {
                    List {
                        ForEach(viewModel.filteredMeals) { meal in
                            Button {
                                selectedMeal = meal
                            } label: {
                                MapMealRow(meal: meal)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .listStyle(.plain)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sensoryFeedback(.selection, trigger: selectedMeal?.id)
        .sensoryFeedback(.selection, trigger: viewModel.selectedCity)
        .sensoryFeedback(.selection, trigger: viewModel.selectedRating)
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

// MARK: - Restaurant Row
struct MapMealRow: View {
    let meal: Meal

    var body: some View {
        HStack(spacing: 12) {
            if let firstPhoto = meal.photoURLs.first, let url = URL(string: firstPhoto) {
                KFImage(url)
                    .placeholder { ProgressView() }
                    .fade(duration: 0.2)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.tertiarySystemFill))
                    .frame(width: 60, height: 60)
                    .overlay {
                        Image(systemName: "fork.knife")
                            .foregroundStyle(.tertiary)
                    }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(meal.displayTitle)
                    .font(.headline)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    RatingBadge(rating: meal.rating)
                    if let address = meal.address {
                        Text(address)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }

                if !meal.review.isEmpty {
                    Text(meal.review)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    FoodMapView()
}
