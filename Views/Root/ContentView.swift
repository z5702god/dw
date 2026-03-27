import SwiftUI

struct ContentView: View {
    @State private var authRepo = AuthRepository.shared

    var body: some View {
        Group {
            if authRepo.isSignedIn {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut, value: authRepo.isSignedIn)
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            Tab("日誌", systemImage: "book") {
                TimelineView()
            }

            Tab("地圖", systemImage: "map") {
                FoodMapView()
            }

            Tab("打卡", systemImage: "checkmark.circle") {
                CheckInView()
            }

            Tab("獎勵", systemImage: "gift") {
                RewardListView()
            }
        }
        .tint(.appPrimary)
    }
}

#Preview {
    ContentView()
}
