// SquatModels.swift
// Zob Squat Counter
//
// Created on 18/04/2025

import Foundation
import SwiftData

@Model
final class SquatDay {
    var id: UUID
    var date: Date
    var count: Int

    init(id: UUID = UUID(), date: Date = Date(), count: Int = 0) {
        self.id = id
        self.date = Calendar.current.startOfDay(for: date)
        self.count = count
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    var dayStart: Date {
        Calendar.current.startOfDay(for: date)
    }
}

@Model
final class UserStats {
    var id: UUID
    var bestStreak: Int
    var currentStreak: Int
    var totalSquats: Int
    var lastUpdated: Date

    init(id: UUID = UUID(), bestStreak: Int = 0, currentStreak: Int = 0, totalSquats: Int = 0, lastUpdated: Date = Date()) {
        self.id = id
        self.bestStreak = bestStreak
        self.currentStreak = currentStreak
        self.totalSquats = totalSquats
        self.lastUpdated = lastUpdated
    }
}

// MARK: - Helpers for SwiftData Queries and Statistics

struct SquatDataManager {
    static func fetchTodaySquats(context: ModelContext) -> SquatDay {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Create the day range for today (start of day to start of next day)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

        // Simple predicate checking if date is within today's range
        let predicate = #Predicate<SquatDay> { squatDay in
            squatDay.date >= today && squatDay.date < tomorrow
        }

        let descriptor = FetchDescriptor<SquatDay>(predicate: predicate)

        do {
            let results = try context.fetch(descriptor)
            if let todayRecord = results.first {
                return todayRecord
            } else {
                // Create new record for today
                let newDay = SquatDay(date: today)
                context.insert(newDay)
                return newDay
            }
        } catch {
            print("Error fetching today's squats: \(error)")
            // Create a new record if fetch fails
            let newDay = SquatDay(date: today)
            context.insert(newDay)
            return newDay
        }
    }

    static func fetchSquatDays(context: ModelContext, startDate: Date, endDate: Date) -> [SquatDay] {
        let startDay = Calendar.current.startOfDay(for: startDate)
        let endDay = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: endDate))!

        let predicate = #Predicate<SquatDay> { squatDay in
            squatDay.date >= startDay && squatDay.date < endDay
        }

        let descriptor = FetchDescriptor<SquatDay>(predicate: predicate, sortBy: [SortDescriptor(\.date)])

        do {
            return try context.fetch(descriptor)
        } catch {
            print("Error fetching squat days: \(error)")
            return []
        }
    }

    static func fetchOrCreateStats(context: ModelContext) -> UserStats {
        let descriptor = FetchDescriptor<UserStats>()

        do {
            let results = try context.fetch(descriptor)
            if let stats = results.first {
                return stats
            } else {
                // Create new stats object if none exists
                let newStats = UserStats()
                context.insert(newStats)
                return newStats
            }
        } catch {
            print("Error fetching stats: \(error)")
            // Create a new stats object if fetch fails
            let newStats = UserStats()
            context.insert(newStats)
            return newStats
        }
    }

    static func updateStats(context: ModelContext, withNewSquatCount squatCount: Int, previousCount: Int) {
        let stats = fetchOrCreateStats(context: context)

        // Update total squats
        let squatDifference = squatCount - previousCount
        stats.totalSquats += squatDifference

        // Update streaks
        updateStreaks(context: context, stats: stats)

        stats.lastUpdated = Date()
    }

    static func updateStreaks(context: ModelContext, stats: UserStats) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Get the last 60 days of data for streak calculation
        let sixtyDaysAgo = calendar.date(byAdding: .day, value: -60, to: today)!
        let squatDays = fetchSquatDays(context: context, startDate: sixtyDaysAgo, endDate: today)

        // Get daily goal
        let dailyGoal = UserDefaults.standard.integer(forKey: "dailyGoal")
        if dailyGoal == 0 { return } // Skip if goal not set

        // Create a dictionary of days with squats
        // We'll use this approach instead of the Calendar.isDate method
        var squatsByDay: [Date: Int] = [:]
        for day in squatDays {
            squatsByDay[calendar.startOfDay(for: day.date)] = day.count
        }

        // Calculate current streak
        var currentStreak = 0
        var date = today

        while true {
            // Check if the day exists in our dictionary and if the goal was met
            if let count = squatsByDay[date], count >= dailyGoal {
                currentStreak += 1

                // Move to previous day
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: date) else {
                    break
                }
                date = previousDay
            } else {
                // Break streak if we miss a day or didn't reach the goal
                break
            }
        }

        // Update stats
        stats.currentStreak = currentStreak
        if currentStreak > stats.bestStreak {
            stats.bestStreak = currentStreak
        }
    }

    static func getAverageDailySquats(context: ModelContext) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: today)!

        let squatDays = fetchSquatDays(context: context, startDate: thirtyDaysAgo, endDate: today)

        if squatDays.isEmpty {
            return 0
        }

        let totalSquats = squatDays.reduce(0) { $0 + $1.count }
        return totalSquats / squatDays.count
    }

    // Helper to create sample data for previews
    static func createSampleData(context: ModelContext) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dailyGoal = UserDefaults.standard.integer(forKey: "dailyGoal")
        let effectiveGoal = dailyGoal > 0 ? dailyGoal : 30

        // Create 30 days of sample data
        for day in -30...0 {
            if let date = calendar.date(byAdding: .day, value: day, to: today) {
                let squatCount = Int.random(in: 0...(effectiveGoal + 15))
                let squatDay = SquatDay(date: date, count: squatCount)
                context.insert(squatDay)
            }
        }

        // Create stats
        let stats = UserStats(bestStreak: 14, currentStreak: 5, totalSquats: 1250)
        context.insert(stats)
    }
}
