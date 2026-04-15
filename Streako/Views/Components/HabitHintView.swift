//
//  HabitHintView.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-14.
//

import SwiftUI

struct HabitHintView: View {
    @State private var animateArrow = false
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "arrow.up")
                .font(.title3)
                .foregroundColor(.white.opacity(0.85))
                .offset(y: animateArrow ? -6 : 0)
                .shadow(color: .white.opacity(0.2), radius: 4)
            
            HStack(spacing: 4) {
                Text("Tap")
                Image(systemName: "circle")
                Text("to complete")
            }
            .font(.footnote.weight(.medium))
            .foregroundColor(.white.opacity(0.85))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.35))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .onAppear {
            animateArrow = true
        }
        .animation(
            .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
            value: animateArrow
        )
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        HabitHintView()
    }
}
