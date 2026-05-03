//
//  pretty_habitsApp.swift
//  pretty-habits entry point.
//

import SwiftData
import SwiftUI

@main
struct pretty_habitsApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            HabitEntry.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
