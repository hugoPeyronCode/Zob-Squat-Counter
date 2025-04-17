import SwiftUI

struct DayCell: View {
    let date: Date
    let squatCount: Int
    let goalTarget: Int

     var calendar = Calendar.current
     var day: String {
        let day = calendar.component(.day, from: date)
        return "\(day)"
    }

     var goalReached: Bool {
        return squatCount >= goalTarget
    }

    var body: some View {
        VStack(spacing: 5) {
            Text(day)
                .font(.system(size: 16, weight: .medium))

            if date <= Date() { // Only show progress for past or current days
                Circle()
                    .fill(goalReached ? Color.green : Color.blue.opacity(0.3))
                    .frame(width: 10, height: 10)
            }
        }
        .frame(height: 50)
        .background(date.isToday ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(10)
    }
}