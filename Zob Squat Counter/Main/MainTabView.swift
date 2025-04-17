//
//  Home.swift
//  Zob Squat Counter
//
//  Created by Hugo Peyron on 17/04/2025.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tag(0)
                .tabItem {
                    Label("Home", systemImage: "figure.walk")
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
    }
}

#Preview {
    MainTabView()
}
