//
//  HabitRowButton.swift
//  pretty-habits

import SwiftUI

struct HabitRowButton: View {
    let habit: HabitEntry
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Colour dot
                Circle()
                    .fill(
                        shouldGreyOutHabit(habit: habit)
                            ? Color.gray : habit.color
                    )
                    .frame(width: 14, height: 14)

                // Habit name and date range
                VStack(alignment: HorizontalAlignment.leading, spacing: 8) {
                    Text(
                        habitIsExpired(habit: habit)
                            ? "(Ended) \(habit.habitName)" : habit.habitName
                    )
                    .font(.body)
                    .foregroundStyle(
                        shouldGreyOutHabit(habit: habit)
                            ? .secondary : .primary
                    )

                    Text(
                        habit.startDate.formatted(date: .long, time: .omitted)
                            + " - "
                            + habit.endDate.formatted(
                                date: .long,
                                time: .omitted
                            )
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Spacer()

                // Progress label, in the format x/x days completed.
                Text("\(habit.completedDates.count)/\(habit.targetDays) days")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                // Checkmark badge when done today
                if habit.isDoneToday {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.gray)
                } else {
                    Image(systemName: "circle")
                        .foregroundStyle(
                            shouldGreyOutHabit(habit: habit)
                                ? Color.gray : habit.color.opacity(0.5)
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        shouldGreyOutHabit(habit: habit)
                            ? Color(.systemGray5)
                            : habit.color.opacity(0.1)
                    )
            )
        }
        .disabled(habitIsExpired(habit: habit))
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.25), value: habit.isDoneToday)
    }

    private func shouldGreyOutHabit(habit: HabitEntry) -> Bool {
        habit.isDoneToday
            || habitIsExpired(habit: habit)
    }

    private func habitIsExpired(habit: HabitEntry) -> Bool {
        Calendar.current.startOfDay(for: habit.endDate)
            < Calendar.current.startOfDay(for: .now)
    }

}
