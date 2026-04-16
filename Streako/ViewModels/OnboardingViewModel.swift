//
//  OnboardingViewModel.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-16.
//

import Foundation
import Combine
import SwiftUI

/// Single source of truth for the first-run tutorial. Drives which step is
/// currently visible, handles skip/next/back, and persists completion per
/// Firebase UID so switching accounts on one device re-shows onboarding for
/// the new user.
final class OnboardingViewModel: ObservableObject {

    // MARK: - Published state

    /// The currently displayed step, or `nil` when the tutorial is not active.
    @Published private(set) var currentStep: OnboardingStep?

    /// True when the overlay should be rendered.
    @Published private(set) var isActive: Bool = false

    // MARK: - Private state

    private var uid: String?
    private var hasAutoStartedForCurrentUID: Bool = false

    private static let persistenceKeyPrefix = "streako.onboarding.completed."
    private static let anonymousKey = persistenceKeyPrefix + "anonymous"

    // MARK: - Lifecycle

    /// Call whenever the signed-in user changes. Auto-starts the tutorial
    /// once per UID if it has not been completed.
    func bind(uid: String?) {
        let changed = uid != self.uid
        self.uid = uid

        if changed {
            hasAutoStartedForCurrentUID = false
            // If the user signed out mid-tutorial, close the overlay.
            if uid == nil, isActive {
                isActive = false
                currentStep = nil
            }
        }

        guard let uid, !hasAutoStartedForCurrentUID else { return }
        hasAutoStartedForCurrentUID = true

        if !isCompleted(forUID: uid) {
            start()
        }
    }

    // MARK: - Public controls

    /// Start (or restart) the tutorial at the welcome step.
    func start() {
        currentStep = .welcome
        isActive = true
    }

    /// Advance to the next step, or complete if already on the last one.
    func next() {
        guard let current = currentStep else { return }
        guard let nextStep = OnboardingStep(rawValue: current.rawValue + 1) else {
            complete()
            return
        }
        currentStep = nextStep
        if nextStep == .done {
            // `.done` is still shown as a confirmation card; the user dismisses it.
        }
    }

    /// Step backward. No-op on the first step.
    func back() {
        guard let current = currentStep,
              let previous = OnboardingStep(rawValue: current.rawValue - 1) else { return }
        currentStep = previous
    }

    /// Mark onboarding as complete and dismiss the overlay.
    func complete() {
        if let uid {
            UserDefaults.standard.set(true, forKey: Self.persistenceKey(forUID: uid))
        } else {
            UserDefaults.standard.set(true, forKey: Self.anonymousKey)
        }
        isActive = false
        currentStep = nil
    }

    /// Dismiss the overlay permanently. Persists completion so it does not
    /// re-appear on next launch.
    func skip() {
        complete()
    }

    /// Replay the tutorial from the beginning. Wipes the per-UID completion
    /// flag so it won't auto-dismiss mid-flow.
    func restart() {
        if let uid {
            UserDefaults.standard.removeObject(forKey: Self.persistenceKey(forUID: uid))
        } else {
            UserDefaults.standard.removeObject(forKey: Self.anonymousKey)
        }
        hasAutoStartedForCurrentUID = true
        start()
    }

    // MARK: - External event hooks

    /// Called when the habit list grows from 0 → 1+. Drives the automatic
    /// advance for the `.addHabit` step.
    func habitListDidGrow() {
        guard isActive, currentStep?.advance == .onHabitCreated else { return }
        next()
    }

    /// Called when any habit becomes completed today. Drives automatic
    /// advance for the `.completeHabit` step. Works regardless of which
    /// screen triggered the completion, fixing the bug where completing
    /// from `HabitDetailView` left the coach mark stranded.
    func anyHabitCompletedToday() {
        guard isActive, currentStep?.advance == .onHabitCompleted else { return }
        next()
    }

    // MARK: - Persistence helpers

    private static func persistenceKey(forUID uid: String) -> String {
        persistenceKeyPrefix + uid
    }

    private func isCompleted(forUID uid: String) -> Bool {
        UserDefaults.standard.bool(forKey: Self.persistenceKey(forUID: uid))
    }

    // MARK: - Derived values for the overlay

    /// "Step 2 of 6" — VoiceOver reads this. Returns `nil` on `.done`.
    func progressDescription(for step: OnboardingStep) -> String? {
        guard let index = step.visibleIndex else { return nil }
        return "Step \(index + 1) of \(OnboardingStep.visibleSteps.count)"
    }
}
