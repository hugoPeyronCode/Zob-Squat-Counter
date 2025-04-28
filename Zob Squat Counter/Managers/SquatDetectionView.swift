//
//  SquatDetectionView.swift
//  Zob Squat Counter
//
//  Created by Hugo Peyron on 23/04/2025.
//

import SwiftUI

struct SquatDetectionView: View {
  @State private var manager = SquatCounterManager()
  @State private var showSettings = false
  @State private var showInstructions = true
  
  var body: some View {
    VStack(spacing: 25) {
      // En-tête
      VStack(spacing: 5) {
        Text("Test de détection de squats")
          .font(.title2)
          .fontWeight(.bold)
        
        Text("Tenez votre téléphone verticalement et effectuez un squat")
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)
      }
      .padding(.top)
      
      // Indicateur d'inclinaison
      VStack(spacing: 10) {
        Text("Inclinaison actuelle: \(Int(manager.currentPitch))°")
          .fontWeight(.medium)
        
        // Jauge animée
        GeometryReader { geometry in
          ZStack(alignment: .leading) {
            // Barre de fond
            RoundedRectangle(cornerRadius: 8)
              .fill(Color.secondary.opacity(0.2))
              .frame(height: 16)
            
            // Barre de progression
            RoundedRectangle(cornerRadius: 8)
              .fill(gaugeColor)
              .frame(width: min(CGFloat(manager.currentPitch) * 2, geometry.size.width), height: 16)
          }
        }
        .frame(height: 16)
        
        // Indicateurs de seuil
        HStack {
          Spacer()
          // Marqueur de seuil de squat
          VStack(spacing: 2) {
            Text("Squat")
              .font(.caption)
              .foregroundStyle(.secondary)
            Rectangle()
              .fill(.orange)
              .frame(width: 2, height: 10)
          }
          .offset(x: -2)
          .position(x: min(CGFloat(manager.squatAngleThreshold) * 2, UIScreen.main.bounds.width - 40), y: 0)
        }
        .frame(height: 20)
      }
      .padding()
      .background(Color.secondary.opacity(0.05))
      .cornerRadius(16)
      .padding(.horizontal)
      
      // Compteur de squats
      VStack(spacing: 15) {
        Text("SQUATS")
          .font(.headline)
          .foregroundStyle(.secondary)
        
        Text("\(manager.squatCount)")
          .font(.system(size: 80, weight: .bold, design: .rounded))
          .contentTransition(.numericText(value: Double(manager.squatCount)))
          .animation(.spring(response: 0.3, dampingFraction: 0.7), value: manager.squatCount)
        
        // Bouton de réinitialisation
        Button(action: {
          withAnimation {
            manager.resetCount()
          }
        }) {
          Label("Réinitialiser", systemImage: "arrow.counterclockwise")
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
            .background(Color.red.opacity(0.1))
            .cornerRadius(8)
        }
        .padding(.bottom, 10)
      }
      .padding()
      .frame(maxWidth: .infinity)
      .background(Color.secondary.opacity(0.05))
      .cornerRadius(16)
      .padding(.horizontal)
      
      // Indicateur d'état
      HStack(spacing: 12) {
        Circle()
          .fill(manager.isMonitoring ? .green : .gray)
          .frame(width: 10, height: 10)
        
        Text(manager.statusMessage)
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .animation(.easeInOut, value: manager.statusMessage)
      }
      .padding(.vertical, 10)
      .padding(.horizontal, 20)
      .background(Color.secondary.opacity(0.05))
      .cornerRadius(20)
      
      Spacer()
      
      // Contrôles inférieurs
      HStack(spacing: 20) {
        Button(action: {
          if manager.isMonitoring {
            manager.stopMonitoring()
          } else {
            manager.startMonitoring()
          }
        }) {
          Label(manager.isMonitoring ? "Arrêter" : "Démarrer",
                systemImage: manager.isMonitoring ? "stop.circle.fill" : "play.circle.fill")
          .font(.headline)
          .padding()
          .frame(maxWidth: .infinity)
          .background(manager.isMonitoring ? Color.red.opacity(0.2) : Color.green.opacity(0.2))
          .foregroundColor(manager.isMonitoring ? .red : .green)
          .cornerRadius(12)
        }
        
        Button(action: {
          showSettings.toggle()
        }) {
          Label("Paramètres", systemImage: "slider.horizontal.3")
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue.opacity(0.2))
            .foregroundColor(.blue)
            .cornerRadius(12)
        }
      }
      .padding(.horizontal)
      .padding(.bottom)
    }
    .sheet(isPresented: $showSettings) {
      settingsView
    }
    .sheet(isPresented: $showInstructions) {
      instructionsView
    }
    .onAppear {
      // Démarrage automatique de la surveillance
      if !manager.isMonitoring {
        manager.startMonitoring()
      }
    }
    .onDisappear {
      // Arrêt de la surveillance quand la vue disparaît
      manager.stopMonitoring()
    }
  }
  
  // MARK: - Vues auxiliaires
  
  private var gaugeColor: Color {
    if manager.isInSquatPosition {
      return .orange
    } else if manager.currentPitch > manager.squatAngleThreshold {
      return .red
    } else {
      return .green
    }
  }
  
  private var settingsView: some View {
    NavigationView {
      Form {
        Section(header: Text("Paramètres de détection")) {
          VStack(alignment: .leading, spacing: 8) {
            HStack {
              Text("Seuil d'angle pour squat")
              Spacer()
              Text("\(Int(manager.squatAngleThreshold))°")
                .foregroundColor(.secondary)
            }
            
            Slider(value: $manager.squatAngleThreshold, in: 20...70, step: 5)
              .tint(.blue)
          }
          
          VStack(alignment: .leading, spacing: 8) {
            HStack {
              Text("Seuil d'angle pour retour")
              Spacer()
              Text("\(Int(manager.returnAngleThreshold))°")
                .foregroundColor(.secondary)
            }
            
            Slider(value: $manager.returnAngleThreshold, in: 5...30, step: 5)
              .tint(.blue)
          }
        }
        
        Section(header: Text("Informations")) {
          Text("Angle de squat: Inclinaison nécessaire pour détecter un squat")
            .font(.caption)
          
          Text("Angle de retour: Inclinaison pour revenir de la position squat")
            .font(.caption)
          
          Text("Un angle de squat plus élevé = des squats plus profonds nécessaires. Un angle de retour plus bas = plus facile de compléter un squat.")
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.top, 8)
        }
      }
      .navigationTitle("Paramètres de détection")
      .navigationBarItems(trailing: Button("Terminé") {
        showSettings = false
      })
    }
  }
  
  private var instructionsView: some View {
    VStack(spacing: 25) {
      Image(systemName: "figure.strengthtraining.traditional")
        .font(.system(size: 60))
        .foregroundColor(.blue)
        .padding(.top, 40)
      
      Text("Comment utiliser le détecteur de squats")
        .font(.title2)
        .fontWeight(.bold)
      
      VStack(alignment: .leading, spacing: 20) {
        instructionStep(number: 1, title: "Tenez votre téléphone",
                        description: "Gardez votre téléphone dans votre main ou poche, avec l'écran face à vous")
        
        instructionStep(number: 2, title: "Effectuez un squat",
                        description: "Pliez vos genoux tout en gardant votre dos droit")
        
        instructionStep(number: 3, title: "Revenez en position debout",
                        description: "Redressez-vous pour compléter le squat")
        
        instructionStep(number: 4, title: "Vérifiez le compteur",
                        description: "L'application comptera chaque squat complet")
      }
      .padding(.horizontal, 20)
      
      Spacer()
      
      Button(action: {
        showInstructions = false
      }) {
        Text("Compris!")
          .fontWeight(.bold)
          .foregroundColor(.white)
          .frame(width: 200)
          .padding()
          .background(Color.blue)
          .cornerRadius(12)
      }
      .padding(.bottom, 40)
    }
  }
  
  private func instructionStep(number: Int, title: String, description: String) -> some View {
    HStack(alignment: .top, spacing: 15) {
      Text("\(number)")
        .font(.headline)
        .foregroundColor(.white)
        .frame(width: 28, height: 28)
        .background(Circle().fill(Color.blue))
      
      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .font(.headline)
        
        Text(description)
          .font(.subheadline)
          .foregroundColor(.secondary)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
  }
}

#Preview {
  SquatDetectionView()
}
