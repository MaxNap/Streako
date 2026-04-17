//
//  EmptyStateView.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-14.
//

import SwiftUI

struct EmptyStateView: View {
    @State private var animateIcon = false
    @State private var showContent = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Animated icon
            ZStack {
                // Pulsing background circles
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 140, height: 140)
                    .scaleEffect(animateIcon ? 1.1 : 1.0)
                    .blur(radius: 20)
                
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 100, height: 100)
                    .scaleEffect(animateIcon ? 1.05 : 1.0)
                
                // Main icon
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .blue.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(showContent ? 1.0 : 0.5)
                    .rotationEffect(.degrees(showContent ? 0 : -90))
            }
            .padding(.top, 20)
            
            // Text content
            VStack(spacing: 12) {
                Text("Start Your Journey")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(showContent ? 1 : 0)
                
                Text("Build consistency one habit at a time")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                    .opacity(showContent ? 1 : 0)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
            
            // Action hint
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.up")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.blue)
                        .offset(y: animateIcon ? -6 : 0)
                    
                    Text("Tap the")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Image(systemName: "plus")
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Color.blue.opacity(0.2))
                        .clipShape(Circle())
                    
                    Text("button")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .opacity(showContent ? 1 : 0)
                .padding(.top, 8)
            }
        }
        .padding(.horizontal, 24)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                animateIcon = true
            }
            
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                showContent = true
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        EmptyStateView()
    }
}
