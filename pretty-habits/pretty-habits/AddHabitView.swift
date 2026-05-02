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
    @State private var endDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    @State private var selectedColorHex: String = "FF6B6B"

    private let presetColors: [(String, String)] = [
        ("Coral",   "FF6B6B"),
        ("Sky",     "4ECDC4"),
        ("Gold",    "FFD93D"),
        ("Lavender","A78BFA"),
        ("Mint",    "6BCB77"),
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Habit") {
                    TextField("Name (e.g. Walk 10k steps)", text: $name)
                }
                Section("Schedule") {
                    DatePicker("Start", selection: $startDate, displayedComponents: .date)
                    DatePicker("End",   selection: $endDate,   displayedComponents: .date)
                }
                Section("Colour") {
                    HStack(spacing: 16) {
                        ForEach(presetColors, id: \.1) { label, hex in
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Circle().stroke(Color.primary, lineWidth: selectedColorHex == hex ? 3 : 0)
                                )
                                .onTapGesture { selectedColorHex = hex }
                        }
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
                            endDate: endDate
                        )
                        onAdd(entry)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
