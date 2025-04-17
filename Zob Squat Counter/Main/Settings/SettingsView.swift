//
//  SettingsView.swift
//  Zob Squat Counter
//
//  Created by Hugo Peyron on 17/04/2025.
//

import SwiftUI

struct SettingsView: View {
  @State private var selectedMode = "circle.righthalf.filled"
  @State private var lightModes = ["sun.max.fill", "circle.righthalf.filled", "moon.fill"]
  
  @AppStorage("isDarkMode") private var isDarkMode = false
  @AppStorage("isSystemMode") private var isSystemMode = true
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
          DarkLightMode
        }
        
        Section("Goal Settings") {
          
          
          Stepper("Daily Goal: \(dailyGoal) squats", value: $dailyGoal, in: 1...200)
          
          HStack {
            Text("Quick Set")
            Spacer()
            
            ForEach([10, 30, 50, 100], id: \.self) { num in
              Button("\(num)") {
                withAnimation {
                  dailyGoal = num
                }
              }
              .buttonStyle(.bordered)
              .buttonBorderShape(.capsule)
              .foregroundStyle(dailyGoal == num ? .primary : .secondary)
            }
          }
        }
        
        Section("Premium Features") {
          VStack(alignment: .leading, spacing: 10) {
            
            Toggle("Home Screen Widget", isOn: $isWidgetSubscriptionActive)
              .tint(.primary)
            
            if !isWidgetSubscriptionActive {
              Label("Unlock with Premium", systemImage: "lock.fill")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.leading, 28)
            }
          }
          
          VStack(alignment: .leading, spacing: 10) {
            Toggle("Custom Themes", isOn: $isThemeSubscriptionActive)
              .tint(.primary)
            
            if !isThemeSubscriptionActive {
              Label("Unlock with Premium", systemImage: "lock.fill")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.leading, 28)
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
              .foregroundStyle(.indigo)
          }
        }
        .foregroundStyle(.primary)
      }
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.inline)
      .animation(.easeInOut(duration: 0.2), value: isWidgetSubscriptionActive)
      .animation(.easeInOut(duration: 0.2), value: isThemeSubscriptionActive)
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
}
