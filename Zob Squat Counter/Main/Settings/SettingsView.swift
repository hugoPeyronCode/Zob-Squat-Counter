//
//  SettingsView.swift
//  Zob Squat Counter
//
//  Created by Hugo Peyron on 17/04/2025.
//

import SwiftUI
import SwiftData
import WidgetKit

struct SettingsView: View {
  @State private var selectedMode = "circle.righthalf.filled"
  @State private var lightModes = ["sun.max.fill", "circle.righthalf.filled", "moon.fill"]

  @AppStorage("isDarkMode") private var isDarkMode = false
  @AppStorage("isSystemMode") private var isSystemMode = true
  @AppStorage("dailyGoal") private var dailyGoal = 30
  @AppStorage("themeName") private var themeName = "Classic"
  @AppStorage("isWidgetSubscriptionActive") private var isWidgetSubscriptionActive = false

  // Access to the model context
  @Environment(\.modelContext) private var modelContext

  // Sample theme colors (would be more elaborate in a real app)
  private let themeOptions = ["Classic", "Ocean", "Forest", "Sunset", "Neon"]

  var body: some View {
    NavigationView {
      Form {
        Section("Appearance") {
          DarkLightMode
        }

        Section("Goal Settings") {
          Stepper("Daily Goal: \(dailyGoal) squats", value: $dailyGoal, in: 1...200)
            .onChange(of: dailyGoal) { _, _ in
              // Update widgets when goal changes
              if isWidgetSubscriptionActive {
                WidgetCenter.shared.reloadAllTimelines()
                SquatDataManager.updateWidgetData(context: modelContext)
              }
            }

          HStack {
            Text("Quick Set")
            Spacer()

            ForEach([10, 30, 50, 100], id: \.self) { num in
              Button("\(num)") {
                withAnimation {
                  dailyGoal = num
                  // Update widgets
                  if isWidgetSubscriptionActive {
                    WidgetCenter.shared.reloadAllTimelines()
                    SquatDataManager.updateWidgetData(context: modelContext)
                  }
                }
              }
              .buttonStyle(.bordered)
              .buttonBorderShape(.capsule)
              .foregroundStyle(dailyGoal == num ? .primary : .secondary)
            }
          }
        }

        Section("Premium") {
          VStack(alignment: .leading, spacing: 10) {
            Toggle("Home Screen Widget", isOn: $isWidgetSubscriptionActive)
              .tint(.primary)
              .onChange(of: isWidgetSubscriptionActive) { _, newValue in
                handleWidgetToggle(isEnabled: newValue)
              }

            if !isWidgetSubscriptionActive {
              Label("Unlock with Premium", systemImage: "lock.fill")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.leading, 28)
            } else {
              widgetOptionsSection
            }
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
              .foregroundStyle(.indigo)
          }
        }
        .foregroundStyle(.primary)
      }
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.inline)
      .animation(.easeInOut(duration: 0.2), value: isWidgetSubscriptionActive)
      .preferredColorScheme(isSystemMode ? nil : (isDarkMode ? .dark : .light))
      .onAppear {
        // Initialize the selected mode based on current settings
        if isSystemMode {
          selectedMode = "circle.righthalf.filled"
        } else {
          selectedMode = isDarkMode ? "moon.fill" : "sun.max.fill"
        }
      }
    }
    .fontDesign(.monospaced)
  }

  // MARK: - Widget Settings

  @ViewBuilder
  private var widgetOptionsSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Widget Options")
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(.top, 4)

      Button {
        // Refresh widgets
        WidgetCenter.shared.reloadAllTimelines()
      } label: {
        Label("Refresh Widgets", systemImage: "arrow.clockwise")
          .font(.footnote)
      }

      Button {
        // Open system widget configuration
        if let url = URL(string: "widgetkit://configure") {
          UIApplication.shared.open(url)
        }
      } label: {
        Label("Configure Widgets", systemImage: "square.grid.2x2")
          .font(.footnote)
      }
    }
    .padding(.vertical, 4)
    .padding(.leading, 28)
  }

  // Direct function in the view where modelContext is accessible
  private func handleWidgetToggle(isEnabled: Bool) {
    if isEnabled {
      // Initialize widget data when feature enabled
      SquatDataManager.updateWidgetData(context: modelContext)
    }

    // Always reload widget timelines when toggled
    WidgetCenter.shared.reloadAllTimelines()
  }
}

extension SettingsView {
  var DarkLightMode: some View {
    HStack {
      Image(systemName: selectedMode)
        .font(.system(size: 18))
        .frame(width: 24)

      Text(returnIconForDarkLightMode())
        .bold()
      Spacer()
      Picker("Select Light Mode", selection: $selectedMode) {
        ForEach(lightModes, id: \.self) { mode in
          Image(systemName: mode)
            .tag(mode)
        }
      }
      .pickerStyle(.segmented)
      .frame(width: 150)
      .onChange(of: selectedMode) { _, newValue in
        updateAppearanceMode(mode: newValue)
      }
    }
  }

  func returnIconForDarkLightMode(mode: String? = nil) -> String {
    let modeToCheck = mode ?? selectedMode
    switch modeToCheck {
    case "moon.fill":
      return "Dark"
    case "circle.righthalf.filled":
      return "System"
    case "sun.max.fill":
      return "Light"
    default:
      return "System"
    }
  }

  func updateAppearanceMode(mode: String) {
    switch mode {
    case "moon.fill":
      isDarkMode = true
      isSystemMode = false
    case "sun.max.fill":
      isDarkMode = false
      isSystemMode = false
    case "circle.righthalf.filled":
      isSystemMode = true
    default:
      isSystemMode = true
    }
  }
}

#Preview {
  SettingsView()
    .previewWithData()
}
