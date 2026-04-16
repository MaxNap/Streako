//
//  View+OnboardingAnchor.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-16.
//

import SwiftUI

/// PreferenceKey that collects the bounds of every view that registered as an
/// onboarding anchor. Consumed once at the root by `.overlayPreferenceValue`.
struct OnboardingAnchorsKey: PreferenceKey {
    static let defaultValue: [OnboardingAnchor: Anchor<CGRect>] = [:]

    static func reduce(
        value: inout [OnboardingAnchor: Anchor<CGRect>],
        nextValue: () -> [OnboardingAnchor: Anchor<CGRect>]
    ) {
        value.merge(nextValue()) { _, new in new }
    }
}

extension View {
    /// Register this view as the target for an onboarding step. The overlay
    /// reads the live bounds each render, so rotation, split view, keyboard,
    /// and scroll offsets are handled automatically.
    func onboardingAnchor(_ id: OnboardingAnchor) -> some View {
        anchorPreference(key: OnboardingAnchorsKey.self, value: .bounds) { anchor in
            [id: anchor]
        }
    }
}
