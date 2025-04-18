// PreviewContainer.swift
// Zob Squat Counter
//
// Created on 18/04/2025.

import SwiftData
import SwiftUI

// MARK: - FOR PREVIEW ONLY -
@MainActor
class PreviewContainer {
    static let shared = PreviewContainer()

    let modelContainer: ModelContainer
    let context: ModelContext
    let todaySquats: SquatDay
    let userStats: UserStats

    private init() {
        // Create in-memory container
        let schema = Schema([
            SquatDay.self,
            UserStats.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            context = ModelContext(modelContainer)

            // Create sample data
            // Create today's squats
            let today = Calendar.current.startOfDay(for: Date())
            todaySquats = SquatDay(date: today, count: 15)
            context.insert(todaySquats)

            // Create user stats
            userStats = UserStats(
                bestStreak: 14,
                currentStreak: 5,
                totalSquats: 1250,
                lastUpdated: Date()
            )
            context.insert(userStats)

            // Create some history data (last 30 days)
            createHistoryData()

            try context.save()
        } catch {
            fatalError("Could not create preview container: \(error.localizedDescription)")
        }
    }

    private func createHistoryData() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dailyGoal = UserDefaults.standard.integer(forKey: "dailyGoal")
        let effectiveGoal = dailyGoal > 0 ? dailyGoal : 30

        // Create 30 days of sample data (skip today since we already created it)
        for day in -30...(-1) {
            if let date = calendar.date(byAdding: .day, value: day, to: today) {
                let squatCount = Int.random(in: 0...(effectiveGoal + 15))
                let squatDay = SquatDay(date: date, count: squatCount)
                context.insert(squatDay)
            }
        }
    }

    // Helper to create a preview wrapper
    func container<Content: View>(@ViewBuilder content: @escaping () -> Content) -> some View {
        content()
            .modelContainer(modelContainer)
    }
}

// Extension for easy use in previews
extension View {
    func previewWithData() -> some View {
        return PreviewContainer.shared.container {
            self
        }
    }
}

// Preview examples
#Preview("Home") {
    HomeView()
        .previewWithData()
}

#Preview("Calendar") {
    CalendarView()
        .previewWithData()
}

#Preview("Main Tab View") {
    MainTabView()
        .previewWithData()
}
