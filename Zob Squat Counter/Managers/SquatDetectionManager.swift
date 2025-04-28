// SquatCounterManager.swift
// Zob Squat Counter
//
// Created on 18/04/2025


import Foundation
import CoreMotion
import SwiftUI

@Observable
class SquatCounterManager {
    // CoreMotion manager pour accéder aux capteurs
    private let motionManager = CMMotionManager()

    // Paramètres de détection
    var squatAngleThreshold: Double = 45.0 // Angle en degrés pour détecter un squat
    var returnAngleThreshold: Double = 10.0 // Angle en degrés pour revenir à la position debout

    // État actuel
    var currentPitch: Double = 0.0
    var squatCount: Int = 0
    var isInSquatPosition: Bool = false

    // Informations d'état
    var statusMessage: String = "Prêt"
    var isMonitoring: Bool = false

    // Timing pour éviter les faux positifs
    private var lastSquatTime: Date = Date.distantPast
    private let minimumSquatInterval: TimeInterval = 1.0 // Temps minimum entre deux squats

    init() {
        setupMotionManager()
    }

    private func setupMotionManager() {
        guard motionManager.isDeviceMotionAvailable else {
            statusMessage = "Motion capteur non disponible"
            return
        }

        motionManager.deviceMotionUpdateInterval = 0.1
    }

    func startMonitoring() {
        guard motionManager.isDeviceMotionAvailable else { return }

        if !motionManager.isDeviceMotionActive {
            statusMessage = "Surveillance démarrée"
            isMonitoring = true

            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, error) in
                guard let self = self, let motion = motion else {
                    if let error = error {
                        self?.statusMessage = "Erreur: \(error.localizedDescription)"
                    }
                    return
                }

                self.processMotionData(motion)
            }
        }
    }

    func stopMonitoring() {
        motionManager.stopDeviceMotionUpdates()
        isMonitoring = false
        statusMessage = "Surveillance arrêtée"
    }

    func resetCount() {
        squatCount = 0
        statusMessage = "Compteur remis à zéro"
    }

    private func processMotionData(_ motion: CMDeviceMotion) {
        // Obtenir l'inclinaison verticale (pitch) en degrés
        let pitchInRadians = motion.attitude.pitch
        let pitchInDegrees = pitchInRadians * 180.0 / .pi

        // Mise à jour de l'inclinaison (valeur absolue pour simplifier)
        currentPitch = abs(pitchInDegrees)

        // Détecter le squat
        detectSquat()

        // Mise à jour du message d'état
        updateStatusMessage()
    }

    private func detectSquat() {
        let now = Date()

        // Détection de l'entrée en position squat
        if !isInSquatPosition && currentPitch > squatAngleThreshold {
            isInSquatPosition = true
            statusMessage = "Position squat détectée"
        }
        // Détection de la fin d'un squat
        else if isInSquatPosition && currentPitch < returnAngleThreshold {
            // Vérification du temps minimum entre deux squats
            if now.timeIntervalSince(lastSquatTime) >= minimumSquatInterval {
                isInSquatPosition = false
                squatCount += 1
                lastSquatTime = now
                statusMessage = "Squat complété! Total: \(squatCount)"
            } else {
                // Mouvement trop rapide, on ne compte pas
                isInSquatPosition = false
                statusMessage = "Mouvement trop rapide"
            }
        }
    }

    private func updateStatusMessage() {
        // Mise à jour du message uniquement en position stable
        if !statusMessage.contains("détectée") && !statusMessage.contains("complété") {
            if isInSquatPosition {
                statusMessage = "En position squat"
            } else if currentPitch < squatAngleThreshold {
                statusMessage = "Position debout"
            }
        }
    }

    deinit {
        stopMonitoring()
    }
}
