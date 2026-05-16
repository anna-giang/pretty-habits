//
//  PrettyHabitsWidget.swift
//  PrettyHabitsWidget
//
import WidgetKit
import SwiftUI

// MARK: - Timeline Entry
struct HabitEntry: TimelineEntry {
    let date: Date
    let habits: [SharedHabit]
}

// MARK: - Provider
struct HabitProvider: TimelineProvider {
    func placeholder(in context: Context) -> HabitEntry {
        HabitEntry(date: Date(), habits: [
            SharedHabit(id: UUID(), habitName: "Habit 1", colorHex: "FF6B6B", startDate: Date(), endDate: Date(), completedDates: [], targetDays: 7, sortOrder: 1),
            SharedHabit(id: UUID(), habitName: "Habit 2", colorHex: "4ECDC4", startDate: Date(), endDate: Date(), completedDates: [], targetDays: 7, sortOrder: 2),
            SharedHabit(id: UUID(), habitName: "Habit 3", colorHex: "FFD93D", startDate: Date(), endDate: Date(), completedDates: [], targetDays: 7, sortOrder: 3),
        ])
    }

    func getSnapshot(in context: Context, completion: @escaping (HabitEntry) -> Void) {
        completion(HabitEntry(date: Date(), habits: SharedHabitStore.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HabitEntry>) -> Void) {
        let entry = HabitEntry(date: Date(), habits: SharedHabitStore.load())
        // Refresh at midnight so completion percentages stay current
        let midnight = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400))
        let timeline = Timeline(entries: [entry], policy: .after(midnight))
        completion(timeline)
    }
}

// MARK: - Widget
@main
struct PrettyHabitsWidget: Widget {
    let kind: String = "PrettyHabitsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitProvider()) { entry in
            PrettyHabitsWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Habit Rings")
        .description("Your habit progress at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
