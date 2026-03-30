import SwiftUI
import Kingfisher

struct MealDetailView: View {
    let meal: Meal
    @State private var partnerReviewText = ""
    @State private var isSubmitting = false
    @State private var submitted = false

    private let mealRepo = MealRepository.shared
    private let authRepo = AuthRepository.shared

    private var isOwnMeal: Bool { meal.userId == authRepo.currentUserId }

    var body: some View {
        List {
            // Photos
            Section {
                if !meal.photoURLs.isEmpty {
                    TabView {
                        ForEach(meal.photoURLs, id: \.self) { urlString in
                            if let url = URL(string: urlString) {
                                KFImage(url)
                                    .placeholder { ProgressView() }
                                    .fade(duration: 0.2)
                                    .resizable()
                                    .scaledToFill()
                                    .clipped()
                            }
                        }
                    }
                    .tabViewStyle(.page)
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .transition(.opacity)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                } else {
                    // Photo placeholder
                    VStack(spacing: 12) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 36))
                            .foregroundStyle(.tertiary)
                        Text("還沒有照片")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }

            // Title + Rating + Metadata
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(meal.displayTitle)
                            .font(.title2)
                            .fontWeight(.bold)

                        Spacer()

                        RatingBadge(rating: meal.rating)
                    }

                    // Metadata row
                    HStack(spacing: 4) {
                        // Mood
                        if let mood = meal.mood {
                            Text(mood.emoji + " " + mood.displayName)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .accessibilityLabel(mood.displayName)
                            Text("·")
                                .foregroundStyle(.secondary)
                        }

                        // Meal slot
                        Image(systemName: meal.mealSlot.icon)
                            .font(.caption)
                        Text(meal.mealSlot.displayName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        // City (only if present)
                        if let city = meal.city {
                            Text("·")
                                .foregroundStyle(.secondary)
                            Image(systemName: "mappin")
                                .font(.caption)
                            Text(city.displayName)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        // Date
                        if let date = meal.createdAt {
                            Text("·")
                                .foregroundStyle(.secondary)
                            Text(date.formatted(.dateTime.year().month().day()))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            // Review
            Section("心得") {
                Text(meal.review)
                    .font(.body)
                    .lineSpacing(4)
            }

            // Partner review display
            if let partnerReview = meal.partnerReview, !partnerReview.isEmpty {
                Section(isOwnMeal ? "另一半的悄悄話 💌" : "我的悄悄話 💌") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(partnerReview)
                            .font(.body)
                            .lineSpacing(4)
                        if let reviewedAt = meal.partnerReviewedAt {
                            Text(reviewedAt.formatted(.dateTime.year().month().day()))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            // Show submitted review optimistically (only before server syncs back)
            if submitted && (meal.partnerReview == nil || meal.partnerReview?.isEmpty == true) {
                Section("我的悄悄話 💌") {
                    Text(partnerReviewText)
                        .font(.body)
                        .lineSpacing(4)
                }
            }

            // Add review input if this is partner's meal and no review yet
            if !isOwnMeal && !submitted && (meal.partnerReview == nil || meal.partnerReview?.isEmpty == true) {
                Section("留一句悄悄話給他 💕") {
                    HStack {
                        TextField("寫點什麼...", text: $partnerReviewText)
                        Button("送出") {
                            Task {
                                guard let id = meal.id else { return }
                                isSubmitting = true
                                try? await mealRepo.addPartnerReview(mealId: id, review: partnerReviewText)
                                isSubmitting = false
                                submitted = true
                            }
                        }
                        .disabled(partnerReviewText.isEmpty || isSubmitting)
                    }
                }
            }
        }
        .listRowSeparatorTint(Color(.separator))
        .listStyle(.insetGrouped)
        .navigationTitle("紀錄詳情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(
                    item: "\(meal.displayTitle) \(meal.rating.displayName)\n\(meal.review)\n\n— 來自對味 app",
                    subject: Text(meal.displayTitle),
                    message: Text(meal.review)
                )
            }
        }
    }
}
