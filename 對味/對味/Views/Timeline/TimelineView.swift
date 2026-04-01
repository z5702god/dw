import SwiftUI

struct TimelineView: View {
    @State private var viewModel = TimelineViewModel()
    @State private var showingAddMeal = false
    @State private var showingSettings = false
    @State private var showPhotoWall = false
    @State private var showLandmine = false
    @State private var showTasteTimeline = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(
                            title: "全部",
                            isSelected: viewModel.selectedRating == nil
                        ) {
                            viewModel.selectedRating = nil
                        }
                        ForEach(MealRating.allCases, id: \.self) { rating in
                            FilterChip(
                                title: rating.displayName,
                                isSelected: viewModel.selectedRating == rating
                            ) {
                                viewModel.selectedRating = rating
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                }
                .animation(.spring(duration: 0.3), value: viewModel.selectedRating)

                // Meal list
                if viewModel.filteredMeals.isEmpty {
                    VStack(spacing: 16) {
                        Image("EmptyStateIllustration")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)

                        Text("還沒有回味")
                            .font(.headline)
                        Text("點擊 + 記錄你們的第一餐")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
                } else {
                    List {
                        ForEach(viewModel.groupedMeals) { group in
                            Section(group.title) {
                                ForEach(group.meals) { meal in
                                    NavigationLink(destination: MealDetailView(meal: meal)) {
                                        MealCardView(meal: meal)
                                    }
                                    .buttonStyle(.plain)
                                    .listRowSeparatorTint(Color(.separator))
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        if meal.userId == AuthRepository.shared.currentUserId {
                                            Button(role: .destructive) {
                                                Task { await viewModel.deleteMeal(meal) }
                                            } label: {
                                                Label("刪除", systemImage: "trash")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .animation(.spring(duration: 0.3), value: viewModel.filteredMeals.count)
                }
            }
            .background(.appBackground)
            .navigationTitle("回味")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .tint(.appPrimary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        Button {
                            showLandmine = true
                        } label: {
                            Image(systemName: "exclamationmark.triangle.fill")
                        }
                        .tint(.ratingBad)

                        Button {
                            showTasteTimeline = true
                        } label: {
                            Image(systemName: "bookmark.fill")
                        }
                        .tint(.appPrimary)

                        Button {
                            showPhotoWall = true
                        } label: {
                            Image(systemName: "photo.on.rectangle")
                        }
                        .tint(.appPrimary)

                        Button {
                            showingAddMeal = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .tint(.appPrimary)
                    }
                }
            }
            .sheet(isPresented: $showingAddMeal) {
                MealFormView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showPhotoWall) {
                PhotoWallView()
            }
            .sheet(isPresented: $showLandmine) {
                LandmineView()
            }
            .sheet(isPresented: $showTasteTimeline) {
                TasteTimelineView()
            }
            .sensoryFeedback(.selection, trigger: viewModel.selectedRating)
        }
    }
}

// MARK: - Filter Chip (Apple HIG pill style)
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(isSelected ? .subheadline.weight(.semibold) : .subheadline.weight(.medium))
                .padding(.horizontal, 14)
                .frame(height: 32)
                .background(isSelected ? Color.appPrimary : Color(.quaternarySystemFill))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .frame(minHeight: 44)
        .contentShape(Rectangle())
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

#Preview {
    TimelineView()
}
