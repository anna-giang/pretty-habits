//
//  HabitEntry.swift
//  pretty-habits
//
import SwiftUI
import SwiftData

@Model
final class HabitEntry {
    var habitName: String
    var colorHex: String        // store color as hex string
    var startDate: Date
    var endDate: Date
    var completedDates: [Date]  // dates marked as done
    var targetDays: Int
    var sortOrder: Int

    init(habitName: String, colorHex: String, startDate: Date, endDate: Date, targetDays: Int, sortOrder: Int) {
        self.habitName = habitName
        self.colorHex = colorHex
        self.startDate = startDate
        self.endDate = endDate
        self.completedDates = []
        self.targetDays = targetDays
        self.sortOrder = sortOrder
    }

    /// Completion percentage (0–100), calculated as number of days completed divided by target days
    var completionPercent: Double {
        min(Double(completedDates.count) / Double(targetDays) * 100, 100)
    }

    /// Whether today is already marked done
    var isDoneToday: Bool {
        completedDates.contains { Calendar.current.isDateInToday($0) }
    }

    /// Mark today as done
    func markDoneToday() {
        guard !isDoneToday else { return }
        completedDates.append(Date())
    }

    /// Unmark today
    func unmarkToday() {
        completedDates.removeAll { Calendar.current.isDateInToday($0) }
    }

    /// SwiftUI Color from hex
    var color: Color {
        Color(hex: colorHex)
    }
}
