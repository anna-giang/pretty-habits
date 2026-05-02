//
//  ContentView.swift
//  pretty-habits
//
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var habits: [HabitEntry]

    @State private var showAddSheet = false
    @State private var selectedHabit: HabitEntry? = nil
    @State private var showMarkDoneAlert = false
    @State private var showMarkUndoneAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {

                    // ── Rings ──────────────────────────────────────────────
                    if habits.isEmpty {
                        ContentUnavailableView(
                            "No habits yet",
                            systemImage: "circle.dashed",
                            description: Text("Tap + to add your first habit.")
                        )
                        .padding(.top, 60)
                    } else {
                        HabitRingsView(habits: Array(habits.prefix(5)))
                            .padding(.top, 24)
                    }

                    // ── Habit list ─────────────────────────────────────────
                    VStack(spacing: 12) {
                        ForEach(Array(habits.prefix(5))) { habit in
                            HabitRowButton(habit: habit) {
                                selectedHabit = habit
                                if habit.isDoneToday {
                                    selectedHabit?.unmarkToday()
                                } else {
                                    selectedHabit?.markDoneToday()
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 32)
            }
            .navigationTitle("Habits")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }.disabled(habits.count >= 5)
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

                // Name
                Text(habit.habitName)
                    .font(.body)
                    .foregroundStyle(habit.isDoneToday ? .secondary : .primary)

                Spacer()

                // Progress label
                Text("\(Int(habit.completionPercent))%")
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
                    .fill(habit.isDoneToday
                          ? Color(.systemGray5)
                          : habit.color.opacity(0.1))
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
