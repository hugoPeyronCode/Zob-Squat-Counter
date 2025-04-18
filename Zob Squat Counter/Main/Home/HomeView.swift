//
//  HomeView.swift
//  Zob Squat Counter
//
//  Created by Hugo Peyron on 17/04/2025.
//

import SwiftUI
import SwiftData

struct HomeView: View {
  @AppStorage("dailyGoal") private var dailyGoal = 30
  @Environment(\.modelContext) private var modelContext

  @State private var isPlusMenuExpanded = false
  @State private var showGoalReachedAnimation = false
  @State private var goalAnimationScale = 0.7
  @State private var isControlExpanded = false
  @State private var todaySquats: SquatDay?

  private var squatCount: Int {
    todaySquats?.count ?? 0
  }

  private var goal: UserGoal {
    UserGoal(dailyTarget: dailyGoal, currentCount: squatCount)
  }

  var body: some View {
    ZStack {
      VStack(spacing: 30) {
        dateDisplayView
        Spacer()
        progressCircleView
        Spacer()
        counterControlsView
      }
      .padding()
    }
    .onAppear {
      loadTodayData()
    }
  }

  // MARK: - Data Loading

  private func loadTodayData() {
    todaySquats = SquatDataManager.fetchTodaySquats(context: modelContext)
  }

  private func updateSquatCount(_ newCount: Int) {
    if todaySquats == nil {
      todaySquats = SquatDataManager.fetchTodaySquats(context: modelContext)
    }

    let previousCount = todaySquats?.count ?? 0
    todaySquats?.count = newCount

    // Update statistics
    SquatDataManager.updateStats(
      context: modelContext,
      withNewSquatCount: newCount,
      previousCount: previousCount
    )
  }

  private var dateDisplayView: some View {
    VStack(spacing: 10) {
      Text(Date().formatted(date: .complete, time: .omitted))
        .font(.callout)
        .fontDesign(.monospaced)
        .foregroundStyle(.secondary)
        .padding(.top)

      Image(systemName: "checkmark")
        .foregroundStyle(goal.isGoalReached ? .green : .clear)
    }
  }

  private var progressCircleView: some View {
    ZStack {
      backgroundCircle
      progressArc
      counterText
    }
    .frame(width: 250, height: 250)
    .padding()
  }

  private var backgroundCircle: some View {
    Circle()
      .stroke(
        Color.secondary.opacity(0.2),
        lineWidth: 2
      )
  }

  private var progressArc: some View {
    Circle()
      .trim(from: 0, to: CGFloat(goal.progressPercentage))
      .stroke(
        goal.isGoalReached ? .green : .primary,
        style: StrokeStyle(
          lineWidth: 4,
          lineCap: .round
        )
      )
      .rotationEffect(.degrees(-90))
      .animation(.easeInOut, value: goal.progressPercentage)
  }

  private var counterText: some View {
    VStack(spacing: 5) {
      Text("\(squatCount)")
        .font(.system(size: 90, weight: .black, design: .monospaced))
        .contentTransition(.numericText())

      Text("of \(dailyGoal) squats")
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
  }

  private var counterControlsView: some View {
    HStack {
      Spacer()

      Button(action: {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
          isControlExpanded.toggle()
        }
      }) {
        ZStack {
          // Background
          RoundedRectangle(cornerRadius: 20)
            .fill(.ultraThinMaterial)

          // Content
          HStack(spacing: isControlExpanded ? 60 : 0) {
            if isControlExpanded {
              minusButton
                .transition(.asymmetric(
                  insertion: .scale(scale: 0.7).combined(with: .opacity),
                  removal: .scale(scale: 0.5).combined(with: .opacity)
                ))
            }

            Image(systemName: isControlExpanded ? "xmark" : "plus")
              .font(.title2)
              .foregroundStyle(.primary)
              .frame(width: 44, height: 44)
              .contentShape(Rectangle())

            if isControlExpanded {
              plusButton
                .transition(.asymmetric(
                  insertion: .scale(scale: 0.7).combined(with: .opacity),
                  removal: .scale(scale: 0.5).combined(with: .opacity)
                ))
            }
          }
          .padding()
        }
      }
      .buttonStyle(PlainButtonStyle())
      .frame(width: isControlExpanded ? 220 : 80, height: 80)

      Spacer()
    }
    .padding(.bottom, 20)
  }

  private var minusButton: some View {
    Button(action: decrementCounter) {
      Image(systemName: "minus.circle.fill")
        .font(.system(size: 44))
        .foregroundStyle(.primary)
        .opacity(squatCount <= 0 ? 0.3 : 1)
        .symbolEffect(.pulse, options: .speed(2), value: squatCount)
    }
    .disabled(squatCount <= 0)
  }

  private var plusButton: some View {
    Button(action: incrementCounter) {
      Image(systemName: "plus.circle.fill")
        .font(.system(size: 44))
        .foregroundStyle(.primary)
        .symbolEffect(.pulse, options: .speed(2), value: squatCount)
    }
  }

  private func incrementCounter() {
    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
      updateSquatCount(squatCount + 1)

      if squatCount == dailyGoal {
        showGoalReachedAnimation = true
      }
    }
  }

  private func decrementCounter() {
    guard squatCount > 0 else { return }
    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
      updateSquatCount(squatCount - 1)
    }
  }
}

#Preview("Home") {
    HomeView()
        .previewWithData()
}
