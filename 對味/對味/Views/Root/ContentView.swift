import SwiftUI

struct ContentView: View {
    @State private var authRepo = AuthRepository.shared

    var body: some View {
        Group {
            if authRepo.isSignedIn {
                MainTabView()
                    .transition(.opacity)
            } else {
                LoginView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: authRepo.isSignedIn)
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var achievementVM = AchievementViewModel()
    @State private var migrationMessage: String?

    var body: some View {
        TabView(selection: $selectedTab) {
            TimelineView()
                .tabItem {
                    Label("回味", systemImage: "book.fill")
                }
                .tag(0)

            FoodMapView()
                .tabItem {
                    Label("地圖", systemImage: "map.fill")
                }
                .tag(1)

            RecordView()
                .tabItem {
                    Label("今日", systemImage: "calendar")
                }
                .tag(2)

            RewardListView()
                .tabItem {
                    Label("獎勵", systemImage: "gift.fill")
                }
                .tag(3)
        }
        .tint(.appPrimary)
        .sensoryFeedback(.selection, trigger: selectedTab)
        .task {
            // 成就系統遷移：首次啟動掃描現有資料
            let migrated = await achievementVM.runMigrationIfNeeded()
            if !migrated.isEmpty {
                migrationMessage = "恭喜！你已解鎖 \(migrated.count) 個成就！"
            }
        }
        .overlay(alignment: .top) {
            if let message = migrationMessage {
                Text(message)
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.appPrimary)
                    )
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        Task {
                            try? await Task.sleep(for: .seconds(3))
                            withAnimation { migrationMessage = nil }
                        }
                    }
            }
        }
        .animation(.spring, value: migrationMessage)
    }
}

#Preview {
    ContentView()
}
