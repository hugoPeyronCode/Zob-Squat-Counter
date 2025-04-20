//
//  WeeklyChartWidget.swift
//  SquatWidgetExtensionExtension
//
//  Created by Hugo Peyron on 20/04/2025.
//

import WidgetKit
import SwiftUI

struct WeeklyChartWidget: Widget {
  let kind: String = "WeeklyChartWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: SquatTimelineProvider()) { entry in
      WeeklyChartWidgetView(entry: entry)
        .fontDesign(.monospaced)
        .containerBackground(.fill.tertiary, for: .widget)
    }
    .configurationDisplayName("Weekly Progress")
    .description("View your squat progress for the week.")
    .supportedFamilies([.systemMedium])
  }
}

struct WeeklyChartWidgetView: View {
  var entry: SquatEntry

  var body: some View {
    VStack(spacing: 8) {
      // Header
      HStack {
        Text("Weekly Progress")
          .font(.subheadline)
          .fontWeight(.semibold)

        Spacer()

        Text(entry.dateString)
          .font(.caption2)
          .foregroundStyle(.secondary)
      }
      .padding(.horizontal, 16)
      .padding(.top, 8)

      Spacer()

      // Weekly chart
      HStack(alignment: .bottom, spacing: 10) {
        ForEach(entry.weeklyData, id: \.date) { day in
          VStack(spacing: 4) {
            // Label showing count
            Text("\(day.count)")
              .font(.system(size: 10))
              .foregroundStyle(day.goalReached ? .green : .primary)
              .opacity(day.count > 0 ? 1 : 0) // Hide if zero

            // Bar
            ZStack(alignment: .bottom) {
              // Background bar
              RoundedRectangle(cornerRadius: 3)
                .fill(Color.gray.opacity(0.1))
                .frame(width: 20, height: 100)

              // Progress bar with min height of 4 if there's any progress
              if day.count > 0 {
                RoundedRectangle(cornerRadius: 3)
                  .fill(day.goalReached ? Color.green : Color.primary)
                  .frame(
                    width: 20,
                    height: max(4, 100 * day.percentage)
                  )
              }

              // Goal indicator line
              if !day.goalReached && day.count > 0 {
                Rectangle()
                  .fill(Color.pink)
                  .frame(width: 20, height: 2)
                  .offset(y: -100 + 100 * day.percentage)
              }
            }
            .frame(height: 100)

            // Day name
            Text(day.dayName.prefix(1))
              .font(.caption2)
              .foregroundStyle(day.isToday ? .primary : .secondary)
              .fontWeight(day.isToday ? .bold : .regular)

            // Bottom indicator for today
            if day.isToday {
              Circle()
                .fill(Color.primary)
                .frame(width: 4, height: 4)
            } else {
              Circle()
                .fill(Color.clear)
                .frame(width: 4, height: 4)
            }
          }
        }
      }
      .padding(.horizontal, 10)

      Spacer()

      // Footer with goal info
      HStack {
        RoundedRectangle(cornerRadius: 2)
          .fill(Color.gray.opacity(0.2))
          .frame(width: 14, height: 2)

        Text("Goal: \(entry.dailyGoal) squats")
          .font(.caption2)
          .foregroundStyle(.secondary)

        Spacer()

        Text("Avg: \(averageSquatsPerDay())/day")
          .font(.caption2)
          .foregroundStyle(.secondary)
      }
      .padding(.horizontal, 16)
      .padding(.bottom, 8)
    }
    .widgetURL(URL(string: "zobbsquat://calendar"))
  }

  // Calculate average squats per day for the week
  private func averageSquatsPerDay() -> Int {
    let nonZeroDays = entry.weeklyData.filter { $0.count > 0 }
    if nonZeroDays.isEmpty {
      return 0
    }

    let total = nonZeroDays.reduce(0) { $0 + $1.count }
    return total / nonZeroDays.count
  }
}

#Preview(as: .systemMedium) {
  WeeklyChartWidget()
} timeline: {
  SquatEntry.sampleEntry(widgetFamily: .systemMedium)
}
