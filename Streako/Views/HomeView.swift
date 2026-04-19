//
//  HomeView.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-08.
//

import SwiftUI
import UIKit

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var habitsViewModel = HabitsViewModel()
    @State private var showAddHabit = false
    @State private var showHabitLimitAlert = false
    @State private var habitToUndo: Habit?
    @State private var showUndoAlert = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var showOnboarding = false
    @State private var showMonthlyCalendar = false
    
    private var completedTodayCount: Int {
        habitsViewModel.habits.filter { $0.isCompletedToday }.count
    }
    
    private var completionRate: Int {
        guard !habitsViewModel.habits.isEmpty else { return 0 }
        return Int((Double(completedTodayCount) / Double(habitsViewModel.habits.count)) * 100)
    }
    
    private var currentStreak: Int {
        // Calculate the best current streak across all habits
        habitsViewModel.habits.map { $0.currentStreak }.max() ?? 0
    }
    
    private var totalHabitsCompleted: Int {
        // Total number of habit completions across all habits
        habitsViewModel.habits.reduce(0) { $0 + $1.completedDates.count }
    }
    
    private var totalDaysActive: Int {
        // Count unique days where at least one habit was completed
        var allCompletedDates = Set<String>()
        for habit in habitsViewModel.habits {
            allCompletedDates.formUnion(habit.completedDates)
        }
        return allCompletedDates.count
    }
    
    private var allCompletedDatesSet: Set<String> {
        var allDates = Set<String>()
        for habit in habitsViewModel.habits {
            allDates.formUnion(habit.completedDates)
        }
        return allDates
    }
    
    private var weeklyProgressSection: some View {
        WeeklyProgressView(
            weekData: WeeklyProgressView.getCurrentWeekData(
                completedDays: Set(), // Not needed anymore
                habits: habitsViewModel.habits
            ),
            habits: habitsViewModel.habits
        )
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private var quickStatsSection: some View {
        QuickStatsView(
            completionRate: completionRate,
            currentStreak: currentStreak,
            totalValue: totalDaysActive
        )
        .padding(.top, 16)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerSection
                    weeklyProgressSection
                    
                    if habitsViewModel.habits.isEmpty {
                        
                        Spacer()
                        EmptyStateView()
                        Spacer()
                        
                    } else {
                        ScrollView {
                            VStack(spacing: 16) {
                                // Quick stats
                                quickStatsSection
                                
                                // Habits list
                                ForEach(habitsViewModel.habits) { habit in
                                    NavigationLink {
                                        HabitDetailView(habitId: habit.id ?? "")
                                            .environmentObject(habitsViewModel)
                                    } label: {
                                        HabitCardView(
                                            habit: habit,
                                            onComplete: {
                                                if habit.isCompletedToday {
                                                    habitToUndo = habit
                                                    showUndoAlert = true
                                                } else {
                                                    triggerSuccessHaptic()

                                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                        habitsViewModel.completeHabit(habit)
                                                    }
                                                }
                                            },
                                            onCompleteButtonFrameChange: nil
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                            .padding(.bottom, 30)
                        }
                    }
                }
                
                // Onboarding tutorial overlay
                if showOnboarding {
                    OnboardingTutorialView(isPresented: $showOnboarding)
                        .transition(.opacity)
                        .zIndex(100)
                 }
            }
            .coordinateSpace(name: "HomeViewSpace")
            .sheet(isPresented: $showAddHabit) {
                AddHabitView()
                    .environmentObject(habitsViewModel)
            }
            .sheet(isPresented: $showMonthlyCalendar) {
                MonthlyCalendarView(
                    completedDates: allCompletedDatesSet,
                    habits: habitsViewModel.habits
                )
            }
            .alert("Undo completion?", isPresented: $showUndoAlert, presenting: habitToUndo) { habit in
                Button("Cancel", role: .cancel) { }
                Button("Undo", role: .destructive) {
                    triggerUndoHaptic()
                    
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        habitsViewModel.uncompleteHabit(habit)
                    }
                }
            } message: { habit in
                Text("Mark \"\(habit.name)\" as not completed for today?")
            }
            .alert("Habit Limit Reached", isPresented: $showHabitLimitAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("You've reached the maximum of 20 habits. Consider archiving or deleting old habits to add new ones.")
            }
            .onAppear {
                habitsViewModel.fetchHabits()
                
                // Show onboarding on first launch
                if !hasSeenOnboarding {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        showOnboarding = true
                        hasSeenOnboarding = true
                    }
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                // Left: Add Habit button
                Button {
                    if habitsViewModel.habits.count >= 20 {
                        showHabitLimitAlert = true
                    } else {
                        showAddHabit = true
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                }
                
                Spacer()
                
                // Center: Today title and date (tappable for calendar)
                Button {
                    showMonthlyCalendar = true
                } label: {
                    VStack(spacing: 2) {
                        Text("Today")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 4) {
                            Text(formattedDate)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.gray)
                            
                            Image(systemName: "calendar")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.gray.opacity(0.6))
                        }
                    }
                }
                
                Spacer()
                
                // Right: Settings button
                NavigationLink {
                    SettingsView()
                        .environmentObject(habitsViewModel)
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
    }
    
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE d MMMM" // e.g., "Friday 18th April"
        let dateString = formatter.string(from: Date())
        
        // Add ordinal suffix (1st, 2nd, 3rd, etc.)
        let day = Calendar.current.component(.day, from: Date())
        let suffix: String
        switch day {
        case 1, 21, 31: suffix = "st"
        case 2, 22: suffix = "nd"
        case 3, 23: suffix = "rd"
        default: suffix = "th"
        }
        
        // Replace day number with number + suffix
        return dateString.replacingOccurrences(
            of: " \(day) ",
            with: " \(day)\(suffix) "
        )
    }
    
    private func triggerSuccessHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }

    private func triggerUndoHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
}

#Preview {
    HomeView()
}
