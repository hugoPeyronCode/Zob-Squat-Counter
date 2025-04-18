//
//  SquatWidgetView.swift
//  SquatWidgetExtension
//
//  Created on 18/04/2025.
//

import WidgetKit
import SwiftUI

struct SquatWidgetView: View {
    var entry: SquatTimelineProvider.Entry

    var body: some View {
        switch entry.widgetFamily {
        case .systemSmall:
            SmallSquatWidget(entry: entry)
        case .systemMedium:
            MediumSquatWidget(entry: entry)
        case .systemLarge:
            LargeSquatWidget(entry: entry)
        @unknown default:
            SmallSquatWidget(entry: entry)
        }
    }
}

// MARK: - Small Widget Layout

struct SmallSquatWidget: View {
    var entry: SquatEntry

    var body: some View {
        VStack {
            // Header with date
            Text(entry.dateString)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.top, 2)

            Spacer()

            // Progress circle
            ZStack {
                // Background circle
                Circle()
                    .stroke(
                        Color.gray.opacity(0.2),
                        lineWidth: 4
                    )

                // Progress arc
                Circle()
                    .trim(from: 0, to: CGFloat(entry.progressPercentage))
                    .stroke(
                        entry.goalReached ? Color.green : Color.primary,
                        style: StrokeStyle(
                            lineWidth: 4,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))

                // Counter text
                VStack(spacing: 0) {
                    Text("\(entry.todaySquats)")
                        .font(.system(size: 34, weight: .bold))

                    Text("of \(entry.dailyGoal)")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(15)

            Spacer()

            // Streak indicator if available
            if entry.stats.currentStreak > 0 {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)

                    Text("\(entry.stats.currentStreak)")
                        .font(.caption)
                        .bold()
                }
                .padding(.bottom, 6)
            }
        }
        .padding(8)
        .widgetURL(URL(string: "zobbsquat://home"))
    }
}

// MARK: - Medium Widget Layout

struct MediumSquatWidget: View {
    var entry: SquatEntry

    var body: some View {
        VStack {
            // Header with date and streak
            HStack {
                Text(entry.dateString)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                if entry.stats.currentStreak > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                            .font(.caption)

                        Text("\(entry.stats.currentStreak) day streak")
                            .font(.caption)
                            .bold()
                    }
                }
            }
            .padding(.horizontal, 8)

            // Main content
            HStack(alignment: .center) {
                // Today's progress
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(
                            Color.gray.opacity(0.2),
                            lineWidth: 6
                        )

                    // Progress arc
                    Circle()
                        .trim(from: 0, to: CGFloat(entry.progressPercentage))
                        .stroke(
                            entry.goalReached ? Color.green : Color.primary,
                            style: StrokeStyle(
                                lineWidth: 6,
                                lineCap: .round
                            )
                        )
                        .rotationEffect(.degrees(-90))

                    // Counter text
                    VStack(spacing: 0) {
                        Text("\(entry.todaySquats)")
                            .font(.system(size: 32, weight: .bold))

                        Text("of \(entry.dailyGoal)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 100, height: 100)
                .padding(.leading, 8)

                Spacer()

                // Last 7 days
                VStack(alignment: .leading) {
                    Text("Last 7 Days")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 4)

                    HStack(spacing: 8) {
                        // Weekly bar chart
                        ForEach(entry.weeklyData.suffix(7), id: \.date) { day in
                            VStack(spacing: 4) {
                                // Bar
                                ZStack(alignment: .bottom) {
                                    // Background bar
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.1))
                                        .frame(width: 6, height: 60)

                                    // Progress bar
                                    Rectangle()
                                        .fill(day.goalReached ? Color.green : Color.primary)
                                        .frame(width: 6, height: 60 * day.percentage)
                                }
                                .cornerRadius(3)

                                // Day label
                                Text(day.dayName.prefix(1))
                                    .font(.system(size: 8))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding(.trailing, 12)
            }
            .padding(.vertical, 4)
        }
        .padding(8)
        .widgetURL(URL(string: "zobbsquat://calendar"))
    }
}

// MARK: - Large Widget Layout

struct LargeSquatWidget: View {
    var entry: SquatEntry

    var body: some View {
        VStack(spacing: 12) {
            // Header with date and title
            HStack {
                Text("Squat Counter")
                    .font(.headline)

                Spacer()

                Text(entry.dateString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            // Today's progress
            HStack(alignment: .center, spacing: 20) {
                // Progress circle
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(
                            Color.gray.opacity(0.2),
                            lineWidth: 8
                        )

                    // Progress arc
                    Circle()
                        .trim(from: 0, to: CGFloat(entry.progressPercentage))
                        .stroke(
                            entry.goalReached ? Color.green : Color.primary,
                            style: StrokeStyle(
                                lineWidth: 8,
                                lineCap: .round
                            )
                        )
                        .rotationEffect(.degrees(-90))

                    // Counter text
                    VStack(spacing: 4) {
                        Text("TODAY")
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        Text("\(entry.todaySquats)")
                            .font(.system(size: 44, weight: .bold))

                        Text("of \(entry.dailyGoal) squats")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if entry.goalReached {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .padding(.top, 2)
                        }
                    }
                }
                .frame(width: 120, height: 120)

                // Stats section
                VStack(alignment: .leading, spacing: 8) {
                    statRow(title: "Current Streak", value: "\(entry.stats.currentStreak) days", icon: "flame.fill", color: .orange)
                    statRow(title: "Best Streak", value: "\(entry.stats.bestStreak) days", icon: "trophy.fill", color: .yellow)
                    statRow(title: "Total Squats", value: "\(entry.stats.totalSquats)", icon: "figure.strengthtraining.traditional", color: .blue)
                }
                .padding(.trailing, 16)
            }
            .padding(.horizontal, 16)

            Divider()
                .padding(.horizontal, 16)

            // Weekly progress
            VStack(alignment: .leading, spacing: 8) {
                Text("WEEKLY PROGRESS")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)

                // Week view
                HStack(spacing: 0) {
                    ForEach(entry.weeklyData, id: \.date) { day in
                        VStack(spacing: 4) {
                            // Day progress circle
                            ZStack {
                                // Background circle
                                Circle()
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 2)
                                    .frame(width: 28, height: 28)

                                // Progress circle
                                if day.count > 0 {
                                    Circle()
                                        .trim(from: 0, to: CGFloat(day.percentage))
                                        .stroke(
                                            day.goalReached ? Color.green : Color.primary,
                                            style: StrokeStyle(lineWidth: 2, lineCap: .round)
                                        )
                                        .rotationEffect(.degrees(-90))
                                        .frame(width: 28, height: 28)
                                }

                                // Day number
                                Text(day.dayNumber)
                                    .font(.system(size: 10))
                                    .foregroundStyle(day.isToday ? .primary : .secondary)
                            }

                            // Day name
                            Text(day.dayName)
                                .font(.system(size: 10))
                                .foregroundStyle(day.isToday ? .primary : .secondary)
                                .fontWeight(day.isToday ? .bold : .regular)

                            if day.count > 0 {
                                // Squat count
                                Text("\(day.count)")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(day.goalReached ? .green : .primary)
                            } else {
                                Text("-")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 8)
            }
            .padding(.bottom, 12)
        }
        .padding(4)
        .widgetURL(URL(string: "zobbsquat://calendar"))
    }

    private func statRow(title: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.system(size: 16, weight: .semibold))
            }
        }
    }
}
