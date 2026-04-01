import SwiftUI
import FirebaseFirestore

struct TasteProfileView: View {
    @State private var authRepo = AuthRepository.shared
    @State private var myProfile: TasteProfile = .empty
    @State private var partnerProfile: TasteProfile?
    @State private var isEditing = false
    @State private var isSaving = false

    // 編輯用的暫存欄位
    @State private var newDontEatItem = ""
    @State private var newAllergyItem = ""

    var body: some View {
        List {
            // MARK: - 對方的口味身分證
            if let partner = partnerProfile {
                Section {
                    TasteCardView(
                        profile: partner,
                        title: "\(authRepo.partnerName) 的口味"
                    )
                } header: {
                    Label("對方的口味身分證", systemImage: "person.fill")
                        .font(.subheadline.weight(.semibold))
                }
            } else {
                Section {
                    VStack(spacing: 8) {
                        Image(systemName: "person.crop.circle.badge.questionmark")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        Text("對方還沒填寫口味資料")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                } header: {
                    Label("對方的口味身分證", systemImage: "person.fill")
                        .font(.subheadline.weight(.semibold))
                }
            }

            // MARK: - 我的口味身分證
            Section {
                if isEditing {
                    editFormContent
                } else {
                    TasteCardView(
                        profile: myProfile,
                        title: "我的口味"
                    )

                    Button {
                        isEditing = true
                    } label: {
                        Label("編輯我的口味", systemImage: "pencil")
                    }
                }
            } header: {
                HStack {
                    Label("我的口味身分證", systemImage: "person.fill")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    if isEditing {
                        Button("取消") {
                            isEditing = false
                            loadMyProfile()
                        }
                        .font(.subheadline)
                    }
                }
            }
        }
        .navigationTitle("口味身分證")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadMyProfile()
            loadPartnerProfile()
        }
    }

    // MARK: - 編輯表單

