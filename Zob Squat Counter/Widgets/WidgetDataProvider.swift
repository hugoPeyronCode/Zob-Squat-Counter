//
//  WidgetDataProvider.swift
//  Zob Squat Counter
//
//  Created on 18/04/2025.
//

import Foundation
import SwiftData
import WidgetKit

// This file should be shared between the main app and widget extension

class WidgetDataProvider {
    static let shared = WidgetDataProvider()

    // MARK: - App Group Configuration
    private let appGroupIdentifier = "group.com.cortex.squatCounter"
    private let sharedUserDefaults: UserDefaults

    // File paths for data storage
    private var squatDataURL: URL {
        getAppGroupContainer().appendingPathComponent("squat_data.json")
    }

    private var statsDataURL: URL {
        getAppGroupContainer().appendingPathComponent("stats_data.json")
    }

    private init() {
        // Initialize shared UserDefaults
        sharedUserDefaults = UserDefaults(suiteName: appGroupIdentifier) ?? UserDefaults.standard
    }

    // MARK: - App Group Access

    private func getAppGroupContainer() -> URL {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) ?? FileManager.default.temporaryDirectory
    }

    // MARK: - Data Sharing Methods

    // Called from the main app to update widget data
    func updateWidgetData(squatDays: [SquatDay], stats: UserStats) {
        // Save today's data
        let todayData = createDailySquatData(from: squatDays.first(where: { Calendar.current.isDateInToday($0.date) }))
        sharedUserDefaults.setValue(todayData.count, forKey: "today_count")
        sharedUserDefaults.setValue(todayData.goal, forKey: "today_goal")

        // Save weekly data
        let weeklyData = createWeeklyData(from: squatDays)
        if let encodedData = try? JSONEncoder().encode(weeklyData) {
            try? encodedData.write(to: squatDataURL)
        }

        // Save stats data
        let statsData = SquatStats(
            bestStreak: stats.bestStreak,
            currentStreak: stats.currentStreak,
            totalSquats: stats.totalSquats
        )

        if let encodedStats = try? JSONEncoder().encode(statsData) {
            try? encodedStats.write(to: statsDataURL)
        }

        // Request widget refresh
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - Data Retrieval Methods (Used by Widget)

    func fetchTodayData() -> DailySquatData {
        let count = sharedUserDefaults.integer(forKey: "today_count")
        let goal = sharedUserDefaults.integer(forKey: "today_goal")

        // Default goal is 30 if not set
        return DailySquatData(
            date: Date(),
            count: count,
            goal: goal > 0 ? goal : 30
        )
    }

    func fetchWeeklyData() -> [DailySquatData] {
        // Try to read from file
        do {
            let data = try Data(contentsOf: squatDataURL)
            return try JSONDecoder().decode([DailySquatData].self, from: data)
        } catch {
            // If file doesn't exist or decoding fails, return empty array
            return createEmptyWeekData()
        }
    }

    func fetchStats() -> SquatStats {
        do {
            let data = try Data(contentsOf: statsDataURL)
            return try JSONDecoder().decode(SquatStats.self, from: data)
        } catch {
            // Return empty stats if file doesn't exist
            return SquatStats(bestStreak: 0, currentStreak: 0, totalSquats: 0)
        }
    }

    // MARK: - Helper Methods

    private func createDailySquatData(from squatDay: SquatDay?) -> DailySquatData {
        let dailyGoal = sharedUserDefaults.integer(forKey: "dailyGoal")
        let goal = dailyGoal > 0 ? dailyGoal : 30

        guard let day = squatDay else {
            return DailySquatData(date: Date(), count: 0, goal: goal)
        }

        return DailySquatData(
            date: day.date,
            count: day.count,
            goal: goal
        )
    }

    private func createWeeklyData(from squatDays: [SquatDay]) -> [DailySquatData] {
        let calendar = Calendar.current
        let dailyGoal = sharedUserDefaults.integer(forKey: "dailyGoal")
        let goal = dailyGoal > 0 ? dailyGoal : 30

        // Create array for the past week
        var weekData: [DailySquatData] = []

        // Get dates for the past 7 days
        for dayOffset in -6...0 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: Date()) else { continue }
            let startOfDay = calendar.startOfDay(for: date)

            // Find the corresponding squat day if it exists
            if let squatDay = squatDays.first(where: { calendar.isDate($0.date, inSameDayAs: startOfDay) }) {
                weekData.append(DailySquatData(
                    date: startOfDay,
                    count: squatDay.count,
                    goal: goal
                ))
            } else {
                // Add empty data for days with no records
                weekData.append(DailySquatData(
                    date: startOfDay,
                    count: 0,
                    goal: goal
                ))
            }
        }

        return weekData
    }

    private func createEmptyWeekData() -> [DailySquatData] {
        let calendar = Calendar.current
        let dailyGoal = sharedUserDefaults.integer(forKey: "dailyGoal")
        let goal = dailyGoal > 0 ? dailyGoal : 30

        // Create empty data for the past week
        var weekData: [DailySquatData] = []

        for dayOffset in -6...0 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: Date()) else { continue }
            let startOfDay = calendar.startOfDay(for: date)

            weekData.append(DailySquatData(
                date: startOfDay,
                count: 0,
                goal: goal
            ))
        }

        return weekData
    }
}
