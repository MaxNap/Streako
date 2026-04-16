//
//  OnboardingTooltipView.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-16.
//

import SwiftUI

/// The floating card that explains each step. Progress dots, optional Back,
/// always-visible Skip, and a primary Next/Done button — all with AX5
/// Dynamic Type support, 44×44pt hit targets, and WCAG-compliant contrast.
struct OnboardingTooltipView: View {

    let step: OnboardingStep
    let progressText: String?
    let canGoBack: Bool
    let waitingForAction: Bool

    let onBack: () -> Void
    let onNext: () -> Void
    let onSkip: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var isLastStep: Bool { step == .done }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            progressRow
            Text(step.titleKey)
                .font(.headline)
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            Text(step.messageKey)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)

            controlsRow
        }
        .padding(18)
        .frame(maxWidth: 360, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(white: 0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.35), radius: 12, x: 0, y: 6)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(step.fallbackTitle))
        .accessibilityValue(Text(step.fallbackMessage))
    }

    // MARK: - Progress

    @ViewBuilder
    private var progressRow: some View {
        if let progressText {
            HStack(spacing: 8) {
                progressDots
                    .accessibilityHidden(true)
                Spacer(minLength: 0)
                Text(progressText)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.75))
                    .accessibilityLabel(Text(progressText))
            }
        }
    }

    @ViewBuilder
    private var progressDots: some View {
        let visible = OnboardingStep.visibleSteps
        HStack(spacing: 6) {
            ForEach(visible, id: \.self) { s in
                Circle()
                    .fill(s == step ? Color.white : Color.white.opacity(0.35))
                    .frame(width: 6, height: 6)
            }
        }
    }

    // MARK: - Controls

    private var controlsRow: some View {
        HStack(spacing: 10) {
            if canGoBack {
                Button(action: onBack) {
                    Label {
                        Text("onboarding.cta.back")
                    } icon: {
                        Image(systemName: "chevron.left")
                    }
                    .labelStyle(.titleOnly)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .frame(minWidth: 44, minHeight: 44)
                    .padding(.horizontal, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.white.opacity(0.10))
                    )
                }
                .accessibilityLabel(Text("Back"))
                .accessibilityHint(Text("Go to the previous tutorial step"))
            }

            Button(action: onSkip) {
                Text("onboarding.cta.skip")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.85))
                    .frame(minWidth: 44, minHeight: 44)
                    .padding(.horizontal, 10)
            }
            .accessibilityLabel(Text("Skip tutorial"))
            .accessibilityHint(Text("Dismiss the tutorial and don't show it again"))

            Spacer(minLength: 0)

            Button(action: onNext) {
                HStack(spacing: 6) {
                    Text(isLastStep ? LocalizedStringKey("onboarding.cta.done") : LocalizedStringKey("onboarding.cta.next"))
                    if !isLastStep {
                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.bold))
                    }
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.black)
                .frame(minHeight: 44)
                .padding(.horizontal, 18)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(waitingForAction ? Color.white.opacity(0.4) : Color.white)
                )
            }
            .disabled(waitingForAction)
            .accessibilityLabel(Text(isLastStep ? "Done" : "Next"))
            .accessibilityHint(Text(isLastStep ? "Finish the tutorial" : "Go to the next tutorial step"))
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        OnboardingTooltipView(
            step: .completeHabit,
            progressText: "Step 4 of 6",
            canGoBack: true,
            waitingForAction: false,
            onBack: {},
            onNext: {},
            onSkip: {}
        )
        .padding()
    }
}
