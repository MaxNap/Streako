//
//  DayHabitsSheet.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-17.
//

import SwiftUI

struct DayHabitsSheet: View {
    @Environment(\.dismiss) private var dismiss
    let date: Date
    let habits: [Habit]
    
    private var completedHabits: [Habit] {
        habits.filter { $0.isCompletedOn(date: date) }
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private var dayLetter: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text(dayLetter)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                    
                    Text(dateString)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 8)
                
                // Completed habits
                if completedHabits.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 48))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("No habits completed")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("No habits were completed on this day")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Completed Habits")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(completedHabits) { habit in
                                    HabitCompletionRow(habit: habit)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Close button
                Button {
                    dismiss()
                } label: {
                    Text("Close")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .padding()
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

struct HabitCompletionRow: View {
    let habit: Habit
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color(hex: habit.colorHex))
                    .frame(width: 50, height: 50)
                
                Image(systemName: habit.iconName)
                    .font(.system(size: 22))
                    .foregroundColor(.white)
            }
            
            // Name and streak
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Text("\(habit.currentStreak) day streak")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Checkmark
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundColor(.green)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }
}

#Preview {
    DayHabitsSheet(
        date: Date(),
        habits: [
            Habit(
                name: "Morning Run",
                createdAt: Date(),
                currentStreak: 5,
                bestStreak: 10,
                lastCompletedDate: Habit.dateString(from: Date()),
                completedDates: [Habit.dateString(from: Date())],
                isArchived: false,
                iconName: "figure.run",
                colorHex: "FF6B6B"
            ),
            Habit(
                name: "Read 30 min",
                createdAt: Date(),
                currentStreak: 3,
                bestStreak: 7,
                lastCompletedDate: Habit.dateString(from: Date()),
                completedDates: [Habit.dateString(from: Date())],
                isArchived: false,
                iconName: "book.fill",
                colorHex: "4ECDC4"
            )
        ]
    )
}
