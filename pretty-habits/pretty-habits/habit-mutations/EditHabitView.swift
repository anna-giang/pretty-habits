//
//  EditHabitView.swift
//  pretty-habits
//
import SwiftUI

struct EditHabitView: View {
    @Environment(\.dismiss) private var dismiss

    let habit: HabitEntry

    @State private var name: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var selectedColorHex: String
    @State private var targetDays: Int

    @State private var errorMessage: String = ""
    @State private var showError = false

    // Pre-populate state from the existing habit
    init(habit: HabitEntry) {
        self.habit = habit
        _name = State(initialValue: habit.habitName)
        _startDate = State(initialValue: habit.startDate)
        _endDate = State(initialValue: habit.endDate)
        _selectedColorHex = State(initialValue: habit.colorHex)
        _targetDays = State(initialValue: habit.targetDays)
    }

    var body: some View {
        let maxTarget = HabitForm.maxTarget(from: startDate, to: endDate)
        let minEndDate = HabitForm.minEndDate(from: startDate)
        NavigationStack {
            Form {
                Section("Habit") {
                    TextField("Name", text: $name)
                }

                Section("Schedule") {

                    DatePicker(
                        "Start",
                        selection: $startDate,
                        displayedComponents: .date
                    )
                    .onChange(of: startDate) {
                        if endDate <= startDate {
                            endDate = minEndDate
                        }
                        targetDays = min(targetDays, maxTarget)
                    }

                    DatePicker(
                        "End",
                        selection: $endDate,
                        in: minEndDate...,
                        displayedComponents: .date
                    )
                    .onChange(of: endDate) {
                        targetDays = min(targetDays, maxTarget)
                    }
                }

                Section("Target") {
                    if maxTarget < 1 {
                        Text("End date must be after start date")
                            .foregroundStyle(.red)
                            .font(.caption)
                    } else {
                        Picker("Target days", selection: $targetDays) {
                            ForEach(1...maxTarget, id: \.self) { day in
                                Text("^[\(day) day](inflect: true)").tag(day)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                }

                Section("Colour") {
                    HStack(spacing: 16) {
                        ForEach(HabitForm.presetColors, id: \.1) { label, hex in
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Circle().stroke(
                                        Color.primary,
                                        lineWidth: selectedColorHex == hex
                                            ? 3 : 0
                                    )
                                )
                                .onTapGesture { selectedColorHex = hex }
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Warn user if date changes will drop completed dates
                if hasOutOfRangeCompletions {
                    Section {
                        Label(
                            "Some completed dates fall outside the new date range and will be removed on save.",
                            systemImage: "exclamationmark.triangle"
                        )
                        .font(.caption)
                        .foregroundStyle(.orange)
                    }
                }
            }
            .navigationTitle("Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.isEmpty || maxTarget < 1)
                }
            }
            .alert("Invalid Habit", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    // Whether any completed dates would be stripped by the new date range
    private var hasOutOfRangeCompletions: Bool {
        habit.completedDates.contains { date in
            date < startDate || date > endDate
        }
    }

    private func save() {
        let maxTarget = HabitForm.maxTarget(from: startDate, to: endDate)
        guard !name.isEmpty else { return }
        guard targetDays <= maxTarget else {
            errorMessage =
                "Target \(targetDays) days exceeds habit duration of \(maxTarget) days."
            showError = true
            return
        }

        habit.habitName = name
        habit.startDate = startDate
        habit.endDate = endDate
        habit.colorHex = selectedColorHex
        habit.targetDays = targetDays

        // Strip completed dates that fall outside the new range
        habit.completedDates = habit.completedDates.filter { date in
            date >= startDate && date <= endDate
        }

        dismiss()
    }
}
