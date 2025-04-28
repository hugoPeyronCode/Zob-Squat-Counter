////
////  SquatLiveActivityManager.swift
////  SquatWidgetExtensionExtension
////
////  Created by Hugo Peyron on 22/04/2025.
////
//
//import Foundation
//import ActivityKit
//import SwiftUI
//
//class SquatLiveActivityManager {
//    static let shared = SquatLiveActivityManager()
//
//    private var activity: Activity<SquatActivityAttributes>?
//
//    // Démarrer une nouvelle Live Activity
//    func startActivity(initialCount: Int) {
//        guard Activity<SquatActivityAttributes>.isSupported else { return }
//
//        // Récupérer l'objectif quotidien
//        let dailyGoal = UserDefaults.standard.integer(forKey: "dailyGoal")
//        let effectiveGoal = dailyGoal > 0 ? dailyGoal : 30
//
//        let attributes = SquatActivityAttributes(name: "Squat Counter")
//        let state = SquatActivityAttributes.ContentState(
//            count: initialCount,
//            goal: effectiveGoal,
//            startTime: Date(),
//            isActive: true
//        )
//
//        do {
//            activity = try Activity.request(
//                attributes: attributes,
//                contentState: state,
//                pushType: nil
//            )
//        } catch {
//            print("Error starting squat activity: \(error)")
//        }
//    }
//
//    // Mettre à jour la Live Activity existante
//    func updateActivity(count: Int) {
//        guard let activity = activity else { return }
//
//        // Créer le nouvel état
//        let updatedState = SquatActivityAttributes.ContentState(
//            count: count,
//            goal: activity.contentState.goal,
//            startTime: activity.contentState.startTime,
//            isActive: true
//        )
//
//        // Mettre à jour l'activité
//        Task {
//            await activity.update(using: updatedState)
//        }
//    }
//
//    // Terminer la Live Activity
//    func endActivity(finalCount: Int) {
//        guard let activity = activity else { return }
//
//        // Créer l'état final
//        let finalState = SquatActivityAttributes.ContentState(
//            count: finalCount,
//            goal: activity.contentState.goal,
//            startTime: activity.contentState.startTime,
//            isActive: false
//        )
//
//        // Terminer l'activité
//        Task {
//            await activity.end(using: finalState, dismissalPolicy: .after(Date(timeIntervalSinceNow: 15*60)))
//        }
//
//        self.activity = nil
//    }
//}
