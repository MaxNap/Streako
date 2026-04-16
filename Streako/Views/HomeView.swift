//
//  HomeView.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-08.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var onboarding: OnboardingViewModel
    @StateObject private var habitsViewModel = HabitsViewModel()
    @State private var showAddHabit = false

    private var completedTodayCount: Int {
        habitsViewModel.habits.filter { $0.isCompletedToday }.count
    }

    private var anyCompletedToday: Bool {
        habitsViewModel.habits.contains { $0.isCompletedToday }
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
                                ForEach(Array(habitsViewModel.habits.enumerated()), id: \.element.id) { index, habit in
                                    NavigationLink {
                                        HabitDetailView(habitId: habit.id ?? "")
                                            .environmentObject(habitsViewModel)
                                    } label: {
                                        HabitCardView(
                                            habit: habit,
                                            isFirst: index == 0,
                                            onComplete: {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                    habitsViewModel.completeHabit(habit)
                                                }
                                            }
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
            }
            .sheet(isPresented: $showAddHabit) {
                AddHabitView()
                    .environmentObject(habitsViewModel)
            }
            .onAppear {
                habitsViewModel.fetchHabits()
            }
            // Automatic onboarding advance hooks. Observing the list here
            // captures completions that happen from both HomeView and
            // HabitDetailView (fixes the bug where detail-view completion
            // left the coach mark stranded).
            .onChange(of: habitsViewModel.habits.count) { oldValue, newValue in
                if newValue > oldValue {
                    onboarding.habitListDidGrow()
                }
            }
            .onChange(of: anyCompletedToday) { _, isAnyCompleted in
                if isAnyCompleted {
                    onboarding.anyHabitCompletedToday()
                }
            }
        }
        // A single overlay consumes all anchor preferences registered by
        // child views. No hardcoded coordinates, no GeometryReader callbacks,
        // no per-card closures — live bounds are resolved every render.
        .overlayPreferenceValue(OnboardingAnchorsKey.self) { anchors in
            OnboardingOverlay(onboarding: onboarding, anchors: anchors)
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
                        .foregroundColor(.white.opacity(0.75)) // WCAG 4.5:1 on black
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
                    .accessibilityLabel(Text("Statistics"))
                    .accessibilityHint(Text("View streaks and completion rate"))
                    .onboardingAnchor(.statsTab)

                    NavigationLink {
                        SettingsView()
                            .environmentObject(onboarding)
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel(Text("Settings"))
                    .accessibilityHint(Text("Manage reminders, account, and replay the tutorial"))
                    .onboardingAnchor(.settingsTab)

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
                    .accessibilityLabel(Text("Add habit"))
                    .accessibilityHint(Text("Create a new daily habit"))
                    .onboardingAnchor(.addHabitButton)
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
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
        .environmentObject(OnboardingViewModel())
}
