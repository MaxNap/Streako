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
    @AppStorage("hasCompletedFirstHabit") private var hasCompletedFirstHabit = false
    @State private var firstHabitCompleteButtonFrame: CGRect = .zero
    @State private var habitToUndo: Habit?
    @State private var showUndoAlert = false
    @AppStorage("hasSeenUndoHint") private var hasSeenUndoHint = false
    
    private var completedTodayCount: Int {
        habitsViewModel.habits.filter { $0.isCompletedToday }.count
    }
    
    
    private var progressSection: some View {
        TodayProgressCardView(
            completedCount: completedTodayCount,
            totalCount: habitsViewModel.habits.count
        )
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
                        EmptyStateView()
                        Spacer()
                        
                    } else {
                        ScrollView {
                            VStack(spacing: 14) {
                                ForEach(habitsViewModel.habits) { habit in
                                    NavigationLink {
                                        HabitDetailView(habitId: habit.id ?? "")
                                            .environmentObject(habitsViewModel)
                                    } label: {
                                        HabitCardView(
                                            habit: habit,
                                            onComplete: {
                                                if habit.isCompletedToday {
                                                    if !hasSeenUndoHint {
                                                        hasSeenUndoHint = true
                                                    }
                                                    
                                                    habitToUndo = habit
                                                    showUndoAlert = true
                                                } else {
                                                    triggerSuccessHaptic()

                                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                        habitsViewModel.completeHabit(habit)
                                                    }
                                                    
                                                    if !hasCompletedFirstHabit {
                                                        hasCompletedFirstHabit = true
                                                    }
                                                }
                                            },
                                            onCompleteButtonFrameChange: habitsViewModel.habits.count == 1 ? { frame in
                                                firstHabitCompleteButtonFrame = frame
                                            } : nil
                                        )
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
                if habitsViewModel.habits.count == 1 &&
                    firstHabitCompleteButtonFrame != .zero {
                    
                    if !hasCompletedFirstHabit {
                        HabitHintView(text: "Tap to complete")
                            .position(
                                x: hintXPosition,
                                y: firstHabitCompleteButtonFrame.minY + 95
                            )
                            .transition(.opacity)
                    }
                    else if !hasSeenUndoHint {
                        HabitHintView(
                            text: "Tap again to undo",
                            alignTrailingToArrow: isHintNearRightEdge
                        )
                        .position(
                            x: hintXPosition,
                            y: firstHabitCompleteButtonFrame.minY + 95
                        )
                        .transition(.opacity)
                    }
                }
            }
            .coordinateSpace(name: "HomeViewSpace")
            .sheet(isPresented: $showAddHabit) {
                AddHabitView()
                    .environmentObject(habitsViewModel)
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
                
                HStack(spacing: 12) {
                    NavigationLink {
                        StatsView()
                            .environmentObject(habitsViewModel)
                    } label: {
                        Image(systemName: "chart.bar.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Circle())
                    }
                    
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Circle())
                    }
                    
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
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            Divider()
                .background(Color.white.opacity(0.08))
                .padding(.top, 12)
        }
    }
    
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: Date())
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
    
    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }

    private var isHintNearRightEdge: Bool {
        firstHabitCompleteButtonFrame.midX > screenWidth - 100
    }

    private var hintXPosition: CGFloat {
        if isHintNearRightEdge {
            return screenWidth - 100
        } else {
            return firstHabitCompleteButtonFrame.midX
        }
    }
    
}

#Preview {
    HomeView()
}
