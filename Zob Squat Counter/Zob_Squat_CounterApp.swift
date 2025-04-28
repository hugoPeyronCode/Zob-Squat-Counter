//
//  Zob_Squat_CounterApp.swift
//  Zob Squat Counter
//
//  Created by Hugo Peyron on 17/04/2025.
//

import SwiftUI
import SwiftData

@main
struct ZobSquatCounterApp: App {
  @AppStorage("isDarkMode") private var isDarkMode = false

  var sharedModelContainer: ModelContainer = {
    do {
      let schema = Schema([SquatDay.self, UserStats.self])
      let modelConfiguration = ModelConfiguration(schema: schema)
      return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
      // In a real app, you would handle this error properly
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()

  var body: some Scene {
    WindowGroup {
      SquatDetectionView()
//      MainTabView()
//        .preferredColorScheme(isDarkMode ? .dark : .light)
//        .modelContainer(sharedModelContainer)
    }
  }
}
