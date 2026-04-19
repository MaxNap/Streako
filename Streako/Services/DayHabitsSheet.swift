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
    
    private var allHabitsOnDate: [(habit: Habit, isCompleted: Bool)] {
        // Only show habits that existed on this date
        habits
            .filter { habit in
                // Check if habit was created before or on this date
                Calendar.current.startOfDay(for: habit.createdAt) <= Calendar.current.startOfDay(for: date)
            }
            .map { habit in
                (habit: habit, isCompleted: habit.isCompletedOn(date: date))
            }
    }
    
    private var completedCount: Int {
        allHabitsOnDate.filter { $0.isCompleted }.count
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
                    
                    // Progress indicator
                    Text("\(completedCount) of \(allHabitsOnDate.count) habits completed")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 24)
                
                // All habits
                if habits.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "tray")
                            .font(.system(size: 48))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("No habits yet")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("Create your first habit to start tracking")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("All Habits")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(allHabitsOnDate, id: \.habit.id) { item in
                                    HabitCompletionRow(
                                        habit: item.habit,
                                        isCompleted: item.isCompleted
                                    )
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
    }
}

struct HabitCompletionRow: View {
    let habit: Habit
    let isCompleted: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color(hex: habit.colorHex))
                    .frame(width: 50, height: 50)
                    .opacity(isCompleted ? 1.0 : 0.3)
                
                Image(systemName: habit.iconName)
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                    .opacity(isCompleted ? 1.0 : 0.5)
            }
            
            // Name and streak
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .opacity(isCompleted ? 1.0 : 0.5)
                
                if isCompleted {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        
                        Text("\(habit.currentStreak) day streak")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                } else {
                    Text("Not completed")
                        .font(.subheadline)
                        .foregroundColor(.gray.opacity(0.7))
                }
            }
            
            Spacer()
            
            // Checkmark or empty circle
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
            } else {
                Image(systemName: "circle")
                    .font(.title2)
                    .foregroundColor(.gray.opacity(0.3))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(isCompleted ? 0.05 : 0.02))
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
                lastCompletedDate: nil,
                completedDates: [],
                isArchived: false,
                iconName: "book.fill",
                colorHex: "4ECDC4"
            )
        ]
    )
}
