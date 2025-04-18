//
//  CalendarView.swift
//  Zob Squat Counter
//
//  Created by Hugo Peyron on 17/04/2025.
//

import SwiftUI
import SwiftData

struct CalendarView: View {
  @AppStorage("dailyGoal") private var dailyGoal = 30
  @AppStorage("hasStatsSubscription") private var hasStatsSubscription = false
  @Environment(\.modelContext) private var modelContext

  @State private var selectedDate = Date()
  @State private var currentMonth = Date()
  @State private var statsFadeOut = false
  @State private var showSubscriptionSheet = false

  // Stats loaded from SwiftData
  @State private var calendarData: [Date: Int] = [:]
  @State private var bestStreak = 0
  @State private var currentStreak = 0
  @State private var averageDailySquats = 0
  @State private var totalSquats = 0

  // Layout properties
  let spacing: CGFloat = 20
  let cardPadding: CGFloat = 16

  var body: some View {
    ScrollView {
      VStack(alignment: .center, spacing: spacing) {
        // Calendar header and grid
        calendarSection
          .background(
            RoundedRectangle(cornerRadius: 16)
              .fill(Color.primary.opacity(0.03))
          )
          .padding(.horizontal)

        // Day detail card
        selectedDayDetailView
          .padding(.horizontal)

        // Stats section
        statsSection
          .padding(.horizontal)

        todayButton
      }
      .fontDesign(.monospaced)
      .padding(.vertical, spacing)
      .task {
        await loadCalendarData()
      }
      .onChange(of: currentMonth) { _, _ in
        Task {
          await loadCalendarData()
        }
      }
      .sheet(isPresented: $showSubscriptionSheet) {
        SubscriptionView(onSubscribe: handleSubscriptionPurchase)
      }
    }
  }

  // MARK: - UI Sections

  private var todayButton: some View {
    Button {
      jumpToToday()
    } label: {
      Text("Today")
        .fontWeight(.medium)
        .foregroundStyle(.primary)
        .padding(.vertical, 12)
        .padding(.horizontal, 24)
        .background(.thinMaterial)
        .clipShape(Capsule())
    }
    .padding(.vertical, spacing)
  }

  private var calendarSection: some View {
    VStack(spacing: spacing) {
      monthNavigationView
        .padding(.top, cardPadding)

      // Make calendar scrollable horizontally if needed
      ScrollView(.horizontal, showsIndicators: false) {
        calendarGridView
          .padding(.horizontal, cardPadding)
      }

      calendarLegend
        .padding(.bottom, cardPadding)
    }
  }

