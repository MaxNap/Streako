//
//  HomeView.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-08.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var habitsViewModel = HabitsViewModel()
    @State private var showAddHabit = false
    
    private var completedTodayCount: Int {
        habitsViewModel.habits.filter { $0.isCompletedToday }.count
    }
    
    private var progressSection: some View {
        HStack(spacing: 12) {
            ForEach(habitsViewModel.habits.indices, id: \.self) { index in
                let habit = habitsViewModel.habits[index]
                
                Circle()
                    .strokeBorder(
                        habit.isCompletedToday ? Color.purple : Color.white.opacity(0.15),
                        lineWidth: 3
                    )
                    .background(
                        Circle()
                            .fill(habit.isCompletedToday ? Color.purple.opacity(0.18) : Color.clear)
                    )
                    .frame(width: 28, height: 28)
                    .overlay {
                        if habit.isCompletedToday {
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
            }
            
            Spacer()
            
            Text("\(completedTodayCount)/\(habitsViewModel.habits.count)")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.horizontal)
        .padding(.top, 14)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerSection
                    progressSection
                    
                    if habitsViewModel.habits.isEmpty {
                        Spacer()
                        
                        Text("No habits yet")
                            .foregroundColor(.gray)
                            .font(.headline)
                        
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 14) {
                                ForEach(habitsViewModel.habits) { habit in
                                    NavigationLink {
                                        HabitDetailView(habitId: habit.id ?? "")
                                            .environmentObject(habitsViewModel)
                                    } label: {
                                        habitCard(habit)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 16)
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddHabit) {
                AddHabitView()
                    .environmentObject(habitsViewModel)
            }
            .onAppear {
                habitsViewModel.fetchHabits()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(formattedDate)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button {
                    showAddHabit = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            Divider()
                .background(Color.white.opacity(0.08))
                .padding(.top, 12)
        }
    }
    
    private func habitCard(_ habit: Habit) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.10))
                    .frame(width: 54, height: 54)
                
                Circle()
                    .stroke(
                        habit.isCompletedToday ? Color.purple : Color.white.opacity(0.10),
                        lineWidth: 3
                    )
                    .frame(width: 54, height: 54)
                
                Image(systemName: "flame.fill")
                    .foregroundColor(habit.isCompletedToday ? .purple : .orange)
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
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    habitsViewModel.completeHabit(habit)
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 34, height: 34)
                    
                    Image(systemName: habit.isCompletedToday ? "checkmark" : "circle")
                        .scaleEffect(habit.isCompletedToday ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: habit.isCompletedToday)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(habit.isCompletedToday ? .white : .gray)
                }
            }
            .buttonStyle(.plain)
            .disabled(habit.isCompletedToday)
            .opacity(habit.isCompletedToday ? 0.8 : 1.0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(habit.isCompletedToday ? Color.purple.opacity(0.12) : Color.white.opacity(0.04))
        )
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: Date())
    }
}

#Preview {
    HomeView()
}
