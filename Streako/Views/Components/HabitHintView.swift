//
//  HabitHintView.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-14.
//

import SwiftUI

struct HabitHintView: View {
    let text: String
    var alignTrailingToArrow: Bool = false
    
    @State private var animateArrow = false
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "arrow.up")
                .font(.title3)
                .foregroundColor(.white.opacity(0.85))
                .offset(y: animateArrow ? -6 : 0)
                .shadow(color: .white.opacity(0.2), radius: 4)
                .frame(maxWidth: .infinity, alignment: alignTrailingToArrow ? .trailing : .center)
            
            Text(text)
                .font(.footnote.weight(.medium))
                .foregroundColor(.white.opacity(0.85))
                .lineLimit(1)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.black.opacity(0.35))
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .frame(maxWidth: 170, alignment: alignTrailingToArrow ? .trailing : .center)
        .onAppear {
            animateArrow = true
        }
        .animation(
            .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
            value: animateArrow
        )
    }
}

#Preview("Complete Hint") {
    ZStack {
        Color.black.ignoresSafeArea()
        HabitHintView(text: "Tap to complete")
    }
}

#Preview("Undo Hint") {
    ZStack {
        Color.black.ignoresSafeArea()
        HabitHintView(text: "Tap again to undo", alignTrailingToArrow: true)
    }
}
