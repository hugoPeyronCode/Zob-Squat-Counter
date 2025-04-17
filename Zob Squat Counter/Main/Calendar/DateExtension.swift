//
//  File.swift
//  Zob Squat Counter
//
//  Created by Hugo Peyron on 17/04/2025.
//


import SwiftUI

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