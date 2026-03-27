import SwiftUI
import PhotosUI

struct MealFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = MealFormViewModel()

    var body: some View {
        NavigationStack {
            Form {
                // Restaurant Info
                Section("餐廳資訊") {
                    TextField("餐廳名稱", text: $viewModel.restaurantName)

                    Picker("城市", selection: $viewModel.city) {
                        ForEach(City.allCases, id: \.self) { city in
                            Text(city.displayName).tag(city)
                        }
                    }
                    .onChange(of: viewModel.city) {
                        viewModel.updateCityDefaults()
                    }
                }

                // Photos
                Section("照片") {
                    PhotosPicker(
                        selection: $viewModel.selectedPhotos,
                        maxSelectionCount: 5,
                        matching: .images
                    ) {
                        Label("選擇照片", systemImage: "photo.on.rectangle.angled")
                    }
                    .onChange(of: viewModel.selectedPhotos) {
                        Task { await viewModel.loadImages() }
                    }

                    if !viewModel.loadedImages.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(viewModel.loadedImages.indices, id: \.self) { index in
                                    Image(uiImage: viewModel.loadedImages[index])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                    }
                }

                // Rating
                Section("評價") {
                    Picker("推薦程度", selection: $viewModel.rating) {
                        ForEach(MealRating.allCases, id: \.self) { rating in
                            HStack {
                                Image(systemName: rating.icon)
                                Text(rating.displayName)
                            }
                            .tag(rating)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // Review
                Section("心得") {
                    TextEditor(text: $viewModel.review)
                        .frame(minHeight: 100)
                }

                // Error
                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("新增紀錄")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("儲存") {
                        Task {
                            if await viewModel.saveMeal() {
                                dismiss()
                            }
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(!viewModel.isValid || viewModel.isLoading)
                }
            }
            .overlay {
                if viewModel.isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    ProgressView("上傳中...")
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
}

#Preview {
    MealFormView()
}
