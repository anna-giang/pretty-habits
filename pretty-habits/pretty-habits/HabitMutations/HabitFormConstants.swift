//
//  HabitFormConstants.swift
//  pretty-habits
//  Contains values and helper functions shared between Add and Edit Habit views.
//

import SwiftUI

// MARK: - Static constants
enum HabitForm {
    static let presetColors: [(label: String, hex: String)] = [
        ("Coral",    "FF6B6B"),
        ("Sky",      "4ECDC4"),
        ("Gold",     "FFD93D"),
        ("Lavender", "A78BFA"),
        ("Mint",     "6BCB77"),
    ]
}

// MARK: - Date/target helpers
extension HabitForm {
    static func minEndDate(from startDate: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: 1, to: startDate) ?? startDate
    }

    static func maxTarget(from startDate: Date, to endDate: Date) -> Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 1
    }
}
