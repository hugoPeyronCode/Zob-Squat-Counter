//
//  StreakWidget.swift
//  SquatWidgetExtensionExtension
//
//  Created by Hugo Peyron on 20/04/2025.
//

import WidgetKit
import SwiftUI

struct StreakWidget: Widget {
    let kind: String = "StreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SquatTimelineProvider()) { entry in
            StreakWidgetView(entry: entry)
                .fontDesign(.monospaced)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Squat Streak")
        .description("Track your current and best streak.")
        .supportedFamilies([.systemSmall])
    }
}

struct StreakWidgetView: View {
    var entry: SquatEntry

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 5) {
                Text("STREAK")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)

                Spacer()

                ZStack {
                    // Flame background
                    Image(systemName: "flame.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.orange.opacity(0.2))
                        .frame(width: min(geometry.size.width * 0.6, 100))

                    VStack(spacing: 5) {
                        Text("\(entry.stats.currentStreak)")
                            .font(.system(size: min(geometry.size.width * 0.3, 50), weight: .bold))
                            .foregroundStyle(.orange)

                        Text("days")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                VStack(spacing: 2) {
                    Text("Best: \(entry.stats.bestStreak) days")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 2) {
                        if entry.goalReached {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption2)
                                .foregroundStyle(.green)
                        } else {
                            Image(systemName: "circle")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        Text("Today")
                            .font(.caption2)
                            .foregroundStyle(entry.goalReached ? .green : .secondary)
                    }
                }
                .padding(.bottom, 4)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(10)
        }
        .widgetURL(URL(string: "zobbsquat://calendar"))
    }
}

#Preview(as: .systemSmall) {
  StreakWidget()
} timeline: {
  SquatEntry.sampleEntry(widgetFamily: .systemSmall)
}
