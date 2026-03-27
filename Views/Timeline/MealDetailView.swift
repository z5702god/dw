import SwiftUI
import Kingfisher

struct MealDetailView: View {
    let meal: Meal

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Photos
                if !meal.photoURLs.isEmpty {
                    TabView {
                        ForEach(meal.photoURLs, id: \.self) { urlString in
                            if let url = URL(string: urlString) {
                                KFImage(url)
                                    .resizable()
                                    .scaledToFill()
                                    .clipped()
                            }
                        }
                    }
                    .tabViewStyle(.page)
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Restaurant Info
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(meal.restaurantName)
                            .font(.title2)
                            .fontWeight(.bold)

                        Spacer()

                        RatingBadge(rating: meal.rating)
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "mappin")
                            .font(.caption)
                        Text(meal.city.displayName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        if let date = meal.createdAt {
                            Text("·")
                                .foregroundStyle(.secondary)
                            Text(date.formatted(.dateTime.year().month().day()))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Divider()

                // Review
                Text(meal.review)
                    .font(.body)
                    .lineSpacing(4)
            }
            .padding()
        }
        .navigationTitle("詳細")
        .navigationBarTitleDisplayMode(.inline)
    }
}
