import SwiftUI

struct DreamListView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var dreamRepo = DreamRepository.shared
    @State private var authRepo = AuthRepository.shared
    @State private var showAddDream = false
    @State private var itemToDelete: DreamRestaurant?

    private var myItems: [DreamRestaurant] {
        dreamRepo.myItems(userId: authRepo.currentUserId)
    }

    private var matched: [DreamRestaurant] {
        dreamRepo.matchedRestaurants
    }

    var body: some View {
        NavigationStack {
            List {
                // MARK: - 配對成功
                if !matched.isEmpty {
                    Section {
                        ForEach(matched) { item in
                            DreamMatchedRow(item: item)
                        }
                    } header: {
                        Label("配對成功 💕", systemImage: "heart.fill")
                            .foregroundStyle(.pink)
                            .font(.subheadline.weight(.semibold))
                    }
                }

                // MARK: - 我的祕密收藏
                Section {
                    if myItems.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "eye.slash")
                                .font(.title2)
                                .foregroundStyle(.secondary)
                            Text("偷偷收藏想去的餐廳")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text("對方看不到，配對成功才會揭曉")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    } else {
                        ForEach(myItems) { item in
                            DreamItemRow(item: item)
                                .swipeActions(edge: .trailing) {
                                    if item.id != nil {
                                        Button(role: .destructive) {
                                            itemToDelete = item
                                        } label: {
                                            Label("刪除", systemImage: "trash")
                                        }
                                    }
                                }
                        }
                    }
                } header: {
                    HStack {
                        Label("我的祕密收藏", systemImage: "eye.slash")
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Text("\(myItems.count) 間")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("夢幻餐廳")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("完成") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddDream = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddDream) {
                AddDreamView()
            }
            .alert("確定要刪除嗎？", isPresented: .init(
                get: { itemToDelete != nil },
                set: { if !$0 { itemToDelete = nil } }
            )) {
                Button("取消", role: .cancel) { itemToDelete = nil }
                Button("刪除", role: .destructive) {
                    if let id = itemToDelete?.id {
                        Task { try? await dreamRepo.deleteItem(id: id) }
                    }
                    itemToDelete = nil
                }
            }
        }
    }
}

// MARK: - 配對成功的 Row
private struct DreamMatchedRow: View {
    let item: DreamRestaurant

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.pink.opacity(0.15))
                .frame(width: 50, height: 50)
                .overlay {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.pink)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(1)
                if let address = item.address, !address.isEmpty {
                    Text(address)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Text("你們都想去！")
                    .font(.caption)
                    .foregroundStyle(.pink)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 我的收藏 Row
private struct DreamItemRow: View {
    let item: DreamRestaurant

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.purple.opacity(0.12))
                .frame(width: 50, height: 50)
                .overlay {
                    Image(systemName: "eye.slash.fill")
                        .foregroundStyle(.purple.opacity(0.7))
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(1)
                if let address = item.address, !address.isEmpty {
                    Text(address)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    DreamListView()
}