    @ViewBuilder
    private var editFormContent: some View {
        // 🚫 不吃
        VStack(alignment: .leading, spacing: 6) {
            Text("🚫 不吃的食物")
                .font(.subheadline.weight(.medium))
            FlowTagsView(tags: $myProfile.dontEat)
            HStack {
                TextField("新增不吃的...", text: $newDontEatItem)
                    .textFieldStyle(.roundedBorder)
                Button("加入") {
                    let trimmed = newDontEatItem.trimmingCharacters(in: .whitespaces)
                    guard !trimmed.isEmpty else { return }
                    myProfile.dontEat.append(trimmed)
                    newDontEatItem = ""
                }
                .disabled(newDontEatItem.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }

        // ⚠️ 過敏
        VStack(alignment: .leading, spacing: 6) {
            Text("⚠️ 過敏原")
                .font(.subheadline.weight(.medium))
            FlowTagsView(tags: $myProfile.allergies)
            HStack {
                TextField("新增過敏原...", text: $newAllergyItem)
                    .textFieldStyle(.roundedBorder)
                Button("加入") {
                    let trimmed = newAllergyItem.trimmingCharacters(in: .whitespaces)
                    guard !trimmed.isEmpty else { return }
                    myProfile.allergies.append(trimmed)
                    newAllergyItem = ""
                }
                .disabled(newAllergyItem.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }

        // 🌶️ 辣度
        VStack(alignment: .leading, spacing: 6) {
            Text("🌶️ 辣度接受度")
                .font(.subheadline.weight(.medium))
            Picker("辣度", selection: $myProfile.spiceLevel) {
                ForEach(TasteProfile.spiceLevels, id: \.self) { level in
                    Text(level).tag(level)
                }
            }
            .pickerStyle(.segmented)
        }

        // ❤️ 最愛料理
        VStack(alignment: .leading, spacing: 6) {
            Text("❤️ 最愛料理")
                .font(.subheadline.weight(.medium))
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 8) {
                ForEach(TasteProfile.cuisineOptions, id: \.self) { cuisine in
                    let isSelected = myProfile.favoriteCuisines.contains(cuisine)
                    Button {
                        if isSelected {
                            myProfile.favoriteCuisines.removeAll { $0 == cuisine }
                        } else {
                            myProfile.favoriteCuisines.append(cuisine)
                        }
                    } label: {
                        Text(cuisine)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(isSelected ? Color.appPrimary.opacity(0.2) : Color(.tertiarySystemFill))
                            .foregroundStyle(isSelected ? .appPrimary : .primary)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }

        // ☕ 咖啡
        VStack(alignment: .leading, spacing: 6) {
            Text("☕ 咖啡喜好")
                .font(.subheadline.weight(.medium))
            TextField("例如：拿鐵、美式、不喝咖啡", text: Binding(
                get: { myProfile.coffeePreference ?? "" },
                set: { myProfile.coffeePreference = $0.isEmpty ? nil : $0 }
            ))
            .textFieldStyle(.roundedBorder)
        }

        // 🍰 甜點
        VStack(alignment: .leading, spacing: 6) {
            Text("🍰 甜點喜好")
                .font(.subheadline.weight(.medium))
            TextField("例如：巧克力、提拉米蘇", text: Binding(
                get: { myProfile.dessertPreference ?? "" },
                set: { myProfile.dessertPreference = $0.isEmpty ? nil : $0 }
            ))
            .textFieldStyle(.roundedBorder)
        }

        // 🥤 飲料
        VStack(alignment: .leading, spacing: 6) {
            Text("🥤 飲料喜好")
                .font(.subheadline.weight(.medium))
            TextField("例如：珍奶、綠茶、水果茶", text: Binding(
                get: { myProfile.drinkPreference ?? "" },
                set: { myProfile.drinkPreference = $0.isEmpty ? nil : $0 }
            ))
            .textFieldStyle(.roundedBorder)
        }

        // 📝 備註
        VStack(alignment: .leading, spacing: 6) {
            Text("📝 備註")
                .font(.subheadline.weight(.medium))
            TextField("其他飲食偏好...", text: Binding(
                get: { myProfile.notes ?? "" },
                set: { myProfile.notes = $0.isEmpty ? nil : $0 }
            ))
            .textFieldStyle(.roundedBorder)
        }

        // 儲存按鈕
        Button {
            Task { await saveProfile() }
        } label: {
            HStack {
                Spacer()
                if isSaving {
                    ProgressView()
                } else {
                    Text("儲存口味資料")
                        .font(.headline)
                }
                Spacer()
            }
        }
        .disabled(isSaving)
        .listRowBackground(Color.appPrimary.opacity(0.15))
    }

    // MARK: - Data

    private func loadMyProfile() {
        myProfile = authRepo.appUser?.tasteProfile ?? .empty
    }

    private func loadPartnerProfile() {
        partnerProfile = authRepo.partnerUser?.tasteProfile
    }

    private func saveProfile() async {
        guard let uid = authRepo.currentUserId else { return }
        isSaving = true
        do {
            let data = try Firestore.Encoder().encode(myProfile)
            try await FirebaseConfig.userDocument(uid).updateData(["tasteProfile": data])
            isEditing = false
            #if DEBUG
            print("[TasteProfileView] Saved taste profile")
            #endif
        } catch {
            #if DEBUG
            print("[TasteProfileView] Failed to save: \(error.localizedDescription)")
            #endif
        }
        isSaving = false
    }
}

// MARK: - 口味卡片顯示

private struct TasteCardView: View {
    let profile: TasteProfile
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            if !profile.dontEat.isEmpty {
                TagRow(icon: "🚫", label: "不吃", items: profile.dontEat, color: .red)
            }

            if !profile.allergies.isEmpty {
                TagRow(icon: "⚠️", label: "過敏", items: profile.allergies, color: .orange)
            }

            HStack(spacing: 4) {
                Text("🌶️")
                Text(profile.spiceLevel)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if !profile.favoriteCuisines.isEmpty {
                TagRow(icon: "❤️", label: "最愛", items: profile.favoriteCuisines, color: .pink)
            }

            if let coffee = profile.coffeePreference, !coffee.isEmpty {
                HStack(spacing: 4) {
                    Text("☕")
                    Text(coffee)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            if let dessert = profile.dessertPreference, !dessert.isEmpty {
                HStack(spacing: 4) {
                    Text("🍰")
                    Text(dessert)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            if let drink = profile.drinkPreference, !drink.isEmpty {
                HStack(spacing: 4) {
                    Text("🥤")
                    Text(drink)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            if let notes = profile.notes, !notes.isEmpty {
                HStack(spacing: 4) {
                    Text("📝")
                    Text(notes)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

private struct TagRow: View {
    let icon: String
    let label: String
    let items: [String]
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Text(icon)
                Text(label)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            FlowLayout(spacing: 6) {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(color.opacity(0.12))
                        .foregroundStyle(color)
                        .clipShape(Capsule())
                }
            }
        }
    }
}

// MARK: - Flow Layout (tags 自動換行)

private struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), positions)
    }
}

// MARK: - 可刪除的 Tag 列表

private struct FlowTagsView: View {
    @Binding var tags: [String]

    var body: some View {
        if !tags.isEmpty {
            FlowLayout(spacing: 6) {
                ForEach(tags, id: \.self) { tag in
                    HStack(spacing: 2) {
                        Text(tag)
                            .font(.caption)
                        Button {
                            tags.removeAll { $0 == tag }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption2)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.tertiarySystemFill))
                    .clipShape(Capsule())
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        TasteProfileView()
    }
}
