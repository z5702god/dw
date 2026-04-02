import SwiftUI

struct ConfessionView: View {
    private let confessionRepo = ConfessionRepository.shared
    private let authRepo = AuthRepository.shared

    @State private var isConfessing = false
    @State private var showConfirm = false
    @State private var selectedCategory: ConfessionCategory?

    var body: some View {
        List {
            // MARK: - 告解按鈕
            Section {
                VStack(spacing: 12) {
                    Text("今天偷吃了什麼？")
                        .font(.headline)

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(ConfessionCategory.allCases, id: \.self) { category in
                            Button {
                                selectedCategory = category
                                showConfirm = true
                            } label: {
                                VStack(spacing: 6) {
                                    Image(systemName: category.icon)
                                        .font(.system(size: 32))
                                        .symbolRenderingMode(.hierarchical)
                                        .foregroundStyle(.appPrimary)
                                        .symbolEffect(.bounce, value: isConfessing)
                                    Text(category.displayName)
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(.primary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(.tertiarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .disabled(isConfessing)
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            } header: {
                Text("嘴饞告解")
            }

            // MARK: - 待回應的告解
            if !confessionRepo.pendingForMe.isEmpty {
                Section {
                    ForEach(confessionRepo.pendingForMe) { confession in
                        ConfessionResponseRow(confession: confession)
                    }
                } header: {
                    Text("\(authRepo.partnerName) 的告解")
                }
            }

            // MARK: - 本月統計
            Section {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundStyle(.appPrimary)
                    Text("本月告解")
                    Spacer()
                    Text("\(confessionRepo.monthlyCount) 次")
                        .font(.headline)
                        .foregroundStyle(.appPrimary)
                }
            }

            // MARK: - 歷史紀錄
            if !confessionRepo.confessions.isEmpty {
                Section {
                    ForEach(confessionRepo.confessions.prefix(20)) { confession in
                        ConfessionHistoryRow(confession: confession)
                    }
                } header: {
                    Text("告解紀錄")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("嘴饞告解室")
        .navigationBarTitleDisplayMode(.inline)
        .alert("確定要告解嗎？", isPresented: $showConfirm) {
            Button("告解 \(selectedCategory?.displayName ?? "")") {
                guard let category = selectedCategory else { return }
                Task {
                    isConfessing = true
                    try? await confessionRepo.confess(category: category)
                    isConfessing = false
                    selectedCategory = nil
                }
            }
            Button("取消", role: .cancel) {
                selectedCategory = nil
            }
        } message: {
            if let category = selectedCategory {
                Text("你確定要告解偷吃了「\(category.displayName)」嗎？")
            }
        }
        .sensoryFeedback(.success, trigger: confessionRepo.confessions.count)
    }
}

// MARK: - 回應列

private struct ConfessionResponseRow: View {
    let confession: Confession
    @State private var isResponding = false

    private let confessionRepo = ConfessionRepository.shared
    private let authRepo = AuthRepository.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: confession.category.icon)
                        .foregroundStyle(.appPrimary)
                    Text("\(authRepo.partnerName) 偷吃了\(confession.category.displayName)")
                }
                    .font(.subheadline)
                Spacer()
                if let date = confession.createdAt {
                    Text(date.formatted(.dateTime.hour().minute()))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 12) {
                Button {
                    respond("forgive")
                } label: {
                    Label("原諒", systemImage: "face.smiling")
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.green.opacity(0.15))
                        .foregroundStyle(.green)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .disabled(isResponding)

                Button {
                    respond("wantSome")
                } label: {
                    Label("我也要吃", systemImage: "mouth.fill")
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.orange.opacity(0.15))
                        .foregroundStyle(.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .disabled(isResponding)
            }
        }
        .padding(.vertical, 4)
    }

    private func respond(_ response: String) {
        guard let id = confession.id else { return }
        isResponding = true
        Task {
            try? await confessionRepo.respond(id: id, response: response)
            isResponding = false
        }
    }
}

// MARK: - 歷史列

private struct ConfessionHistoryRow: View {
    let confession: Confession
    private let authRepo = AuthRepository.shared

    private var isMyConfession: Bool {
        confession.confessedBy == authRepo.currentUserId
    }

    var body: some View {
        HStack {
            Image(systemName: confession.category.icon)
                .font(.title3)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.appPrimary)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(isMyConfession ? "我" : authRepo.partnerName)偷吃了\(confession.category.displayName)")
                    .font(.subheadline)

                if let date = confession.createdAt {
                    Text(date.formatted(.dateTime.month().day().hour().minute()))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if let response = confession.response {
                Image(systemName: response == "forgive" ? "face.smiling" : "mouth.fill")
                    .font(.title3)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(response == "forgive" ? .green : .orange)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ConfessionView()
    }
}
