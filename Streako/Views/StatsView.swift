//
//  StatsView.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-12.
//

import SwiftUI

struct StatsView: View {
    @EnvironmentObject var habitsViewModel: HabitsViewModel
    
    private var completionRatePercent: Int {
        Int(habitsViewModel.overallCompletionRate * 100)
    }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    summarySection
                    todayProgressSection
                    overallStatsSection
                    habitBreakdownSection
                }
                .padding()
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Stats")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var summarySection: some View {
        VStack(spacing: 12) {
            Text("Your Progress")
                .font(.title2.weight(.bold))
                .foregroundColor(.white)
            
            Text("\(completionRatePercent)% completed today")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }
    
    private var todayProgressSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Today's Progress")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 10) {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 12)
                    
                    GeometryReader { geometry in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.purple)
                            .frame(
                                width: max(0, geometry.size.width * habitsViewModel.overallCompletionRate),
                                height: 12
                            )
                    }
                    .frame(height: 12)
                }
                
                HStack {
                    Text("\(habitsViewModel.completedTodayCount) of \(habitsViewModel.totalHabits) habits completed")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text("\(completionRatePercent)%")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private var overallStatsSection: some View {
        VStack(spacing: 14) {
            statCard(
                title: "Total Habits",
                value: "\(habitsViewModel.totalHabits)",
                color: .white
            )
            
            statCard(
                title: "Completed Today",
                value: "\(habitsViewModel.completedTodayCount)",
                color: .green
            )
            
            statCard(
                title: "Total Completions",
                value: "\(habitsViewModel.totalCompletions)",
                color: .blue
            )
            
            statCard(
                title: "Best Overall Streak",
                value: "\(habitsViewModel.bestOverallStreak) days",
                color: .orange
            )
        }
    }
    
    private var habitBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Habit Breakdown")
                .font(.headline)
                .foregroundColor(.white)
            
            if habitsViewModel.habits.isEmpty {
                Text("No habits yet")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            } else {
                ForEach(habitsViewModel.habits) { habit in
                    HStack(spacing: 14) {
                        Circle()
                            .fill(Color.white.opacity(0.08))
                            .frame(width: 42, height: 42)
                            .overlay {
                                Image(systemName: habit.iconName)
                                    .foregroundColor(Color(hex: habit.colorHex))
                            }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(habit.name)
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("Best: \(habit.bestStreak) • Total completions: \(habit.completedDates.count)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text("\(habit.currentStreak)")
                            .font(.title3.weight(.bold))
                            .foregroundColor(Color(hex: habit.colorHex))
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
        }
    }
    
    private func statCard(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    NavigationStack {
        StatsView()
            .environmentObject(HabitsViewModel())
    }
}
