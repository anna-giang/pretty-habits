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

    init(habitName: String, colorHex: String, startDate: Date, endDate: Date) {
        self.habitName = habitName
        self.colorHex = colorHex
        self.startDate = startDate
        self.endDate = endDate
        self.completedDates = []
    }

    /// Total number of days in the habit window
    var totalDays: Int {
        let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        return max(days, 1)
    }

    /// Completion percentage (0–100)
    var completionPercent: Double {
        min(Double(completedDates.count) / Double(totalDays) * 100, 100)
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
