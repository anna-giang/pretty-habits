import SwiftData
//
//  ContentView.swift
//  pretty-habits
//
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var habits: [HabitEntry]

    @State private var showAddSheet = false
    @State private var selectedHabit: HabitEntry? = nil
    @State private var showMarkDoneAlert = false
    @State private var showMarkUndoneAlert = false

    let MAX_HABITS = 5

    var body: some View {
        NavigationStack {
            List {
                Section(
                    // Rings.
                    header: HabitRingsView(habits: Array(habits.prefix(5)))
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                ) {
                    // Habit List.
                    ForEach(habits) { habit in
                        HabitRowButton(habit: habit) {
                            selectedHabit = habit
                            if habit.isDoneToday {
                                selectedHabit?.unmarkToday()
                            } else {
                                selectedHabit?.markDoneToday()
                            }
                        }
                    }
                    .onDelete(perform: deleteHabit)
                }
            }
            .navigationTitle("Habits")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }.disabled(habits.count >= MAX_HABITS)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            // ── Add habit sheet ────────────────────────────────────────────
            .sheet(isPresented: $showAddSheet) {
                AddHabitView { newHabit in
                    modelContext.insert(newHabit)
                }
            }
        }
    }

    private func deleteHabit(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(habits[index])
            }
        }
    }
}

// ── Habit row button ───────────────────────────────────────────────────────────
struct HabitRowButton: View {
    let habit: HabitEntry
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Colour dot (grayscale when done today)
                Circle()
                    .fill(habit.isDoneToday ? Color.gray : habit.color)
                    .frame(width: 14, height: 14)

                // Habit name and date range
                VStack(alignment: HorizontalAlignment.leading, spacing: 8) {
                    Text(habit.habitName)
                        .font(.body)
                        .foregroundStyle(
                            habit.isDoneToday ? .secondary : .primary
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
                        .foregroundStyle(habit.color.opacity(0.5))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        habit.isDoneToday
                            ? Color(.systemGray5)
                            : habit.color.opacity(0.1)
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.25), value: habit.isDoneToday)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: HabitEntry.self, inMemory: true)
}
