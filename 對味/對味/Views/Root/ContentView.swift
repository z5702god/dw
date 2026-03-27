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
    }
}

#Preview {
    ContentView()
}
