//
//  EditHabitCalendarSheet.swift
//  pretty-habits

import SwiftUI

struct EditHabitCalendarSheet: View {
    let startDate: Date
    let endDate: Date
    @Binding var completedDates: [Date]
    @Environment(\.dismiss) private var dismiss

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdaySymbols = Calendar.current.veryShortWeekdaySymbols

    // All days in the habit range
    private var days: [Date] {
        var result: [Date] = []
        var current = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)
        while current <= end {
            result.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        return result
    }

    // Leading empty cells so the first day lands on the right weekday column
    private var leadingBlanks: Int {
        let weekday = calendar.component(.weekday, from: days.first ?? startDate)
        return (weekday - calendar.firstWeekday + 7) % 7
    }

    // Group days by month for section headers
    private var months: [(title: String, days: [Date])] {
        var grouped: [(title: String, days: [Date])] = []
        var current: (title: String, days: [Date])? = nil

        for day in days {
            let title = day.formatted(.dateTime.month(.wide).year())
            if current?.title == title {
                current?.days.append(day)
            } else {
                if let c = current { grouped.append(c) }
                current = (title, [day])
            }
        }
        if let c = current { grouped.append(c) }
        return grouped
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(months, id: \.title) { month in
                        MonthBlock(
                            title: month.title,
                            days: month.days,
                            startDate: startDate,
                            completedDates: $completedDates
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Completed Days")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Month block
private struct MonthBlock: View {
    let title: String
    let days: [Date]
    let startDate: Date
    @Binding var completedDates: [Date]

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdaySymbols = Calendar.current.veryShortWeekdaySymbols

    // Blank cells before the first day of this month block
    private var leadingBlanks: Int {
        let weekday = calendar.component(.weekday, from: days.first!)
        return (weekday - calendar.firstWeekday + 7) % 7
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Month header
            Text(title)
                .font(.headline)
                .padding(.bottom, 2)

            // Weekday labels
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }

                // Blank leading cells
                ForEach(0..<leadingBlanks, id: \.self) { _ in
                    Color.clear.frame(height: 36)
                }

                // Day cells
                ForEach(days, id: \.self) { day in
                    DayCell(
                        day: day,
                        isCompleted: isCompleted(day),
                        isFuture: day > Date()
                    ) {
                        toggle(day)
                    }
                }
            }
        }
    }

    private func isCompleted(_ date: Date) -> Bool {
        completedDates.contains {
            calendar.isDate($0, inSameDayAs: date)
        }
    }

    private func toggle(_ date: Date) {
        // Don't allow logging future dates
        guard date <= calendar.startOfDay(for: Date()) else { return }

        if let index = completedDates.firstIndex(where: {
            calendar.isDate($0, inSameDayAs: date)
        }) {
            completedDates.remove(at: index)
        } else {
            completedDates.append(date)
        }
    }
}

// MARK: - Day cell
private struct DayCell: View {
    let day: Date
    let isCompleted: Bool
    let isFuture: Bool
    let onTap: () -> Void

    private var dayNumber: String {
        day.formatted(.dateTime.day())
    }

    var body: some View {
        Button(action: onTap) {
            Text(dayNumber)
                .font(.system(.callout, design: .rounded))
                .fontWeight(isCompleted ? .semibold : .regular)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(
                    Circle()
                        .fill(isCompleted ? Color.accentColor : Color.clear)
                )
                .foregroundStyle(cellForeground)
        }
        .disabled(isFuture)
        .buttonStyle(.plain)
    }

    private var cellForeground: Color {
        if isFuture { return .secondary }
        if isCompleted { return .white }
        return .primary
    }
}
