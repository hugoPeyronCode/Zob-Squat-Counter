//
//  Home.swift
//  Zob Squat Counter
//
//  Created by Hugo Peyron on 17/04/2025.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab = 0
    @Environment(\.modelContext) private var modelContext

    // Pre-initialize model context to ensure it's available
    @Query private var squatDays: [SquatDay]

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tag(0)
                .tabItem {
                    Label("Home", systemImage: "figure.cross.training")
                }

            CalendarView()
                .tag(1)
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }

            SettingsView()
                .tag(2)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .tint(.primary)
        .animation(.easeInOut, value: selectedTab)
        .onAppear {
            // Initialize data if needed (ensures SwiftData is working)
            ensureDataIsInitialized()
        }
    }

    private func ensureDataIsInitialized() {
        // This ensures the SwiftData stack is properly initialized
        // before any views try to access it
        _ = SquatDataManager.fetchOrCreateStats(context: modelContext)

        // Make sure today has an entry
        _ = SquatDataManager.fetchTodaySquats(context: modelContext)
    }
}

#Preview {
    MainTabView()
}
