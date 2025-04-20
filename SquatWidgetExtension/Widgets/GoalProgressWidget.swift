//
//  GoalProgressWidget.swift
//  SquatWidgetExtensionExtension
//
//  Created by Hugo Peyron on 20/04/2025.
//

import WidgetKit
import SwiftUI

struct GoalProgressWidget: Widget {
  let kind: String = "GoalProgressWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: SquatTimelineProvider()) { entry in
      GoalProgressWidgetView(entry: entry)
        .fontDesign(.monospaced)
        .containerBackground(.fill.tertiary, for: .widget)
    }
    .configurationDisplayName("Goal Progress")
    .description("Focus on today's goal progress.")
    .supportedFamilies([.systemSmall])
  }
}

struct GoalProgressWidgetView: View {
  var entry: SquatEntry

  // Calculate percentage text
  private var percentageText: String {
    return "\(Int(entry.progressPercentage * 100))%"
  }

  var body: some View {
    GeometryReader { geometry in
      VStack {
        Spacer()
        // Progress gauge
        ZStack(alignment: .leading) {
          // Background bar
          RoundedRectangle(cornerRadius: 4)
            .fill(Color.gray.opacity(0.2))
            .frame(height: 3)

          // Progress bar
          RoundedRectangle(cornerRadius: 4)
            .fill(entry.goalReached ? .green : .primary)
            .frame(width: max(4, geometry.size.width * CGFloat(entry.progressPercentage)), height: 8)
        }
        .padding(.horizontal, 20)

        // Counter text
        HStack(spacing: 4) {
          Text("\(entry.todaySquats)")
            .font(.system(size: 22, weight: .bold))
            .foregroundStyle(.primary)

          Text("of")
            .font(.caption)
            .foregroundStyle(.secondary)

          Text("\(entry.dailyGoal)")
            .font(.system(size: 22, weight: .bold))
            .foregroundStyle(.secondary)
        }

        Spacer()

      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .padding(10)
    }
    .widgetURL(URL(string: "zobbsquat://home"))
  }

  // Format date as "Today" or the weekday
  private func formatDate(_ date: Date) -> String {
    if Calendar.current.isDateInToday(date) {
      return "Today"
    } else {
      let formatter = DateFormatter()
      formatter.dateFormat = "EEEE"
      return formatter.string(from: date)
    }
  }
}

#Preview(as: .systemSmall) {
  GoalProgressWidget()
} timeline: {
  SquatEntry.sampleEntry(widgetFamily: .systemSmall)
}
