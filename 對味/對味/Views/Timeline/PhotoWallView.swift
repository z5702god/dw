import SwiftUI
import Kingfisher

struct PhotoWallView: View {
    private let mealRepo = MealRepository.shared

    @State private var allPhotos: [(url: String, title: String)] = []

    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            if allPhotos.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 48))
                        .foregroundStyle(.tertiary)
                    Text("還沒有照片")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 2) {
                        ForEach(allPhotos.indices, id: \.self) { index in
                            let photo = allPhotos[index]
                            if let url = URL(string: photo.url) {
                                KFImage(url)
                                    .placeholder { ProgressView() }
                                    .fade(duration: 0.2)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(minHeight: 120)
                                    .clipped()
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("照片牆")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            allPhotos = mealRepo.meals(filteredBy: nil).flatMap { meal in
                meal.photoURLs.map { (url: $0, title: meal.displayTitle) }
            }
        }
    }
}
