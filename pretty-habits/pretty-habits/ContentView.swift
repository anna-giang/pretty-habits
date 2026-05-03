import SwiftData
//
//  ContentView.swift
//  pretty-habits
//
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \HabitEntry.sortOrder) private var habits: [HabitEntry]

    @State private var orderedHabits: [HabitEntry] = []
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
                    header: HabitRingsView(habits: orderedHabits)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                ) {
                    // Habit List.s
                    ForEach(orderedHabits) { habit in
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
                    }.disabled(orderedHabits.count >= MAX_HABITS)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            // ── Add habit sheet ────────────────────────────────────────────
            .sheet(isPresented: $showAddSheet) {
                AddHabitView(habitCount: orderedHabits.count) { newHabit in
                    modelContext.insert(newHabit)
                }
            }
        }.onAppear {
            orderedHabits = habits
        }.onChange(of: habits.map(\.id)) {
            // Only sync when items are added or deleted.
            orderedHabits = habits
        }
    }

    private func deleteHabit(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(habits[index])
            }
            // Renumber remaining habits
            let remaining = orderedHabits.enumerated().filter {
                !offsets.contains($0.offset)
            }
            for (newIndex, (_, habit)) in remaining.enumerated() {
                habit.sortOrder = newIndex
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: HabitEntry.self, inMemory: true)
}
