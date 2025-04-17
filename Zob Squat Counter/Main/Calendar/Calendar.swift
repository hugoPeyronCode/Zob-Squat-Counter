//
//  CalendarView.swift
//  Zob Squat Counter
//
//  Created by Hugo Peyron on 17/04/2025.
//

import SwiftUI

struct CalendarView: View {
  @AppStorage("dailyGoal") private var dailyGoal = 30
  @State private var selectedDate = Date()
  @State private var calendarData: [Date: Int] = [:]
  @State private var currentMonth = Date()
  @State private var bestStreak = 35
  @State private var currentStreak = 30

  var body: some View {
    VStack {
      monthNavigationView
      calendarGridView
      calendarLegend
      selectedDayDetailView

      Spacer()

      streakInfoView

      Spacer()
    }
    .fontDesign(.monospaced)
    .padding(.top)
    .onAppear {
      calendarData = generateSampleData()
    }
  }

  // MARK: - Component Views

  private var streakInfoView: some View {
    VStack(alignment: .leading) {
      VStack(alignment: .leading) {
        Text("Best streak \(bestStreak)")
        Text("Current streak \(currentStreak)")
        Text("Total squats 15400")

        Button {
          jumpToToday()
        } label: {
          Text("Today")
            .foregroundStyle(.blue)
        }
      }
      .font(.system(size: 17))
      .fontDesign(.monospaced)
      .bold()

    }
  }

  private var monthNavigationView: some View {
    HStack {
      Button(action: previousMonth) {
        Image(systemName: "chevron.left")
          .font(.title3)
          .foregroundStyle(.gray)
      }

      Spacer()

      Text(monthYearFormatter.string(from: currentMonth))
        .font(.title2)
        .fontWeight(.semibold)
        .animation(.none, value: currentMonth)

      Spacer()

      Button(action: nextMonth) {
        Image(systemName: "chevron.right")
          .font(.title3)
          .foregroundStyle(.gray)
      }
    }
    .padding(.horizontal)
  }

  private var calendarGridView: some View {
    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
      ForEach(["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"], id: \.self) { day in
        Text(day)
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      ForEach(daysInMonth(), id: \.self) { date in
        if date.isInSameMonth(as: currentMonth) {
          DayCell(date: date, squatCount: calendarData[date.startOfDay] ?? 0, goalTarget: dailyGoal)
            .onTapGesture {
              withAnimation {
                selectedDate = date
              }
            }
            .overlay {
              if date.isSameDay(as: selectedDate) {
                RoundedRectangle(cornerRadius: 10)
                  .stroke(Color.primary, lineWidth: 2)
              }
            }
        } else {
          Text("")
            .frame(height: 50)
        }
      }
    }
    .padding(.horizontal, 5)
  }

  private var calendarLegend: some View {
    HStack(spacing: 16) {
      legendItem(color: .green, text: "Goal reached")
      legendItem(color: .primary, text: "In progress")
      legendItem(backgroundOpacity: 0.1, text: "Today")
    }
    .font(.caption2)
    .foregroundStyle(.secondary)
    .padding(.top, 8)
    .padding(.horizontal)
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private func legendItem(color: Color, text: String) -> some View {
    HStack(spacing: 4) {
      Circle()
        .fill(color)
        .frame(width: 8, height: 8)
      Text(text)
    }
  }

  private func legendItem(backgroundOpacity: Double, text: String) -> some View {
    HStack(spacing: 4) {
      RoundedRectangle(cornerRadius: 2)
        .fill(Color.primary.opacity(backgroundOpacity))
        .frame(width: 8, height: 8)
      Text(text)
    }
  }

  @ViewBuilder
  private var selectedDayDetailView: some View {
    if let squatCount = calendarData[selectedDate.startOfDay] {
      VStack(spacing: 15) {
        Text(selectedDate.formatted(date: .complete, time: .omitted))
          .font(.headline)

        HStack(spacing: 20) {
          VStack {
            Text("\(squatCount)")
              .font(.system(size: 36, weight: .bold))
            Text("Squats")
              .font(.subheadline)
              .foregroundStyle(.secondary)
          }

          Divider()
            .frame(height: 40)

          VStack {
            Text("\(Int(min(Double(squatCount) / Double(dailyGoal) * 100, 100)))%")
              .font(.system(size: 36, weight: .bold))
              .foregroundStyle(squatCount >= dailyGoal ? .green : .primary)
            Text("of Goal")
              .font(.subheadline)
              .foregroundStyle(.secondary)
          }
        }
        .padding()
        .background(
          RoundedRectangle(cornerRadius: 15)
            .fill(.ultraThinMaterial)
        )
      }
      .padding()
      .transition(.move(edge: .bottom).combined(with: .opacity))
      .animation(.spring, value: selectedDate)
    }
  }

  // MARK: - Helper Methods

  private func jumpToToday() {
    withAnimation {
      // Set the current month to today's month if different
      let today = Date()
      let calendar = Calendar.current

      if !calendar.isDate(currentMonth, equalTo: today, toGranularity: .month) {
        currentMonth = today
      }

      // Select today's date
      selectedDate = today
    }
  }

  private func generateSampleData() -> [Date: Int] {
    let calendar = Calendar.current
    var data: [Date: Int] = [:]

    for day in -30...0 {
      guard let date = calendar.date(byAdding: .day, value: day, to: Date()) else { continue }
      let squatCount = Int.random(in: 0...(dailyGoal + 15))
      data[date] = squatCount
    }

    return data
  }

  private func previousMonth() {
    withAnimation {
      currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }
  }

  private func nextMonth() {
    withAnimation {
      currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }
  }

  private func daysInMonth() -> [Date] {
    guard let monthInterval = Calendar.current.dateInterval(of: .month, for: currentMonth),
          let monthFirstWeek = Calendar.current.dateInterval(of: .weekOfMonth, for: monthInterval.start),
          let monthLastWeek = Calendar.current.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1) else {
      return []
    }

    let calendar = Calendar.current
    var dates: [Date] = []
    var currentDate = monthFirstWeek.start

    while currentDate < monthLastWeek.end {
      dates.append(currentDate)
      currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
    }

    return dates
  }

  private var monthYearFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    return formatter
  }
}

struct DayCell: View {
  let date: Date
  let squatCount: Int
  let goalTarget: Int

  var calendar = Calendar.current
  private var day: String {
    let day = calendar.component(.day, from: date)
    return "\(day)"
  }

  private var goalReached: Bool {
    return squatCount >= goalTarget
  }

  var body: some View {
    VStack(spacing: 5) {
      Text(day)
        .font(.system(size: 16, weight: .medium))

      if date <= Date() { // Only show progress for past or current days
        Circle()
          .fill(goalReached ? Color.green : Color.primary.opacity(0.3))
          .frame(width: 10, height: 10)
      }
    }
    .frame(width: 40, height: 50)
    .background(date.isToday ? Color.primary.opacity(0.1) : Color.clear)
    .cornerRadius(10)
  }
}

extension Date {
  var startOfDay: Date {
    return Calendar.current.startOfDay(for: self)
  }

  func isInSameMonth(as date: Date) -> Bool {
    let calendar = Calendar.current
    return calendar.component(.month, from: self) == calendar.component(.month, from: date) &&
    calendar.component(.year, from: self) == calendar.component(.year, from: date)
  }

  var isToday: Bool {
    return Calendar.current.isDateInToday(self)
  }

  func isSameDay(as date: Date) -> Bool {
    let calendar = Calendar.current
    return calendar.isDate(self, inSameDayAs: date)
  }
}

#Preview {
  CalendarView()
}
