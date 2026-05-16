//
//  SharedHabitData.swift
//  pretty-habits
//
import Foundation

// A lightweight, Codable mirror of HabitEntry for sharing between app and widget.
struct SharedHabit: Codable, Identifiable {
    let id: UUID
    let habitName: String
    let colorHex: String
    let completedCount: Int
    let targetCompletionCount: Int
}

struct SharedHabitStore {
    static let appGroupID = "group.annagiang.pretty-habits"
    static let key = "sharedHabits"

    static func save(_ habits: [SharedHabit]) {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = try? JSONEncoder().encode(habits) else { return }
        defaults.set(data, forKey: key)
    }

    static func load() -> [SharedHabit] {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = defaults.data(forKey: key),
              let habits = try? JSONDecoder().decode([SharedHabit].self, from: data)
        else { return [] }
        return habits
    }
}
