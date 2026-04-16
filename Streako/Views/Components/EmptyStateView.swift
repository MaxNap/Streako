//
//  EmptyStateView.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-14.
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.75)) // WCAG-safe on black
                .accessibilityHidden(true)

            Text("No habits yet")
                .font(.title2.bold())
                .foregroundColor(.white)

            Text("Start building consistency one step at a time")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.80)) // ≥ 4.5:1 on black

            Text("Tap + to add your first habit")
                .font(.footnote)
                .foregroundColor(.white.opacity(0.75)) // ≥ 4.5:1 on black
                .padding(.top, 8)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 32)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("No habits yet. Start building consistency one step at a time. Tap the plus button to add your first habit."))
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        EmptyStateView()
    }
}
