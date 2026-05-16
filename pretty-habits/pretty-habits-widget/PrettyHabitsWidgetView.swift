//
//  PrettyHabitsWidgetView.swift
//  PrettyHabitsWidget
//
import SwiftUI
import WidgetKit

struct PrettyHabitsWidgetView: View {
    let entry: HabitEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        // Tapping anywhere opens the app
        Link(destination: URL(string: "prettyhabits://open")!) {
            switch family {
            case .systemSmall:
                SmallWidgetView(habits: entry.habits)
            case .systemMedium:
                MediumWidgetView(habits: entry.habits)
            default:
                SmallWidgetView(habits: entry.habits)
            }
        }
    }
}

// MARK: - Small: just the rings centred
struct SmallWidgetView: View {
    let habits: [SharedHabit]

    var body: some View {
        ZStack {
            ForEach(Array(habits.enumerated()), id: \.element.id) { index, habit in
                let size = 130 - CGFloat(index) * 22
                WidgetRing(habit: habit, size: size, ringWidth: 14)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Medium: rings on left, habit list on right
struct MediumWidgetView: View {
    let habits: [SharedHabit]

    var body: some View {
        HStack(spacing: 16) {
            // Rings
            ZStack {
                ForEach(Array(habits.enumerated()), id: \.element.id) { index, habit in
                    let size = 120 - CGFloat(index) * 20
                    WidgetRing(habit: habit, size: size, ringWidth: 12)
                }
            }
            .frame(width: 130, height: 130)

            // Habit name list
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(habits.enumerated()), id: \.element.id) { index, habit in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color(hex: habit.colorHex))
                            .frame(width: 8, height: 8)
                        Text(habit.habitName)
                            .font(.caption)
                            .lineLimit(1)
                        Spacer()
                        Text("\(habit.completedDates.count)/\(habit.targetDays)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Single ring view for widget
struct WidgetRing: View {
    let habit: SharedHabit
    let size: CGFloat
    let ringWidth: CGFloat

    private var percent: Double {
        min(Double(habit.completedDates.count) / Double(habit.targetDays) * 100, 100)
    }

    private var color: Color {
        Color(hex: habit.colorHex)
    }

    var body: some View {
        PercentageRing(
            ringWidth: ringWidth,
            percent: percent,
            backgroundColor: color.opacity(0.15),
            foregroundColors: [color, color.opacity(0.7)]
        )
        .frame(width: size, height: size)
    }
}
