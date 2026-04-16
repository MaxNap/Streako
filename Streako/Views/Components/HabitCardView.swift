//
//  HabitCardView.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-13.
//

import SwiftUI

struct HabitCardView: View {
    let habit: Habit
    let isFirst: Bool
    let onComplete: () -> Void

    init(
        habit: Habit,
        isFirst: Bool = false,
        onComplete: @escaping () -> Void
    ) {
        self.habit = habit
        self.isFirst = isFirst
        self.onComplete = onComplete
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.10))
                    .frame(width: 54, height: 54)

                Circle()
                    .stroke(
                        habit.isCompletedToday ? Color(hex: habit.colorHex) : Color.white.opacity(0.10),
                        lineWidth: 3
                    )
                    .frame(width: 54, height: 54)

                Image(systemName: habit.iconName)
                    .foregroundColor(Color(hex: habit.colorHex))
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.headline)
                    .foregroundColor(.white)

                Text("\(habit.currentStreak)-day streak")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.75))

                Text(habit.isCompletedToday ? "Completed today" : "Not completed today")
                    .font(.caption)
                    // Raised opacity so both states clear WCAG 4.5:1 on black.
                    .foregroundColor(habit.isCompletedToday ? .green : .white.opacity(0.75))
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text(habit.name))
            .accessibilityValue(Text(accessibilityValue))

            Spacer()

            Button {
                onComplete()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 34, height: 34)

                    Image(systemName: habit.isCompletedToday ? "checkmark" : "circle")
                        .scaleEffect(habit.isCompletedToday ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: habit.isCompletedToday)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(habit.isCompletedToday ? .white : .white.opacity(0.85))
                }
                // Guarantees a 44×44pt hit target even though the visible
                // circle is smaller — meets Apple HIG minimum.
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(habit.isCompletedToday)
            .opacity(habit.isCompletedToday ? 0.8 : 1.0)
            .accessibilityLabel(Text(habit.isCompletedToday ? "Completed" : "Mark complete"))
            .accessibilityHint(Text(habit.isCompletedToday ? "Already completed today" : "Marks this habit as done for today"))
            .accessibilityAddTraits(.isButton)
            // The first card's complete button registers as the onboarding
            // spotlight target for the "Mark it done" step.
            .modifier(FirstCompleteAnchor(isFirst: isFirst))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(habit.isCompletedToday ? Color(hex: habit.colorHex).opacity(0.12) : Color.white.opacity(0.04))
        )
        // Whole-card anchor for the "Open to see details" onboarding step.
        .modifier(FirstCardAnchor(isFirst: isFirst))
    }

    private var accessibilityValue: String {
        let streak = "\(habit.currentStreak) day streak"
        let state = habit.isCompletedToday ? "completed today" : "not completed today"
        return "\(streak), \(state)"
    }
}

/// Conditional anchor for the first complete button — `anchorPreference` cannot
/// be wrapped in a plain `if` inside a `some View` chain without changing the
/// return type, so we isolate the conditional in a ViewModifier.
private struct FirstCompleteAnchor: ViewModifier {
    let isFirst: Bool
    func body(content: Content) -> some View {
        if isFirst {
            content.onboardingAnchor(.firstCompleteButton)
        } else {
            content
        }
    }
}

private struct FirstCardAnchor: ViewModifier {
    let isFirst: Bool
    func body(content: Content) -> some View {
        if isFirst {
            content.onboardingAnchor(.firstHabitCard)
        } else {
            content
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        HabitCardView(
            habit: Habit(
                id: "1",
                name: "Workout",
                createdAt: Date(),
                currentStreak: 3,
                bestStreak: 5,
                lastCompletedDate: Habit.dateString(from: Date()),
                completedDates: [Habit.dateString(from: Date())],
                isArchived: false,
                iconName: "flame.fill",
                colorHex: "#FF9500"
            ),
            isFirst: true,
            onComplete: {}
        )
        .padding()
    }
}
