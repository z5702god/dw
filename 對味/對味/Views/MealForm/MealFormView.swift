import SwiftUI
import PhotosUI
import MapKit

struct MealFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = MealFormViewModel()
    @State private var showCelebration = false
    @State private var saveTrigger = false
    @State private var showMapPicker = false
    @State private var isAIGenerating = false

    var body: some View {
        NavigationStack {
            Form {
                // 搜尋餐廳或直接輸入
                Section {
                    if viewModel.hasLocation {
                        // 已選擇餐廳（搜尋或手動定位）
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(viewModel.name)
                                    .font(.headline)
                                if let address = viewModel.address {
                                    Text(address)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            Button {
                                viewModel.clearLocation()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } else {
                        // 輸入食物名稱或餐廳名
                        TextField("輸入食物或餐廳名稱", text: $viewModel.searchQuery)
                            .onChange(of: viewModel.searchQuery) {
                                if viewModel.isSearchMode {
                                    Task { await viewModel.performSearch() }
                                }
                            }

                        // 搜尋模式：顯示結果
                        if viewModel.isSearchMode {
                            if viewModel.locationSearch.isSearching {
                                HStack {
                                    ProgressView()
                                        .controlSize(.small)
                                    Text("搜尋中...")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            ForEach(viewModel.locationSearch.results, id: \.self) { item in
                                Button {
                                    viewModel.selectLocation(item)
                                } label: {
                                    HStack {
                                        Image(systemName: "mappin.circle.fill")
                                            .foregroundStyle(.appPrimary)
                                        VStack(alignment: .leading, spacing: 1) {
                                            Text(item.name ?? "")
                                                .font(.subheadline)
                                                .foregroundStyle(.primary)
                                            if let address = item.placemark.title {
                                                Text(address)
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                                    .lineLimit(1)
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // 搜尋模式：顯示「在地圖上選擇位置」
                        if viewModel.isSearchMode {
                            Button {
                                showMapPicker = true
                            } label: {
                                Label("在地圖上選擇位置", systemImage: "map")
                                    .font(.subheadline)
                                    .foregroundStyle(.appPrimary)
                            }
                        }

                        // 非搜尋模式 + 有輸入文字：顯示搜尋按鈕
                        if !viewModel.isSearchMode && !viewModel.searchQuery.isEmpty {
                            Button {
                                viewModel.enterSearchMode()
                            } label: {
                                Label("搜尋附近餐廳", systemImage: "magnifyingglass")
                                    .font(.subheadline)
                                    .foregroundStyle(.appPrimary)
                            }
                        }
                    }
                } header: {
                    Text("吃了什麼？")
                } footer: {
                    if !viewModel.hasLocation && viewModel.searchQuery.isEmpty {
                        Text("直接輸入記為在家用餐，想定位餐廳可點下方搜尋")
                    }
                }

                // 評價
                Section("好吃嗎？") {
                    Picker("評價", selection: $viewModel.rating) {
                        ForEach(MealRating.allCases, id: \.self) { rating in
                            Text(rating.displayName).tag(rating)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // 心情
                Section("今天的心情") {
                    HStack(spacing: 12) {
                        ForEach(MealMood.allCases, id: \.self) { mood in
                            Button {
                                if viewModel.mood == mood {
                                    viewModel.mood = nil
                                } else {
                                    viewModel.mood = mood
                                }
                            } label: {
                                VStack(spacing: 4) {
                                    Text(mood.emoji)
                                        .font(.title2)
                                    Text(mood.displayName)
                                        .font(.caption2)
                                        .foregroundStyle(viewModel.mood == mood ? .appPrimary : .secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(viewModel.mood == mood ? Color.appPrimary.opacity(0.1) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(mood.displayName)
                        }
                    }
                }

                // 照片
                Section {
                    PhotosPicker(
                        selection: $viewModel.selectedPhotos,
                        maxSelectionCount: 5,
                        matching: .images
                    ) {
                        Label("加照片", systemImage: "camera")
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
                                        .frame(width: 72, height: 72)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                    }
                }

                // 心得
                Section {
                    TextEditor(text: $viewModel.review)
                        .frame(minHeight: 80)
                        .overlay(alignment: .topLeading) {
                            if viewModel.review.isEmpty {
                                Text("心得（可選）")
                                    .foregroundStyle(.tertiary)
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                                    .allowsHitTesting(false)
                            }
                        }

                    if AIConfig.isAvailable {
                        Button {
                            Task {
                                isAIGenerating = true
                                let foodName = viewModel.name.isEmpty ? viewModel.searchQuery : viewModel.name
                                if let result = await AIService.shared.generateReview(
                                    name: foodName,
                                    rating: viewModel.rating,
                                    mood: viewModel.mood,
                                    mealPlace: viewModel.mealPlace
                                ) {
                                    viewModel.review = result
                                }
                                isAIGenerating = false
                            }
                        } label: {
                            HStack {
                                if isAIGenerating {
                                    ProgressView()
                                        .controlSize(.small)
                                    Text("AI 撰寫中...")
                                        .font(.subheadline)
                                } else {
                                    Image(systemName: "sparkles")
                                    Text("AI 幫我寫 ✨")
                                        .font(.subheadline)
                                }
                            }
                            .foregroundStyle(.appPrimary)
                        }
                        .disabled(isAIGenerating || (viewModel.name.isEmpty && viewModel.searchQuery.isEmpty))
                    }
                }

                if let error = viewModel.errorMessage {
                    Section {
                        Text(error).foregroundStyle(.red)
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("新增紀錄")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("儲存") {
                        Task {
                            // 如果還沒設名稱，用搜尋文字當名稱
                            if viewModel.name.isEmpty && !viewModel.searchQuery.isEmpty {
                                viewModel.name = viewModel.searchQuery
                            }
                            if await viewModel.saveMeal() {
                                saveTrigger.toggle()
                                if viewModel.pointEarned {
                                    showCelebration = true
                                } else {
                                    dismiss()
                                }
                            }
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(viewModel.name.isEmpty && viewModel.searchQuery.isEmpty || viewModel.isLoading)
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ZStack {
                        Color.clear.background(.ultraThinMaterial).ignoresSafeArea()
                        ProgressView { Text("儲存中...").font(.subheadline) }
                            .controlSize(.large)
                    }
                }
            }
            .sheet(isPresented: $showMapPicker) {
                MapPinPickerView { coordinate, address, city in
                    viewModel.selectManualLocation(coordinate: coordinate, address: address, city: city)
                }
            }
            .fullScreenCover(isPresented: $showCelebration, onDismiss: {
                dismiss()
            }) {
                CelebrationView()
            }
            .sensoryFeedback(.success, trigger: saveTrigger)
        }
    }
}

#Preview {
    MealFormView()
}
