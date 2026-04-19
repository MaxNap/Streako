//
//  QuickStatsView.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-17.
//

import SwiftUI

struct QuickStatsView: View {
    let completionRate: Int
    let currentStreak: Int
    let totalValue: Int
    
    var body: some View {
        HStack(spacing: 12) {
            StatBubble(
                value: "\(completionRate)%",
                label: "Completed",
                sublabel: "Today",
                color: .purple
            )
            
            StatBubble(
                value: "\(currentStreak)",
                label: "Day Streak",
                sublabel: currentStreak == 1 ? "Current" : "Current",
                color: .orange,
                icon: "flame.fill"
            )
            
            StatBubble(
                value: "\(totalValue)",
                label: "Active Days",
                sublabel: "Total",
                color: .green,
                icon: "calendar"
            )
        }
        .padding(.horizontal)
    }
}

struct StatBubble: View {
    let value: String
    let label: String
    let sublabel: String
    let color: Color
    var icon: String? = nil
    
    var body: some View {
        VStack(spacing: 6) {
            // Icon space (always reserve space for consistency)
            Group {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(color)
                } else {
                    // Invisible placeholder to maintain consistent height
                    Image(systemName: "circle.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.clear)
                }
            }
            .frame(height: 14)
            
            // Value
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            // Label
            VStack(spacing: 2) {
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                
                Text(sublabel)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 20) {
            QuickStatsView(
                completionRate: 60,
                currentStreak: 3,
                totalValue: 45
            )
            
            QuickStatsView(
                completionRate: 100,
                currentStreak: 7,
                totalValue: 120
            )
            
            QuickStatsView(
                completionRate: 0,
                currentStreak: 0,
                totalValue: 0
            )
        }
    }
}
