//
//  SettingsView.swift
//  Zob Squat Counter
//
//  Created by Hugo Peyron on 17/04/2025.
//


import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("dailyGoal") private var dailyGoal = 30
    @AppStorage("themeName") private var themeName = "Classic"
    @State private var isWidgetSubscriptionActive = false
    @State private var isThemeSubscriptionActive = false

    // Sample theme colors (would be more elaborate in a real app)
    private let themeOptions = ["Classic", "Ocean", "Forest", "Sunset", "Neon"]

    var body: some View {
        NavigationView {
            Form {
                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $isDarkMode)
                        .tint(.blue)
                }

                Section("Goal Settings") {
                    Stepper("Daily Goal: \(dailyGoal) squats", value: $dailyGoal, in: 1...200)

                    HStack {
                        Text("Quick Set:")
                        Spacer()

                        ForEach([10, 30, 50, 100], id: \.self) { num in
                            Button("\(num)") {
                                withAnimation {
                                    dailyGoal = num
                                }
                            }
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.capsule)
                            .tint(dailyGoal == num ? .blue : .secondary)
                        }
                    }
                }

                Section("Premium Features") {
                    VStack(alignment: .leading, spacing: 10) {
                        Toggle("Home Screen Widget", isOn: $isWidgetSubscriptionActive)
                            .tint(.blue)

                        if !isWidgetSubscriptionActive {
                            Label("Unlock with Premium", systemImage: "lock.fill")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Toggle("Custom Themes", isOn: $isThemeSubscriptionActive)
                            .tint(.blue)

                        if !isThemeSubscriptionActive {
                            Label("Unlock with Premium", systemImage: "lock.fill")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if isThemeSubscriptionActive {
                    Section("Theme Selection") {
                        Picker("Theme", selection: $themeName) {
                            ForEach(themeOptions, id: \.self) { theme in
                                Text(theme)
                            }
                        }
                        .pickerStyle(.navigationLink)
                    }
                }

                Section {
                    NavigationLink(destination: Text("About this app").padding()) {
                        Label("About", systemImage: "info.circle")
                    }

                    NavigationLink(destination: Text("Privacy Policy would go here").padding()) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }

                    Button(action: {
                        // Would show upgrade screen
                    }) {
                        Label("Upgrade to Premium", systemImage: "star.fill")
                            .foregroundStyle(.blue)
                    }
                }
            }
            .navigationTitle("Settings")
            .animation(.easeInOut(duration: 0.2), value: isWidgetSubscriptionActive)
            .animation(.easeInOut(duration: 0.2), value: isThemeSubscriptionActive)
        }
    }
}