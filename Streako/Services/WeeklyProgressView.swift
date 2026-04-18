//
//  WeeklyProgressView.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-17.
//

import SwiftUI

struct WeeklyProgressView: View {
    let weekData: [DayProgress]
    let habits: [Habit]
    @State private var selectedDay: DayProgress?
    @State private var showDayHabits = false
    @State private var showCelebration = false
    
    private var isWeekComplete: Bool {
        // Check if all non-future days are completed
        weekData.filter { !$0.isFuture }.allSatisfy { $0.isCompleted }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 0) {
                ForEach(weekData) { day in
                    VStack(spacing: 12) {
                        // Day letter
                        Text(day.dayLetter)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(day.isToday ? .white : .gray)
                        
                        // Circle indicator
                        Button {
                            if !day.isFuture {
                                selectedDay = day
                                showDayHabits = true
                            }
                        } label: {
                            ZStack {
                                // Background circle
                                Circle()
                                    .strokeBorder(
                                        day.isToday ? Color.purple : Color.white.opacity(0.15),
                                        lineWidth: day.isToday ? 2.5 : 2
                                    )
                                    .frame(width: 40, height: 40)
                                
                                // Fill for completed days
                                if day.isCompleted {
                                    Circle()
                                        .fill(Color.purple)
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                // Glow effect for today
                                if day.isToday {
                                    Circle()
                                        .fill(Color.purple.opacity(0.3))
                                        .frame(width: 40, height: 40)
                                        .blur(radius: 8)
                                }
                            }
                        }
                        .disabled(day.isFuture)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal)
        .overlay(
            // Celebration confetti overlay
            Group {
                if isWeekComplete && showCelebration {
                    ConfettiView()
                        .allowsHitTesting(false)
                }
            }
        )
        .sheet(isPresented: $showDayHabits) {
            if let day = selectedDay {
                DayHabitsSheet(
                    date: day.date,
                    habits: habits
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
        .onAppear {
            if isWeekComplete {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation {
                        showCelebration = true
                    }
                    
                    // Hide after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            showCelebration = false
                        }
                    }
                }
            }
        }
        .onChange(of: isWeekComplete) { _, newValue in
            if newValue {
                withAnimation {
                    showCelebration = true
                }
                
                // Hide after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        showCelebration = false
                    }
                }
            }
        }
    }
}

struct DayProgress: Identifiable {
    let id = UUID()
    let dayLetter: String
    let date: Date
    let isToday: Bool
    let isCompleted: Bool
    let isFuture: Bool
}

// Helper to generate week data
extension WeeklyProgressView {
    static func getCurrentWeekData(completedDays: Set<Date> = [], habits: [Habit] = []) -> [DayProgress] {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        
        // Get start of week (Monday)
        let daysFromMonday = (weekday == 1) ? 6 : weekday - 2
        let startOfWeek = calendar.date(byAdding: .day, value: -daysFromMonday, to: today)!
        
        let dayLetters = ["M", "T", "W", "T", "F", "S", "S"]
        
        return (0..<7).map { index in
            let date = calendar.date(byAdding: .day, value: index, to: startOfWeek)!
            let isToday = calendar.isDate(date, inSameDayAs: today)
            let isFuture = date > today
            
            // Check if ALL habits are completed on this day
            var isCompleted = false
            if !isFuture && !habits.isEmpty {
                // A day is complete only if ALL habits are completed
                isCompleted = habits.allSatisfy { habit in
                    habit.isCompletedOn(date: date)
                }
            }
            
            return DayProgress(
                dayLetter: dayLetters[index],
                date: date,
                isToday: isToday,
                isCompleted: isCompleted,
                isFuture: isFuture
            )
        }
    }
}

// MARK: - Confetti Animation

struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(confettiPieces) { piece in
                    ConfettiShape()
                        .fill(piece.color)
                        .frame(width: piece.size, height: piece.size)
                        .offset(x: piece.x, y: piece.y)
                        .rotationEffect(piece.rotation)
                        .opacity(piece.alpha)
                }
            }
            .onAppear {
                generateConfetti(in: geometry.size)
            }
        }
    }
    
    private func generateConfetti(in size: CGSize) {
        let colors: [Color] = [.purple, .orange, .green, .blue, .pink, .yellow]
        
        for _ in 0..<50 {
            let piece = ConfettiPiece(
                x: CGFloat.random(in: 0...size.width),
                y: -50,
                size: CGFloat.random(in: 6...12),
                color: colors.randomElement() ?? .purple,
                rotation: .degrees(Double.random(in: 0...360)),
                alpha: 1.0
            )
            confettiPieces.append(piece)
            
            // Animate each piece
            withAnimation(.easeIn(duration: Double.random(in: 1.5...2.5))) {
                if let index = confettiPieces.firstIndex(where: { $0.id == piece.id }) {
                    confettiPieces[index].y = size.height + 50
                    confettiPieces[index].alpha = 0
                    confettiPieces[index].rotation = .degrees(Double.random(in: 360...720))
                }
            }
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    let color: Color
    var rotation: Angle
    var alpha: Double
}

struct ConfettiShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(rect)
        return path
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 30) {
            // All completed
            WeeklyProgressView(
                weekData: WeeklyProgressView.getCurrentWeekData(
                    completedDays: Set((0..<7).compactMap {
                        Calendar.current.date(byAdding: .day, value: -$0, to: Date())
                    })
                ),
                habits: []
            )
            
            // Partial completion
            WeeklyProgressView(
                weekData: WeeklyProgressView.getCurrentWeekData(
                    completedDays: Set([
                        Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
                        Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                        Date()
                    ])
                ),
                habits: []
            )
            
            // No completion
            WeeklyProgressView(
                weekData: WeeklyProgressView.getCurrentWeekData(),
                habits: []
            )
        }
    }
}

