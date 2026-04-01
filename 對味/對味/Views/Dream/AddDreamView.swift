import SwiftUI
import MapKit

struct AddDreamView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = DreamViewModel()

    var body: some View {
        NavigationStack {
            Form {
                // 餐廳名稱
                Section {
                    TextField("餐廳名稱", text: $viewModel.name)

                    if viewModel.selectedLocation == nil {
                        Button {
                            viewModel.searchQuery = viewModel.name
                            viewModel.enterSearchMode()
                        } label: {
                            Label("搜尋附近餐廳", systemImage: "magnifyingglass")
                        }
                        .disabled(viewModel.name.isEmpty)
                    }
                }

                // 搜尋結果
                if viewModel.isSearchMode {
                    Section("搜尋結果") {
                        TextField("搜尋餐廳...", text: $viewModel.searchQuery)
                            .onChange(of: viewModel.searchQuery) {
                                Task { await viewModel.performSearch() }
                            }

                        if viewModel.locationSearch.isSearching {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        }

                        ForEach(viewModel.locationSearch.results, id: \.self) { item in
                            Button {
                                viewModel.selectLocation(item)
                            } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.name ?? "未知地點")
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(.primary)
                                    if let address = item.placemark.title {
                                        Text(address)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }

                        if !viewModel.locationSearch.isSearching && viewModel.locationSearch.results.isEmpty && !viewModel.searchQuery.isEmpty {
                            Text("找不到結果")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // 已選地點
                if let location = viewModel.selectedLocation {
                    Section("已選地點") {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(location.name ?? "")
                                    .font(.subheadline.weight(.medium))
                                if let address = viewModel.address, !address.isEmpty {
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
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .navigationTitle("偷偷收藏")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("收藏") {
                        Task {
                            if await viewModel.saveItem() {
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.name.isEmpty || viewModel.isLoading)
                }
            }
        }
    }
}

#Preview {
    AddDreamView()
}
