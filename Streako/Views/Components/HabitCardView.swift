//
//  HabitCardView.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-13.
//

import SwiftUI

struct HabitCardView: View {
    let habit: Habit
    let onComplete: () -> Void
    let onCompleteButtonFrameChange: ((CGRect) -> Void)?
    
    @State private var isPressed = false
    @State private var animatePulse = false
    
    init(
        habit: Habit,
        onComplete: @escaping () -> Void,
        onCompleteButtonFrameChange: ((CGRect) -> Void)? = nil
    ) {
        self.habit = habit
        self.onComplete = onComplete
        self.onCompleteButtonFrameChange = onCompleteButtonFrameChange
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
            
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("\(habit.currentStreak)-day streak")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.75))
                
                Text(habit.isCompletedToday ? "Completed today" : "Not completed today")
                    .font(.caption)
                    .foregroundColor(habit.isCompletedToday ? .green : .gray)
            }
            
            Spacer()
            
            Button {
                isPressed = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    isPressed = false
                }
                
                if !habit.isCompletedToday {
                    animatePulse = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        animatePulse = false
                    }
                }
                
                onComplete()
            } label: {
                ZStack {
                    Circle()
                        .stroke(Color(hex: habit.colorHex).opacity(0.6), lineWidth: 2)
                        .frame(width: 34, height: 34)
                        .scaleEffect(animatePulse ? 1.8 : 1.0)
                        .opacity(animatePulse ? 0 : 1)
                        .animation(.easeOut(duration: 0.35), value: animatePulse)
                    
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 34, height: 34)
                    
                    Image(systemName: habit.isCompletedToday ? "checkmark" : "circle")
                        .scaleEffect(habit.isCompletedToday ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: habit.isCompletedToday)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(habit.isCompletedToday ? .white : .gray)
                }
                .scaleEffect(isPressed ? 0.86 : 1.0)
                .animation(.spring(response: 0.18, dampingFraction: 0.55), value: isPressed)
            }
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            onCompleteButtonFrameChange?(geometry.frame(in: .named("HomeViewSpace")))
                        }
                        .onChange(of: geometry.frame(in: .named("HomeViewSpace"))) { _, newFrame in
                            onCompleteButtonFrameChange?(newFrame)
                        }
                }
            )
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    habit.isCompletedToday
                    ? Color(hex: habit.colorHex).opacity(0.12)
                    : Color.white.opacity(0.04)
                )
        )
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
            onComplete: {}
        )
        .padding()
    }
}
