//
//  TestDataGenerator.swift
//  Streako
//
//  Created for testing purposes
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class TestDataGenerator {
    static let shared = TestDataGenerator()
    
    private init() {}
    
    // Generate 1 week of realistic habit data
    func generate1WeekData(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(TestDataError.notAuthenticated))
            return
        }
        
        let db = Firestore.firestore()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date()) // Use start of day for consistency
        
        // Create 5 realistic habits
        let habitsData: [(name: String, icon: String, color: String, completionPattern: [Bool])] = [
            ("Morning Exercise", "figure.walk", "FF9500", [true, true, true, true, true, true, true]), // Perfect week
            ("Read Book", "book.fill", "34C759", [true, true, false, true, true, true, true]), // Missed day 3
            ("Meditation", "bolt.fill", "AF52DE", [false, false, true, true, true, true, true]), // Strong finish
            ("Drink Water", "drop.fill", "007AFF", [true, false, true, false, true, false, true]), // Scattered
            ("Journal", "heart.fill", "FF3B30", [false, false, false, false, false, true, true]) // Recent start
        ]
        
        let group = DispatchGroup()
        var errors: [Error] = []
        
        for habitData in habitsData {
            group.enter()
            
            // Calculate streak and completion dates
            var completedDates: [String] = []
            var currentStreak = 0
            var bestStreak = 0
            var tempStreak = 0
            
            // Go through the week (7 days ago to today)
            for dayOffset in (0..<7).reversed() {
                let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
                let isCompleted = habitData.completionPattern[6 - dayOffset]
                
                if isCompleted {
                    let dateStr = Habit.dateString(from: date)
                    completedDates.append(dateStr)
                    tempStreak += 1
                    bestStreak = max(bestStreak, tempStreak)
                    
                    // If this is today or continues to today, it's current streak
                    if dayOffset == 0 {
                        currentStreak = tempStreak
                    }
                } else {
                    tempStreak = 0
                }
            }
            
            // Last completed date (if today is completed)
            let lastCompletedDate = habitData.completionPattern.last == true ? Habit.dateString(from: today) : nil
            
            // Habit creation date is 6 days ago
            let createdAtDate = calendar.date(byAdding: .day, value: -6, to: today)!
            
            // Create habit document
            let habitRef = db.collection("users").document(userId).collection("habits").document()
            
            let habit: [String: Any] = [
                "name": habitData.name,
                "iconName": habitData.icon,
                "colorHex": habitData.color,
                "createdAt": Timestamp(date: createdAtDate),
                "currentStreak": currentStreak,
                "bestStreak": bestStreak,
                "lastCompletedDate": lastCompletedDate as Any,
                "completedDates": completedDates,
                "isArchived": false
            ]
            
            habitRef.setData(habit) { error in
                if let error = error {
                    errors.append(error)
                }
                group.leave()
            }
            
            // Add slight delay between creations to avoid rate limiting
            Thread.sleep(forTimeInterval: 0.1)
        }
        
        group.notify(queue: .main) {
            if let firstError = errors.first {
                completion(.failure(firstError))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // Clear all habit data
    func clearAllData(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(TestDataError.notAuthenticated))
            return
        }
        
        let db = Firestore.firestore()
        let habitsRef = db.collection("users").document(userId).collection("habits")
        
        habitsRef.getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion(.success(()))
                return
            }
            
            let group = DispatchGroup()
            var errors: [Error] = []
            
            for document in documents {
                group.enter()
                document.reference.delete { error in
                    if let error = error {
                        errors.append(error)
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                if let firstError = errors.first {
                    completion(.failure(firstError))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
}

enum TestDataError: LocalizedError {
    case notAuthenticated
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be signed in to generate test data."
        }
    }
}

