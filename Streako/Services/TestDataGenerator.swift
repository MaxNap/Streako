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
        
        // Generate full month of data for perfect screenshots (all days completed)
        let daysInMonth = calendar.component(.day, from: today) // Days from start of month to today
        
        // Create 5 realistic habits - ALL COMPLETED for perfect App Store screenshots
        let habitsData: [(name: String, icon: String, color: String)] = [
            ("Morning Exercise", "figure.walk", "FF9500"),
            ("Read Book", "book.fill", "34C759"),
            ("Meditation", "bolt.fill", "AF52DE"),
            ("Drink Water", "drop.fill", "007AFF"),
            ("Journal", "heart.fill", "FF3B30")
        ]
        
        let group = DispatchGroup()
        var errors: [Error] = []
        
        for habitData in habitsData {
            group.enter()
            
            // Calculate streak and completion dates for entire month
            var completedDates: [String] = []
            
            // Complete ALL days from start of month to today
            for dayOffset in (0..<daysInMonth).reversed() {
                let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
                let dateStr = Habit.dateString(from: date)
                completedDates.append(dateStr)
            }
            
            // Perfect streak = number of days in month so far
            let currentStreak = daysInMonth
            let bestStreak = daysInMonth
            
            // Last completed date is today
            let lastCompletedDate = Habit.dateString(from: today)
            
            // Habit creation date is at the start of the month
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
            let createdAtDate = startOfMonth
            
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

