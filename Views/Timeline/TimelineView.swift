import SwiftUI

struct TimelineView: View {
    @State private var viewModel = TimelineViewModel()
    @State private var showingAddMeal = false

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

                // Meal list — iOS inset grouped style
                if viewModel.filteredMeals.isEmpty {
                    ContentUnavailableView(
                        "還沒有紀錄",
                        systemImage: "fork.knife",
                        description: Text("點擊 + 開始記錄你們的美食旅程")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(viewModel.filteredMeals) { meal in
                                NavigationLink(destination: MealDetailView(meal: meal)) {
                                    MealCardView(meal: meal)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    }
                }
            }
            .background(.appBackground)
            .navigationTitle("飲食日誌")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddMeal = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .tint(.appPrimary)
                }
            }
            .sheet(isPresented: $showingAddMeal) {
                MealFormView()
            }
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
                .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? Color.appPrimary : Color(hex: "E5E5EA"))
                .foregroundStyle(isSelected ? .white : Color(hex: "3C3C43"))
                .clipShape(Capsule())
        }
    }
}

#Preview {
    TimelineView()
}
