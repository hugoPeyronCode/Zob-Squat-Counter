import SwiftUI

struct UserGoal {
    var dailyTarget: Int
    var currentCount: Int

    var progressPercentage: Double {
        guard dailyTarget > 0 else { return 0 }
        return min(Double(currentCount) / Double(dailyTarget), 1.0)
    }

    var isGoalReached: Bool {
        return currentCount >= dailyTarget
    }
}