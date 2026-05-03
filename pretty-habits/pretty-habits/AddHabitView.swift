//
//  AddHabitView.swift
//  pretty-habits
//
import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) private var dismiss
    var onAdd: (HabitEntry) -> Void

    @State private var name: String = ""
    @State private var startDate: Date = Date()
    // Default end date to 1 month after today.
    @State private var endDate: Date =
        Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    @State private var selectedColorHex: String = "FF6B6B"
    @State private var targetDays: Int = 0
    
    // Max target days will be the number of days between the specified calendar dates.
    private var maxTargetDays: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate)
            .day ?? 1
    }

    private let presetColors: [(String, String)] = [
        ("Coral", "FF6B6B"),
        ("Sky", "4ECDC4"),
        ("Gold", "FFD93D"),
        ("Lavender", "A78BFA"),
        ("Mint", "6BCB77"),
    ]

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
                        displayedComponents: .date
                    )
                }
                Section("Target days") {
                    targetDaysPicker
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
                            targetDays: targetDays
                        )
                        onAdd(entry)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }

    private var targetDaysPicker: some View {
        Picker("Target days", selection: $targetDays) {
            ForEach(1...max(1, maxTargetDays), id: \.self) { day in
                Text("\(day) days").tag(day)
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
        ForEach(presetColors, id: \.1) { label, hex in
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
