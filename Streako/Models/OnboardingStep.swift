//
//  OnboardingStep.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-16.
//

import SwiftUI

/// Anchors that target views register, so the onboarding overlay can spotlight them
/// via `anchorPreference` without any hardcoded coordinates.
enum OnboardingAnchor: String, Hashable {
    case addHabitButton
    case firstHabitCard
    case firstCompleteButton
    case statsTab
    case settingsTab
    case remindersToggle
    case replayTutorial
}

/// Every guided step in the first-run tutorial.
///
/// Reordering: change the `Int` raw values. Adding a step: insert a case and
/// bump subsequent raw values (or use a different `rawValue` scheme). The VM
/// walks linearly through `rawValue` and consults `advance` to decide how
/// each step ends.
enum OnboardingStep: Int, CaseIterable, Identifiable {
    case welcome = 0
    case addHabit
    case habitCard
    case completeHabit
    case stats
    case settings
    case done

    var id: Int { rawValue }

    /// Visible steps (progress dots). `.done` is a confirmation screen, not
    /// counted in "step x of y".
    static var visibleSteps: [OnboardingStep] {
        allCases.filter { $0 != .done }
    }

    /// Zero-based index among `visibleSteps`, or `nil` for `.done`.
    var visibleIndex: Int? {
        Self.visibleSteps.firstIndex(of: self)
    }

    /// Which UI element (if any) the overlay should spotlight.
    var anchor: OnboardingAnchor? {
        switch self {
        case .addHabit: return .addHabitButton
        case .habitCard: return .firstHabitCard
        case .completeHabit: return .firstCompleteButton
        case .stats: return .statsTab
        case .settings: return .settingsTab
        case .welcome, .done: return nil
        }
    }

    enum Advance {
        /// User must tap Next to proceed.
        case userConfirm
        /// Proceeds automatically when at least one habit exists.
        case onHabitCreated
        /// Proceeds automatically when any habit is marked complete today.
        case onHabitCompleted
    }

    var advance: Advance {
        switch self {
        case .addHabit: return .onHabitCreated
        case .completeHabit: return .onHabitCompleted
        default: return .userConfirm
        }
    }

    var titleKey: LocalizedStringKey {
        switch self {
        case .welcome: return "onboarding.welcome.title"
        case .addHabit: return "onboarding.addHabit.title"
        case .habitCard: return "onboarding.habitCard.title"
        case .completeHabit: return "onboarding.completeHabit.title"
        case .stats: return "onboarding.stats.title"
        case .settings: return "onboarding.settings.title"
        case .done: return "onboarding.done.title"
        }
    }

    var messageKey: LocalizedStringKey {
        switch self {
        case .welcome: return "onboarding.welcome.message"
        case .addHabit: return "onboarding.addHabit.message"
        case .habitCard: return "onboarding.habitCard.message"
        case .completeHabit: return "onboarding.completeHabit.message"
        case .stats: return "onboarding.stats.message"
        case .settings: return "onboarding.settings.message"
        case .done: return "onboarding.done.message"
        }
    }

    /// English fallbacks so the flow is comprehensible if the String Catalog
    /// has not been populated yet. VoiceOver announcements also use these.
    var fallbackTitle: String {
        switch self {
        case .welcome: return "Welcome to Streako"
        case .addHabit: return "Add a habit"
        case .habitCard: return "Open to see details"
        case .completeHabit: return "Mark it done"
        case .stats: return "Your stats"
        case .settings: return "Settings and reminders"
        case .done: return "You're set"
        }
    }

    var fallbackMessage: String {
        switch self {
        case .welcome: return "Let's set up your first habit in a few quick steps."
        case .addHabit: return "Tap the plus button to create something you want to repeat daily."
        case .habitCard: return "Tap a habit to view its streak, calendar, and appearance."
        case .completeHabit: return "Tap the circle to complete today. Your streak starts now."
        case .stats: return "See your streaks and completion rate at a glance."
        case .settings: return "Manage your account, turn on daily reminders, and replay this tutorial anytime."
        case .done: return "Have a great streak."
        }
    }
}
