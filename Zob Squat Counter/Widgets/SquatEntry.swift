//
//  SquatEntry.swift
//  SquatWidgetExtension
//
//  Created on 18/04/2025.
//

import WidgetKit
import SwiftUI

// Model structures for widget data
struct DailySquatData: Hashable, Codable {
    let date: Date
    let count: Int
    let goal: Int

    var percentage: Double {
        guard goal > 0 else { return 0 }
        return min(Double(count) / Double(goal), 1.0)
    }

    var goalReached: Bool {
        return count >= goal
    }

    var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }

    var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    var isToday: Bool {
        return Calendar.current.isDateInToday(date)
    }
}

struct SquatStats: Hashable, Codable {
    let bestStreak: Int
    let currentStreak: Int
    let totalSquats: Int
}

// Widget entry with all required data
struct SquatEntry: TimelineEntry {
    let date: Date
    let todaySquats: Int
    let dailyGoal: Int
    let weeklyData: [DailySquatData]
    let stats: SquatStats
    let widgetFamily: WidgetFamily

    // Progress percentage calculation
    var progressPercentage: Double {
        guard dailyGoal > 0 else { return 0 }
        return min(Double(todaySquats) / Double(dailyGoal), 1.0)
    }

    // Goal reached status
    var goalReached: Bool {
        return todaySquats >= dailyGoal
    }

    // String representation of date
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    // Create sample data for previews
    static func sampleEntry(widgetFamily: WidgetFamily) -> SquatEntry {
        let calendar = Calendar.current
        let today = Date()

        // Sample weekly data for medium and large widgets
        var weeklyData: [DailySquatData] = []
        if widgetFamily != .systemSmall {
            for dayOffset in -6...0 {
                guard let date = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }

                let goal = 30
                let isToday = dayOffset == 0
                let count = isToday ? 15 : Int.random(in: 0...(goal + 10))

                weeklyData.append(DailySquatData(
                    date: date,
                    count: count,
                    goal: goal
                ))
            }
        }

        // Sample stats for large widget
        let stats = SquatStats(
            bestStreak: 12,
            currentStreak: 5,
            totalSquats: 1245
        )

        return SquatEntry(
            date: today,
            todaySquats: 15,
            dailyGoal: 30,
            weeklyData: weeklyData,
            stats: stats,
            widgetFamily: widgetFamily
        )
    }
}
