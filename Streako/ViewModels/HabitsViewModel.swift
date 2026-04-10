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
    
    func addHabit(name: String, completion: @escaping () -> Void) {
        HabitService.shared.addHabit(name: name) { [weak self] error in
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
        updatedHabit.lastCompletedDate = updatedHabit.completedDates.sorted().last
        
        if updatedHabit.completedDates.isEmpty {
            updatedHabit.currentStreak = 0
            updatedHabit.bestStreak = max(updatedHabit.bestStreak, 0)
        } else {
            updatedHabit.currentStreak = updatedHabit.completedDates.count
        }
        
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
}
