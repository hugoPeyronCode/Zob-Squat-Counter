//
//  CalendarView.swift
//  Zob Squat Counter
//
//  Created by Hugo Peyron on 17/04/2025.
//

import SwiftUI

struct CalendarView: View {
  @AppStorage("dailyGoal") private var dailyGoal = 30
  @AppStorage("hasStatsSubscription") private var hasStatsSubscription = false
  @State private var selectedDate = Date()
  @State private var calendarData: [Date: Int] = [:]
  @State private var currentMonth = Date()
  @State private var bestStreak = 35
  @State private var currentStreak = 30
  @State private var showSubscriptionSheet = false
  @State private var statsFadeOut = false

  var body: some View {
    VStack(alignment: .leading) {
      monthNavigationView
      calendarGridView
      calendarLegend
      selectedDayDetailView

      Spacer()

      streakInfoView
        .overlay {
          if !hasStatsSubscription {
            ZStack {
              // Blur overlay when not subscribed
              RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(.ultraThinMaterial)
                .opacity(statsFadeOut ? 0 : 0.8)

              Button {
                openSubscriptionShop()
              } label: {
                Image(systemName: "eye")
                  .foregroundStyle(.indigo)
                  .padding()
                  .background(.thinMaterial)
                  .clipShape(.circle)
              }
              .scaleEffect(statsFadeOut ? 0.5 : 1)
              .opacity(statsFadeOut ? 0 : 1)
            }
            .animation(.spring(response: 0.3), value: statsFadeOut)
          }
        }

      Button {
        jumpToToday()
      } label: {
        Text("Today")
          .foregroundStyle(.blue)
          .padding(.top)
      }
      .padding(.horizontal, 5)

      Spacer()
    }
    .fontDesign(.monospaced)
    .padding(.top)
    .onAppear {
      calendarData = generateSampleData()
    }
    .sheet(isPresented: $showSubscriptionSheet) {
      SubscriptionView(onSubscribe: handleSubscriptionPurchase)
    }
  }

  private var streakInfoView: some View {
    VStack(alignment: .leading) {
      Text("Stats")
        .font(.title3)
      VStack(alignment: .leading) {
        statsElements(name: "Best streak", count: 45)
        statsElements(name: "Current streak", count: 5)
        statsElements(name: "Avg daily squats", count: 120)
        statsElements(name: "Total squats", count: 15445)
      }
    }
    .padding(.horizontal, 5)
  }

  private func statsElements(name: String, count: Int) -> some View {
    HStack {
      Text("\(name)")
      Spacer()
      Text("\(count)")
        .overlay {
          if !hasStatsSubscription {
            ZStack {
              RoundedRectangle(cornerRadius: 5)
                .foregroundStyle(.ultraThinMaterial)
            }
          }
        }
    }
    .foregroundStyle(.gray)
    .font(.system(size: 17))
    .fontDesign(.monospaced)
    .bold()
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

  // MARK: - Subscription Logic

  private func openSubscriptionShop() {
    // For demonstration/development, show a quick animation of the stats being revealed
    // In a real app, you would present a proper subscription sheet
    if !hasStatsSubscription {
      showSubscriptionSheet = true
    }
  }

  private func handleSubscriptionPurchase(subscriptionType: SubscriptionType) {
    // Handle subscription purchase completion
    switch subscriptionType {
    case .monthly, .yearly:
      // Animate the blur overlay disappearing
      withAnimation {
        statsFadeOut = true
      }

      // After animation completes, set the subscription state
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        hasStatsSubscription = true
        statsFadeOut = false
      }

    case .none:
      // User cancelled or didn't complete subscription
      showSubscriptionSheet = false
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

// MARK: - Subscription View and Types

enum SubscriptionType {
  case monthly
  case yearly
  case none  // Used for cancellation
}

struct SubscriptionView: View {
  @Environment(\.dismiss) private var dismiss
  var onSubscribe: (SubscriptionType) -> Void
  @State private var selectedOption: SubscriptionType = .monthly

  var body: some View {
    VStack(spacing: 20) {
      Text("Unlock Stats")
        .font(.title)
        .fontWeight(.bold)

      Text("Get detailed statistics and insights into your squat performance")
        .multilineTextAlignment(.center)
        .padding(.horizontal)

      Spacer().frame(height: 20)

      VStack(spacing: 15) {
        subscriptionOption(
          title: "Monthly",
          price: "$1.99",
          description: "Billed monthly",
          type: .monthly
        )

        subscriptionOption(
          title: "Yearly",
          price: "$14.99",
          description: "Save 37% - $1.25/month",
          type: .yearly,
          isBestValue: true
        )
      }
      .padding()

      Spacer()

      Button {
        onSubscribe(selectedOption)
        dismiss()
      } label: {
        Text("Subscribe Now")
          .fontWeight(.semibold)
          .frame(maxWidth: .infinity)
          .padding()
          .background(Color.indigo)
          .foregroundColor(.white)
          .cornerRadius(14)
      }
      .padding(.horizontal)

      Button {
        onSubscribe(.none)
        dismiss()
      } label: {
        Text("No Thanks")
          .foregroundStyle(.secondary)
      }
      .padding(.bottom)
    }
    .padding()
    .fontDesign(.monospaced)
  }

  private func subscriptionOption(
    title: String,
    price: String,
    description: String,
    type: SubscriptionType,
    isBestValue: Bool = false
  ) -> some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        HStack {
          Text(title)
            .font(.headline)

          if isBestValue {
            Text("BEST VALUE")
              .font(.system(size: 10))
              .fontWeight(.bold)
              .padding(.horizontal, 6)
              .padding(.vertical, 2)
              .background(Color.indigo)
              .foregroundStyle(.white)
              .cornerRadius(4)
          }
        }

        Text(description)
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      Spacer()

      VStack(alignment: .trailing) {
        Text(price)
          .font(.headline)
      }

      Circle()
        .strokeBorder(selectedOption == type ? Color.indigo : Color.gray, lineWidth: 2)
        .frame(width: 24, height: 24)
        .overlay {
          if selectedOption == type {
            Circle()
              .fill(Color.indigo)
              .frame(width: 16, height: 16)
          }
        }
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 12)
        .stroke(selectedOption == type ? Color.indigo : Color.gray.opacity(0.3), lineWidth: 2)
    )
    .contentShape(Rectangle())
    .onTapGesture {
      withAnimation(.spring(response: 0.3)) {
        selectedOption = type
      }
    }
  }
}

// MARK: - Day Cell

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
