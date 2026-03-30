import SwiftUI
import Kingfisher

struct FoodMapView: View {
    @State private var viewModel = MapViewModel()
    @State private var selectedMeal: Meal?
    @State private var mapMode = 0 // 0=去過的, 1=想去的
    @State private var showAddWishlist = false
    @State private var wishlistRepo = WishlistRepository.shared
    @State private var authRepo = AuthRepository.shared
    @State private var wishlistToDelete: WishlistItem?

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

                // Mode picker
                Picker("模式", selection: $mapMode) {
                    Text("去過的").tag(0)
                    Text("想去的").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(Color(.systemBackground))

                if mapMode == 0 {
                    // MARK: - 去過的餐廳
                    mealListSection
                } else {
                    // MARK: - 想去清單
                    wishlistSection
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sensoryFeedback(.selection, trigger: selectedMeal?.id)
        .sensoryFeedback(.selection, trigger: viewModel.selectedCity)
        .sensoryFeedback(.selection, trigger: viewModel.selectedRating)
        .sensoryFeedback(.selection, trigger: mapMode)
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
        .sheet(isPresented: $showAddWishlist) {
            AddWishlistItemView()
        }
        .alert("確定要刪除嗎？", isPresented: .init(get: { wishlistToDelete != nil }, set: { if !$0 { wishlistToDelete = nil } })) {
            Button("取消", role: .cancel) {
                wishlistToDelete = nil
            }
            Button("刪除", role: .destructive) {
                if let id = wishlistToDelete?.id {
                    Task {
                        try? await wishlistRepo.deleteItem(id: id)
                    }
                }
                wishlistToDelete = nil
            }
        }
    }

    // MARK: - Meal List

    @ViewBuilder
    private var mealListSection: some View {
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

    // MARK: - Wishlist Section

    @ViewBuilder
    private var wishlistSection: some View {
        HStack {
            Text("想去清單")
                .font(.subheadline.weight(.semibold))
            Spacer()
            Text("\(wishlistRepo.pendingItems.count) 筆")
                .font(.caption)
                .foregroundStyle(.secondary)
            Button {
                showAddWishlist = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.wishlistGold)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))

        if wishlistRepo.pendingItems.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.wishlistGold.opacity(0.5))
                Text("還沒有想去的餐廳")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("點右上角 + 新增")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
        } else {
            List {
                ForEach(wishlistRepo.pendingItems) { item in
                    WishlistItemRow(item: item, authRepo: authRepo)
                        .swipeActions(edge: .trailing) {
                            if item.id != nil {
                                Button(role: .destructive) {
                                    wishlistToDelete = item
                                } label: {
                                    Label("刪除", systemImage: "trash")
                                }
                            }
                        }
                        .swipeActions(edge: .leading) {
                            if let id = item.id {
                                Button {
                                    Task {
                                        try? await wishlistRepo.markAsVisited(id: id, mealId: "")
                                    }
                                } label: {
                                    Label("去過了", systemImage: "checkmark.circle")
                                }
                                .tint(.green)
                            }
                        }
                }
            }
            .listStyle(.plain)
        }
    }
}

// MARK: - Wishlist Item Row
struct WishlistItemRow: View {
    let item: WishlistItem
    let authRepo: AuthRepository

    private var addedByName: String {
        if item.addedBy == authRepo.currentUserId {
            return authRepo.appUser?.displayName ?? "我"
        } else {
            return authRepo.partnerName
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.wishlistGold.opacity(0.15))
                .frame(width: 60, height: 60)
                .overlay {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.wishlistGold)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text(addedByName + " 加入")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let address = item.address, !address.isEmpty {
                        Text("  \(address)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
        }
        .padding(.vertical, 4)
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
