//
//  HabitHintView.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-14.
//

import SwiftUI

// MARK: - Tutorial Step Model
enum TutorialStep: Int, CaseIterable {
    case welcome = 0
    case addHabit = 1
    case complete = 2
    case viewStats = 3
    
    var title: String {
        switch self {
        case .welcome:
            return "Welcome to Streako"
        case .addHabit:
            return "Create Your Habits"
        case .complete:
            return "Track Your Progress"
        case .viewStats:
            return "View Your Stats"
        }
    }
    
    var message: String {
        switch self {
        case .welcome:
            return "Build lasting habits and track your streaks with ease"
        case .addHabit:
            return "Tap the + button to add a new habit. Customize it with icons and colors"
        case .complete:
            return "Tap the checkmark to complete your habit for the day. Tap again to undo"
        case .viewStats:
            return "Check your progress, streaks, and completion rates in the stats section"
        }
    }
    
    var icon: String {
        switch self {
        case .welcome:
            return "flame.fill"
        case .addHabit:
            return "plus.circle.fill"
        case .complete:
            return "checkmark.circle.fill"
        case .viewStats:
            return "chart.bar.fill"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .welcome:
            return .orange
        case .addHabit:
            return .blue
        case .complete:
            return .green
        case .viewStats:
            return .purple
        }
    }
}

// MARK: - Modern Onboarding View
struct OnboardingTutorialView: View {
    @Binding var isPresented: Bool
    @State private var currentStep = 0
    @State private var animateContent = false
    
    private let totalSteps = TutorialStep.allCases.count
    
    var body: some View {
        ZStack {
            // Dimmed background with blur
            Color.black.opacity(0.92)
                .ignoresSafeArea()
                .onTapGesture {
                    // Prevent accidental dismissal
                }
            
            VStack(spacing: 0) {
                Spacer()
                
                if let step = TutorialStep(rawValue: currentStep) {
                    tutorialCard(for: step)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
                
                Spacer()
                    .frame(height: 80)
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.15)) {
                animateContent = true
            }
        }
    }
    
    @ViewBuilder
    private func tutorialCard(for step: TutorialStep) -> some View {
        VStack(spacing: 28) {
            // Icon with animated background
            ZStack {
                Circle()
                    .fill(step.accentColor.opacity(0.15))
                    .frame(width: 100, height: 100)
                    .scaleEffect(animateContent ? 1.0 : 0.5)
                    .blur(radius: 20)
                
                Circle()
                    .fill(step.accentColor.opacity(0.25))
                    .frame(width: 88, height: 88)
                    .scaleEffect(animateContent ? 1.0 : 0.5)
                
                Image(systemName: step.icon)
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(step.accentColor)
                    .scaleEffect(animateContent ? 1.0 : 0.5)
            }
            .padding(.top, 8)
            
            // Content
            VStack(spacing: 14) {
                Text(step.title)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(step.message)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(4)
            }
            .opacity(animateContent ? 1.0 : 0)
            .padding(.horizontal, 8)
            
            // Progress dots
            HStack(spacing: 10) {
                ForEach(0..<totalSteps, id: \.self) { index in
                    Capsule()
                        .fill(index == currentStep ? step.accentColor : Color.white.opacity(0.25))
                        .frame(width: index == currentStep ? 24 : 8, height: 8)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentStep)
                }
            }
            .padding(.top, 4)
            
            // Buttons
            VStack(spacing: 12) {
                Button {
                    if currentStep < totalSteps - 1 {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            animateContent = false
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            currentStep += 1
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                animateContent = true
                            }
                        }
                    } else {
                        completeTutorial()
                    }
                } label: {
                    HStack {
                        Text(currentStep < totalSteps - 1 ? "Next" : "Get Started")
                            .font(.body.weight(.semibold))
                            .foregroundColor(.white)
                        
                        if currentStep < totalSteps - 1 {
                            Image(systemName: "arrow.right")
                                .font(.body.weight(.semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(step.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: step.accentColor.opacity(0.3), radius: 12, x: 0, y: 6)
                }
                
                if currentStep > 0 {
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            animateContent = false
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            currentStep -= 1
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                animateContent = true
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.left")
                                .font(.body.weight(.medium))
                                .foregroundColor(.white.opacity(0.7))
                            
                            Text("Back")
                                .font(.body.weight(.medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(.top, 8)
            
            // Skip button - only show on first steps
            if currentStep < totalSteps - 1 {
                Button {
                    skipTutorial()
                } label: {
                    Text("Skip Tutorial")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.white.opacity(0.4))
                        .padding(.top, 4)
                }
                .transition(.opacity)
            }
        }
        .padding(32)
        .background(
            ZStack {
                // Glass morphism effect
                RoundedRectangle(cornerRadius: 28)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.white.opacity(0.05))
                
                RoundedRectangle(cornerRadius: 28)
                    .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
            }
        )
        .shadow(color: .black.opacity(0.4), radius: 30, x: 0, y: 15)
    }
    
    private func skipTutorial() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isPresented = false
        }
    }
    
    private func completeTutorial() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isPresented = false
        }
    }
}

// MARK: - Previews
#Preview("Onboarding Tutorial") {
    ZStack {
        Color.black.ignoresSafeArea()
        
        // Mock content in background
        VStack {
            Text("Streako")
                .font(.largeTitle.bold())
                .foregroundColor(.white)
        }
        
        OnboardingTutorialView(isPresented: .constant(true))
    }
}

#Preview("Tutorial - Welcome") {
    ZStack {
        Color.black.ignoresSafeArea()
        OnboardingTutorialView(isPresented: .constant(true))
    }
}
