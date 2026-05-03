//
//  AddHabitView.swift
//  pretty-habits
//
import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) private var dismiss
    let habitCount: Int
    var onAdd: (HabitEntry) -> Void

    @State private var name: String = ""
    @State private var startDate: Date = Date()
    // Default end date to 1 month after today.
    @State private var endDate: Date =
        Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    @State private var selectedColorHex: String = "FF6B6B"
    @State private var targetDays: Int = 0

    var body: some View {
        NavigationStack {
            Form {
                Section("Habit") {
                    TextField("Name (e.g. Walk 10k steps)", text: $name)
                }
                Section("Schedule") {
                    DatePicker(
                        "Start",
                        selection: $startDate,
                        displayedComponents: .date
                    )
                    DatePicker(
                        "End",
                        selection: $endDate,
                        in: HabitForm.minEndDate(from: startDate)...,
                        displayedComponents: .date
                    )
                }
                Section("Target days") {
                    targetDaysPicker()
                }
                Section("Colour") {
                    HStack(spacing: 16) {
                        colorCircles
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        guard !name.isEmpty else { return }

                        let entry = HabitEntry(
                            habitName: name,
                            colorHex: selectedColorHex,
                            startDate: startDate,
                            endDate: endDate,
                            targetDays: targetDays,
                            sortOrder: habitCount  // Default newly added habits to the bottom of the list.
                        )
                        onAdd(entry)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }

    private func targetDaysPicker() -> some View {
        let maxTargetDays = HabitForm.maxTarget(from: startDate, to: endDate)
        return Picker("Target days", selection: $targetDays) {
            ForEach(1...max(1, maxTargetDays), id: \.self) { day in
                Text("^[\(day) day](inflect: true)").tag(day)
            }
        }
        .pickerStyle(.wheel)
        .onChange(of: endDate) {
            targetDays = min(targetDays, maxTargetDays)
        }
        .onChange(of: startDate) {
            targetDays = min(targetDays, maxTargetDays)
        }
    }

    private var colorCircles: some View {
        ForEach(HabitForm.presetColors, id: \.1) { label, hex in
            Circle()
                .fill(Color(hex: hex))
                .frame(width: 36, height: 36)
                .overlay(
                    Circle().stroke(
                        Color.primary,
                        lineWidth: selectedColorHex == hex ? 3 : 0
                    )
                )
                .onTapGesture { selectedColorHex = hex }
        }
    }
}
