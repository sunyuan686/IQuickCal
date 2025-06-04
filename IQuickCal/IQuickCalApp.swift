//
//  IQuickCalApp.swift
//  IQuickCal
//
//  Created by sunyuan on 2025/6/4.
//

import SwiftUI
import SwiftData

@main
struct IQuickCalApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Question.self,
            PracticeSession.self,
            Answer.self,
            WrongAnswer.self,
            UserPreferences.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}

