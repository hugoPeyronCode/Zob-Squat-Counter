//
//  SquatWidgetExtensionBundle.swift
//  SquatWidgetExtension
//
//  Created by Hugo Peyron on 18/04/2025.
//

import WidgetKit
import SwiftUI

@main
struct SquatWidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        // Original widgets
        SquatWidget()
//        SquatWidgetExtension()

        // New specialized widgets
        StreakWidget()
        StatsWidget()
        WeeklyChartWidget()
        GoalProgressWidget()
    }
}
