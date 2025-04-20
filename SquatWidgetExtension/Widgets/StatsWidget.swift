//
//  StatsWidget.swift
//  SquatWidgetExtensionExtension
//
//  Created by Hugo Peyron on 20/04/2025.
//

import WidgetKit
import SwiftUI

struct StatsWidget: Widget {
    let kind: String = "StatsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SquatTimelineProvider()) { entry in
            StatsWidgetView(entry: entry)
                .fontDesign(.monospaced)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Squat Stats")
        .description("View your comprehensive squat statistics.")
        .supportedFamilies([.systemMedium])
    }
}

struct StatsWidgetView: View {
    var entry: SquatEntry

    var body: some View {
        VStack(spacing: 8) {
            // Main stats grid - now in a 2×2 grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                // Total squats
                statGridItem(
                    value: "\(entry.stats.totalSquats)",
                    label: "TOTAL SQUATS"
                )

                // Today's progress
                statGridItem(
                    value: "\(entry.todaySquats)",
                    label: "TODAY",
                    progress: entry.progressPercentage,
                    isComplete: entry.goalReached
                )

                // Current streak
                statGridItem(
                    value: "\(entry.stats.currentStreak)",
                    label: "CURRENT STREAK",
                    secondaryText: "days"
                )

                // Best streak
                statGridItem(
                    value: "\(entry.stats.bestStreak)",
                    label: "BEST STREAK",
                    secondaryText: "days"
                )
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)

            Divider()
                .padding(.horizontal, 16)

            // Weekly mini chart
            HStack(alignment: .center) {
                Text("WEEKLY TREND")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .fontWeight(.medium)

                Spacer()

                // 7-day mini chart
                HStack(spacing: 4) {
                    ForEach(entry.weeklyData.suffix(7), id: \.date) { day in
                        miniDayBar(
                            height: 20,
                            percentage: day.percentage,
                            isComplete: day.goalReached,
                            isToday: day.isToday
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .widgetURL(URL(string: "zobbsquat://calendar"))
    }

    // Helper for stat grid items
    private func statGridItem(value: String, label: String, secondaryText: String? = nil, progress: Double? = nil, isComplete: Bool = false) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text(label)
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    if let secondaryText = secondaryText {
                        Text(secondaryText)
                            .font(.system(size: 8))
                            .foregroundStyle(.secondary)
                    }
                }

                // Optional progress bar
                if let progress = progress {
                    ZStack(alignment: .leading) {
                        // Background bar
                        Rectangle()
                            .fill(Color.primary.opacity(0.1))
                            .frame(height: 3)
                            .cornerRadius(1.5)

                        // Progress bar
                        Rectangle()
                            .fill(isComplete ? Color.primary : Color.primary.opacity(0.6))
                            .frame(width: max(3, progress * 100), height: 3)
                            .cornerRadius(1.5)
                    }
                    .frame(width: 100)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // Helper for mini day bars
    private func miniDayBar(height: CGFloat, percentage: Double, isComplete: Bool, isToday: Bool) -> some View {
        VStack(spacing: 2) {
            ZStack(alignment: .bottom) {
                // Background bar
                Rectangle()
                    .fill(Color.primary.opacity(0.1))
                    .frame(width: 4, height: height)
                    .cornerRadius(2)

                // Progress bar
                if percentage > 0 {
                    Rectangle()
                        .fill(Color.primary.opacity(isComplete ? 0.9 : 0.6))
                        .frame(width: 4, height: height * percentage)
                        .cornerRadius(2)
                }
            }

            // Day indicator dot for today
            if isToday {
                Circle()
                    .fill(Color.primary)
                    .frame(width: 3, height: 3)
            } else {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 3, height: 3)
            }
        }
    }
}

#Preview(as: .systemMedium) {
  StatsWidget()
} timeline: {
  SquatEntry.sampleEntry(widgetFamily: .systemMedium)
}
