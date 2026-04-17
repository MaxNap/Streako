//
//  HabitsViewModel.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-08.
//

import Foundation
import Combine

final class HabitsViewModel: ObservableObject {
    
    @Published var habits: [Habit] = []
    @Published var errorMessage = ""
    
    var totalHabits: Int {
        habits.count
    }

    var completedTodayCount: Int {
        habits.filter { $0.isCompletedToday }.count
    }

    var totalCompletions: Int {
        habits.reduce(0) { $0 + $1.completedDates.count }
    }

    var bestOverallStreak: Int {
        habits.map { $0.bestStreak }.max() ?? 0
    }

    var overallCompletionRate: Double {
        guard !habits.isEmpty else { return 0 }
        return Double(completedTodayCount) / Double(habits.count)
    }
    
    func fetchHabits() {
        HabitService.shared.fetchHabits { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let habits):
                    self?.habits = habits.sorted { $0.createdAt < $1.createdAt }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func addHabit(name: String, iconName: String, colorHex: String, completion: @escaping () -> Void) {
        HabitService.shared.addHabit(name: name, iconName: iconName, colorHex: colorHex) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.fetchHabits()
                    completion()
                }
            }
        }
    }
    
    func completeHabit(_ habit: Habit) {
        guard !habit.isCompletedToday else { return }
        
        var updatedHabit = habit
        let today = Date()
        let todayString = Habit.dateString(from: today)
        
        if let lastCompleted = habit.lastCompletedDate,
           let lastDate = Self.dateFormatter.date(from: lastCompleted) {
            
            let calendar = Calendar.current
            if calendar.isDate(lastDate, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: today)!) {
                updatedHabit.currentStreak += 1
            } else {
                updatedHabit.currentStreak = 1
            }
        } else {
            updatedHabit.currentStreak = 1
        }
        
        if updatedHabit.currentStreak > updatedHabit.bestStreak {
            updatedHabit.bestStreak = updatedHabit.currentStreak
        }
        
        updatedHabit.lastCompletedDate = todayString
        if !updatedHabit.completedDates.contains(todayString) {
            updatedHabit.completedDates.append(todayString)
        }
        
        HabitService.shared.updateHabit(updatedHabit) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.fetchHabits()
                }
            }
        }
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    func deleteHabit(_ habit: Habit) {
        HabitService.shared.deleteHabit(habit) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.habits.removeAll { $0.id == habit.id }
                }
            }
        }
    }
    
    func renameHabit(_ habit: Habit, newName: String, completion: @escaping () -> Void) {
        HabitService.shared.renameHabit(habit, newName: newName) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.fetchHabits()
                    completion()
                }
            }
        }
    }
    
    func uncompleteHabit(_ habit: Habit) {
        guard habit.isCompletedToday else { return }
        
        var updatedHabit = habit
        let todayString = Habit.dateString(from: Date())
        
        updatedHabit.completedDates.removeAll { $0 == todayString }
        
        let sortedDates = updatedHabit.completedDates.sorted()
        updatedHabit.lastCompletedDate = sortedDates.last
        
        updatedHabit.currentStreak = calculateCurrentStreak(from: sortedDates)
        
        HabitService.shared.uncompleteHabit(updatedHabit) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.fetchHabits()
                }
            }
        }
    }

    private func calculateCurrentStreak(from sortedDateStrings: [String]) -> Int {
        guard !sortedDateStrings.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let dates = sortedDateStrings.compactMap { Self.dateFormatter.date(from: $0) }.sorted()
        
        guard var streakDate = dates.last else { return 0 }
        var streak = 1
        
        for date in dates.dropLast().reversed() {
            guard let expectedPrevious = calendar.date(byAdding: .day, value: -1, to: streakDate) else {
                break
            }
            
            if calendar.isDate(date, inSameDayAs: expectedPrevious) {
                streak += 1
                streakDate = date
            } else {
                break
            }
        }
        
        return streak
    }
    
    func updateHabitAppearance(_ habit: Habit, iconName: String, colorHex: String, completion: @escaping () -> Void) {
        HabitService.shared.updateHabitAppearance(habit, iconName: iconName, colorHex: colorHex) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.fetchHabits()
                    completion()
                }
            }
        }
    }
}
