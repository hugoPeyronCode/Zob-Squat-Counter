//
//  SquatTimelineProvider.swift
//  SquatWidgetExtension
//
//  Created on 18/04/2025.
//

import WidgetKit
import SwiftUI

struct SquatTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> SquatEntry {
        SquatEntry.sampleEntry(widgetFamily: context.family)
    }

    func getSnapshot(in context: Context, completion: @escaping (SquatEntry) -> Void) {
        let entry = context.isPreview
            ? SquatEntry.sampleEntry(widgetFamily: context.family)
            : createEntry(family: context.family)

        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SquatEntry>) -> Void) {
        // Create the current entry
        let entry = createEntry(family: context.family)

        // Calculate relevant update times
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())

        // Key update times - morning, evening, and midnight
        components.hour = 0
        components.minute = 1
        let midnight = calendar.date(from: components) ?? Date().addingTimeInterval(86400)

        components.hour = 8
        components.minute = 0
        let morning = calendar.date(from: components) ?? Date().addingTimeInterval(3600)

        components.hour = 18
        components.minute = 0
        let evening = calendar.date(from: components) ?? Date().addingTimeInterval(3600)

        // Ensure all dates are in the future
        let now = Date()
        let updateTimes = [morning, evening, midnight].filter { $0 > now }

        // If no future times today, use tomorrow
        var nextUpdate: Date
        if let nextTime = updateTimes.min() {
            nextUpdate = nextTime
        } else {
            nextUpdate = calendar.date(byAdding: .day, value: 1, to: midnight) ?? Date().addingTimeInterval(86400)
        }

        // Create timeline with single entry and next refresh time
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    // Helper to create entry with real data
    private func createEntry(family: WidgetFamily) -> SquatEntry {
        let dataProvider = WidgetDataProvider.shared

        // Get today's data
        let todayData = dataProvider.fetchTodayData()

        // For medium and large widgets, get additional data
        var weeklyData: [DailySquatData] = []
        if family != .systemSmall {
            weeklyData = dataProvider.fetchWeeklyData()
        }

        // Get stats for large widget
        var stats = SquatStats(bestStreak: 0, currentStreak: 0, totalSquats: 0)
        if family == .systemLarge {
            stats = dataProvider.fetchStats()
        }

        return SquatEntry(
            date: Date(),
            todaySquats: todayData.count,
            dailyGoal: todayData.goal,
            weeklyData: weeklyData,
            stats: stats,
            widgetFamily: family
        )
    }
}