  private var statsSection: some View {
    VStack(alignment: .leading, spacing: spacing / 2) {
      Text("Statistics")
        .font(.title3)
        .fontWeight(.bold)
        .padding(.bottom, 4)

      VStack(alignment: .leading, spacing: spacing / 2) {
        statsElements(name: "Best streak", count: bestStreak)
        statsElements(name: "Current streak", count: currentStreak)
        statsElements(name: "Avg daily squats", count: averageDailySquats)
        statsElements(name: "Total squats", count: totalSquats)
      }
    }
    .padding(cardPadding)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.primary.opacity(0.03))
    )
    .statsBlurContainer(
      isVisible: hasStatsSubscription,
      isFadingOut: statsFadeOut,
      onUnlockTapped: openSubscriptionShop
    )
    .clipShape(RoundedRectangle(cornerRadius: 16))
  }

  // MARK: - Calendar Elements

  private var monthNavigationView: some View {
    HStack {
      Button(action: previousMonth) {
        Image(systemName: "chevron.left")
          .font(.title3)
          .foregroundStyle(.gray)
          .padding(8)
          .background(Circle().fill(Color.primary.opacity(0.05)))
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
          .padding(8)
          .background(Circle().fill(Color.primary.opacity(0.05)))
      }
    }
    .padding(.horizontal)
  }

  private var calendarGridView: some View {
    LazyVGrid(columns: Array(repeating: GridItem(.fixed(40)), count: 7), spacing: 10) {
      // Weekday headers
      ForEach(["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"], id: \.self) { day in
        Text(day)
          .font(.caption)
          .foregroundStyle(.secondary)
          .frame(width: 40, height: 20)
      }

      // Calendar days
      ForEach(daysInMonth(), id: \.self) { date in
        if date.isInSameMonth(as: currentMonth) {
          DayCell(
            date: date,
            squatCount: calendarData[date.startOfDay] ?? 0,
            goalTarget: dailyGoal
          )
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
            .frame(width: 40, height: 50)
        }
      }
    }
    .frame(minWidth: 300)
  }

  private var calendarLegend: some View {
    HStack(spacing: 16) {
      legendItem(color: .green, text: "Goal reached")
      Spacer()
      legendItem(color: .primary.opacity(0.3), text: "In progress")
      Spacer()
      legendItem(backgroundOpacity: 0.1, text: "Today")
    }
    .font(.caption2)
    .foregroundStyle(.secondary)
    .padding(.horizontal, 24)
  }

  private func legendItem(color: Color, text: String) -> some View {
    HStack(spacing: 6) {
      Circle()
        .fill(color)
        .frame(width: 8, height: 8)
      Text(text)
    }
  }

  private func legendItem(backgroundOpacity: Double, text: String) -> some View {
    HStack(spacing: 6) {
      RoundedRectangle(cornerRadius: 2)
        .fill(Color.primary.opacity(backgroundOpacity))
        .frame(width: 8, height: 8)
      Text(text)
    }
  }

  private var selectedDayDetailView: some View {
    // Get the squat count, defaulting to 0 if there's no data
    let squatCount = calendarData[selectedDate.startOfDay] ?? 0

    return VStack(spacing: spacing / 2) {
      Text(selectedDate.formatted(date: .complete, time: .omitted))
        .contentTransition(.numericText())
        .font(.headline)
        .padding(.bottom, 6)

      HStack(spacing: 30) {
        VStack {
          Text("\(squatCount)")
            .font(.system(size: 32, weight: .bold))
            .contentTransition(.numericText())
          Text("Squats")
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)

        Divider()
          .frame(height: 50)

        VStack {
          Text("\(Int(min(Double(squatCount) / Double(dailyGoal) * 100, 100)))%")
            .font(.system(size: 32, weight: .bold))
            .foregroundStyle(squatCount >= dailyGoal ? .green : .primary)
            .contentTransition(.numericText())
          Text("of Goal")
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
      }
    }
    .padding(cardPadding)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(.ultraThinMaterial)
    )
    .transition(.move(edge: .bottom).combined(with: .opacity))
    .animation(.spring, value: selectedDate)
  }

  // MARK: - Data Loading

  private func loadCalendarData() async {
    // Get the date range for the current month view (including visible days from previous/next months)
    let calendar = Calendar.current
    guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
          let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
          let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1) else {
      return
    }

    // Fetch squat days from SwiftData
    let startDate = monthFirstWeek.start
    let endDate = monthLastWeek.end

    let squatDays = SquatDataManager.fetchSquatDays(
      context: modelContext,
      startDate: startDate,
      endDate: endDate
    )

    // Convert to dictionary for easy lookup
    var newCalendarData: [Date: Int] = [:]
    for day in squatDays {
      newCalendarData[day.dayStart] = day.count
    }

    // Update state with the fetched data
    await MainActor.run {
      self.calendarData = newCalendarData

      // Load stats
      loadStatsData()
    }
  }

  private func loadStatsData() {
    let stats = SquatDataManager.fetchOrCreateStats(context: modelContext)
    self.bestStreak = stats.bestStreak
    self.currentStreak = stats.currentStreak
    self.totalSquats = stats.totalSquats
    self.averageDailySquats = SquatDataManager.getAverageDailySquats(context: modelContext)
  }

  // MARK: - Helper Views

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

  // MARK: - Subscription Logic

  private func openSubscriptionShop() {
    if !hasStatsSubscription {
      showSubscriptionSheet = true
    }
  }

  private func handleSubscriptionPurchase(subscriptionType: SubscriptionType) {
    // Handle subscription purchase completion
    switch subscriptionType {
    case .monthly, .yearly:
      // Animate the blur overlay disappearing
      withAnimation(.spring(response: 0.4)) {
        statsFadeOut = true
      }

      // After animation completes, set the subscription state
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
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
    .previewWithData()
}
