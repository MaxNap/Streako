//
//  OnboardingOverlay.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-16.
//

import SwiftUI
import UIKit

/// The global dim + spotlight + tooltip layer. Driven entirely by
/// `OnboardingViewModel` and the anchor preferences registered by target
/// views, so there are no hardcoded positions. Attach once, at the root of
/// the screen you want to instrument, via `.overlayPreferenceValue`.
struct OnboardingOverlay: View {

    @ObservedObject var onboarding: OnboardingViewModel
    let anchors: [OnboardingAnchor: Anchor<CGRect>]

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        GeometryReader { geo in
            if onboarding.isActive, let step = onboarding.currentStep {
                ZStack {
                    dimLayer(for: step, in: geo)
                        .transition(.opacity)

                    tooltipLayer(for: step, in: geo)
                        .transition(tooltipTransition)
                }
                .ignoresSafeArea()
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: step)
                .onChange(of: step) { _, newStep in
                    announceStepChange(newStep)
                    playHaptic()
                }
                .onAppear {
                    announceStepChange(step)
                }
            }
        }
    }

    // MARK: - Layers

    /// Dim rectangle with an optional rounded cut-out over the spotlighted
    /// anchor. Falls back to a plain dim when no anchor is set (welcome/done).
    @ViewBuilder
    private func dimLayer(for step: OnboardingStep, in geo: GeometryProxy) -> some View {
        let spotlight = spotlightRect(for: step, in: geo)

        Rectangle()
            .fill(Color.black.opacity(0.72))
            .mask(
                ZStack {
                    Rectangle().fill(Color.white)
                    if let rect = spotlight {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .frame(width: rect.width + 16, height: rect.height + 16)
                            .position(x: rect.midX, y: rect.midY)
                            .blendMode(.destinationOut)
                    }
                }
                .compositingGroup()
            )
            .allowsHitTesting(spotlight == nil)
            // Tapping outside the spotlight does nothing (modal-safe); tapping
            // inside the cut-out passes through to the real UI so the user
            // can complete the requested action.
            .accessibilityHidden(true)
    }

    private func tooltipLayer(for step: OnboardingStep, in geo: GeometryProxy) -> some View {
        let spotlight = spotlightRect(for: step, in: geo)
        let waitingForAction: Bool = {
            switch step.advance {
            case .userConfirm: return false
            case .onHabitCreated, .onHabitCompleted: return true
            }
        }()

        return OnboardingTooltipView(
            step: step,
            progressText: onboarding.progressDescription(for: step),
            canGoBack: step != .welcome,
            waitingForAction: waitingForAction,
            onBack: { onboarding.back() },
            onNext: { onboarding.next() },
            onSkip: { onboarding.skip() }
        )
        .padding(.horizontal, 20)
        .position(tooltipPosition(spotlight: spotlight, in: geo))
    }

    // MARK: - Layout

    private func spotlightRect(for step: OnboardingStep, in geo: GeometryProxy) -> CGRect? {
        guard let anchorID = step.anchor,
              let anchor = anchors[anchorID] else { return nil }
        return geo[anchor]
    }

    /// Prefer below the target. If there isn't room, flip above. If no target
    /// at all, center the card vertically.
    private func tooltipPosition(spotlight: CGRect?, in geo: GeometryProxy) -> CGPoint {
        let safeTop = geo.safeAreaInsets.top
        let safeBottom = geo.safeAreaInsets.bottom
        // Reserve room for the card — Dynamic Type may push it taller at AX5,
        // so use a generous estimate.
        let reservedHeight: CGFloat = 260

        guard let rect = spotlight else {
            return CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
        }

        let roomBelow = geo.size.height - safeBottom - rect.maxY
        let roomAbove = rect.minY - safeTop

        let placeBelow = roomBelow >= reservedHeight || roomBelow >= roomAbove
        let y: CGFloat
        if placeBelow {
            y = rect.maxY + reservedHeight / 2 + 20
        } else {
            y = rect.minY - reservedHeight / 2 - 20
        }
        let clampedY = min(max(y, safeTop + reservedHeight / 2), geo.size.height - safeBottom - reservedHeight / 2)
        return CGPoint(x: geo.size.width / 2, y: clampedY)
    }

    // MARK: - Motion & accessibility

    private var tooltipTransition: AnyTransition {
        if reduceMotion {
            return .opacity
        }
        return .opacity.combined(with: .move(edge: .bottom))
    }

    private func announceStepChange(_ step: OnboardingStep) {
        // Move VoiceOver focus / announce the new step. `.screenChanged` is
        // the right trade-off here: it interrupts the prior announcement
        // and shifts focus to the tooltip.
        let announcement = "\(step.fallbackTitle). \(step.fallbackMessage)"
        UIAccessibility.post(notification: .screenChanged, argument: announcement)
    }

    private func playHaptic() {
        guard !reduceMotion else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}
