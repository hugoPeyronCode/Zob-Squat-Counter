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

// MARK: - Models
struct UserGoal {
    var dailyTarget: Int
    var currentCount: Int

    var progressPercentage: Double {
        guard dailyTarget > 0 else { return 0 }
        return min(Double(currentCount) / Double(dailyTarget), 1.0)
    }

    var isGoalReached: Bool {
        return currentCount >= dailyTarget
    }
}



// MARK: - Settings View


// MARK: - Date Extensions
extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    func isInSameMonth(as date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.component(.month, from: self) == calendar.component(.month, from: date) &&
               calendar.component(.year, from: self) == calendar.component(.year, from: date)
    }

    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }

    func isSameDay(as date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, inSameDayAs: date)
    }
}

// MARK: - Preview
#Preview {
    MainTabView()
}
