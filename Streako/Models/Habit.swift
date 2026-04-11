//
//  Habit.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-08.
//

import Foundation
import FirebaseFirestore

struct Habit: Identifiable, Codable {
    @DocumentID var id: String?
    let name: String
    let createdAt: Date
    var currentStreak: Int
    var bestStreak: Int
    var lastCompletedDate: String?
    var completedDates: [String]
    var isArchived: Bool
    var iconName: String
    var colorHex: String
    
    var isCompletedToday: Bool {
        lastCompletedDate == Self.dateString(from: Date())
    }
    
    static func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
