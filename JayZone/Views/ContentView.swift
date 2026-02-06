import SwiftUI

struct ContentView: View {
    @StateObject private var healthKitManager = HealthKitManager()
    @StateObject private var goalStore = GoalStore()

    var body: some View {
        TabView {
            DashboardView(
                viewModel: DashboardViewModel(
                    healthKitManager: healthKitManager,
                    goalStore: goalStore
                )
            )
            .tabItem {
                Label("Dashboard", systemImage: "heart.text.square")
            }

            GoalsView(goalStore: goalStore)
                .tabItem {
                    Label("Goals", systemImage: "target")
                }

            ZoneSettingsView(goalStore: goalStore)
                .tabItem {
                    Label("Zones", systemImage: "slider.horizontal.3")
                }
        }
        .onAppear {
            healthKitManager.requestAuthorization()
        }
    }
}
