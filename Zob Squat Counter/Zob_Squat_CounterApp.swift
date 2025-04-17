//
//  Zob_Squat_CounterApp.swift
//  Zob Squat Counter
//
//  Created by Hugo Peyron on 17/04/2025.
//

import SwiftUI

@main
struct ZobSquatCounterApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}

#Preview(body: {
  MainTabView()
})
