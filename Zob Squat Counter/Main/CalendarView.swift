import SwiftUI

struct CalendarView: View {
    @AppStorage("dailyGoal") private var dailyGoal = 30
    @State private var selectedDate = Date()
    @State private var calendarData: [Date: Int] = [:]
    @State private var currentMonth = Date()

    // Sample data for demonstration
    private func generateSampleData() -> [Date: Int] {
        let calendar = Calendar.current
        var data: [Date: Int] = [:]

        // Generate random squat counts for the last 30 days
        for day in -30...0 {
            guard let date = calendar.date(byAdding: .day, value: day, to: Date()) else { continue }
            let squatCount = Int.random(in: 0...(dailyGoal + 15))
            data[date] = squatCount
        }

        return data
    }

    var body: some View {
        VStack {
            // Month navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
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
                }
            }
            .padding(.horizontal)

            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                // Day labels
                ForEach(["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Day cells
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
                                        .stroke(Color.blue, lineWidth: 2)
                                }
                            }
                    } else {
                        Text("")
                            .frame(height: 50)
                    }
                }
            }
            .padding(.horizontal, 5)

            // Selected day details
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

            Spacer()
        }
        .padding(.top)
        .onAppear {
            calendarData = generateSampleData()
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