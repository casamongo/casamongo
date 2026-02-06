import SwiftUI

struct ContentView: View {
    @StateObject private var healthKitManager: HealthKitManager
    @StateObject private var goalStore: GoalStore
    @StateObject private var dashboardViewModel: DashboardViewModel

    init() {
        let hkm = HealthKitManager()
        let gs = GoalStore()
        _healthKitManager = StateObject(wrappedValue: hkm)
        _goalStore = StateObject(wrappedValue: gs)
        _dashboardViewModel = StateObject(wrappedValue: DashboardViewModel(healthKitManager: hkm, goalStore: gs))
    }

    var body: some View {
        TabView {
            DashboardView(viewModel: dashboardViewModel)
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
