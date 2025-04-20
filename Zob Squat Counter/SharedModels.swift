//
//  SharedModels.swift
//  Zob Squat Counter
//
//  Created on 20/04/2025.
//

import Foundation
import SwiftUI

// MARK: - Widget Data Models
// These models need to be duplicated here because they're used by both the main app and the widget

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
