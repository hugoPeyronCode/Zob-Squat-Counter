//
//  MainAppWidgetIntegration.swift
//  Zob Squat Counter
//
//  Created on 18/04/2025.
//

import SwiftUI
import SwiftData
import WidgetKit

extension SquatDataManager {
    // Update widget data on relevant changes
    static func updateWidgetData(context: ModelContext) {
        // Only update if widget feature is enabled
        let isWidgetEnabled = UserDefaults.standard.bool(forKey: "isWidgetSubscriptionActive")
        guard isWidgetEnabled else { return }

        // Fetch necessary data for widgets
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: today)!

        // Get squat data for last 7 days
        let squatDays = fetchSquatDays(context: context, startDate: weekAgo, endDate: today)

        // Get current stats
        let stats = fetchOrCreateStats(context: context)

        // Update widget data via shared provider
        WidgetDataProvider.shared.updateWidgetData(squatDays: squatDays, stats: stats)
    }
}
