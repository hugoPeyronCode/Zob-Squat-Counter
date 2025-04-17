//
//  HomeView.swift
//  Zob Squat Counter
//
//  Created by Hugo Peyron on 17/04/2025.
//


import SwiftUI

struct HomeView: View {
    @AppStorage("dailyGoal") private var dailyGoal = 30
    @State private var squatCount: Int = 0
    @State private var isPlusMenuExpanded = false
    @State private var showGoalReachedAnimation = false

    private var goal: UserGoal {
        UserGoal(dailyTarget: dailyGoal, currentCount: squatCount)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                // Date Display
                Text(Date().formatted(date: .complete, time: .omitted))
                    .font(.callout)
                    .fontDesign(.monospaced)
                    .foregroundStyle(.secondary)
                    .padding(.top)

                Spacer()

                // Progress Circle
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(
                            Color.secondary.opacity(0.2),
                            lineWidth: 20
                        )

                    // Progress circle
                    Circle()
                        .trim(from: 0, to: CGFloat(goal.progressPercentage))
                        .stroke(
                            goal.isGoalReached ? Color.green : Color.blue,
                            style: StrokeStyle(
                                lineWidth: 20,
                                lineCap: .round
                            )
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut, value: goal.progressPercentage)

                    // Counter and goal text
                    VStack(spacing: 5) {
                        Text("\(squatCount)")
                            .font(.system(size: 90, weight: .black, design: .monospaced))
                            .contentTransition(.numericText())

                        Text("of \(dailyGoal) squats")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 250, height: 250)
                .padding()
                .overlay {
                    if showGoalReachedAnimation {
                        GoalReachedOverlay()
                            .transition(.scale.combined(with: .opacity))
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    withAnimation {
                                        showGoalReachedAnimation = false
                                    }
                                }
                            }
                    }
                }

                Spacer()

                // Bottom controls
                HStack {
                    Spacer()

                    // Counter Controls
                    HStack(spacing: 60) {
                        // Minus button
                        Button(action: decrementCounter) {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(.red.opacity(0.8))
                                .symbolEffect(.pulse, options: .speed(2), value: squatCount)
                        }
                        .disabled(squatCount <= 0)
                        .opacity(squatCount <= 0 ? 0.3 : 1)

                        // Plus button
                        Button(action: incrementCounter) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(.green.opacity(0.8))
                                .symbolEffect(.pulse, options: .speed(2), value: squatCount)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                    )

                    Spacer()
                }
                .padding(.bottom, 20)
            }
            .padding()
        }
    }

    private func incrementCounter() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            squatCount += 1

            // Check if goal just reached
            if squatCount == dailyGoal {
                withAnimation {
                    showGoalReachedAnimation = true
                }
            }
        }
    }

    private func decrementCounter() {
        guard squatCount > 0 else { return }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            squatCount -= 1
        }
    }
}