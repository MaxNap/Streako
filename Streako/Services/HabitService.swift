//
//  HabitService.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-08.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

final class HabitService {
    
    static let shared = HabitService()
    
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Update Habit
    func updateHabit(_ habit: Habit, completion: @escaping (Error?) -> Void) {
        guard let ref = habitsRef(), let habitId = habit.id else { return }
        
        do {
            try ref.document(habitId).setData(from: habit)
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    // MARK: - Reference
    private func habitsRef() -> CollectionReference? {
        guard let userId = Auth.auth().currentUser?.uid else { return nil }
        return db.collection("users").document(userId).collection("habits")
    }
    
    // MARK: - Fetch Habits
    func fetchHabits(completion: @escaping (Result<[Habit], Error>) -> Void) {
        guard let ref = habitsRef() else {
            print("❌ habitsRef is nil during fetch")
            return
        }
        
        ref.getDocuments { snapshot, error in
            if let error = error {
                print("❌ Fetch error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            print("📦 Documents count: \(snapshot?.documents.count ?? 0)")
            
            let habits = snapshot?.documents.compactMap {
                try? $0.data(as: Habit.self)
            } ?? []
            
            print("✅ Decoded habits count: \(habits.count)")
            completion(.success(habits))
        }
    }
    
    // MARK: - Add Habit
    func addHabit(name: String, completion: @escaping (Error?) -> Void) {
        guard let ref = habitsRef() else {
            print("❌ habitsRef is nil")
            return
        }
        
        let habit = Habit(
            id: nil,
            name: name,
            createdAt: Date(),
            currentStreak: 0,
            bestStreak: 0,
            lastCompletedDate: nil,
            completedDates: [],
            isArchived: false,
            iconName: "flame.fill",
            colorHex: "#FF9500"
        )
        
        do {
            let docRef = try ref.addDocument(from: habit)
            print("✅ Habit added with id: \(docRef.documentID)")
            completion(nil)
        } catch {
            print("❌ Error adding habit: \(error.localizedDescription)")
            completion(error)
        }
    }
    
    func deleteHabit(_ habit: Habit, completion: @escaping (Error?) -> Void) {
        guard let ref = habitsRef(), let habitId = habit.id else { return }
        
        ref.document(habitId).delete { error in
            completion(error)
        }
    }
    
    func renameHabit(_ habit: Habit, newName: String, completion: @escaping (Error?) -> Void) {
        guard let ref = habitsRef(), let habitId = habit.id else { return }
        
        ref.document(habitId).updateData([
            "name": newName
        ]) { error in
            completion(error)
        }
    }
    
    func uncompleteHabit(_ habit: Habit, completion: @escaping (Error?) -> Void) {
        updateHabit(habit, completion: completion)
    }
    
    func updateHabitAppearance(_ habit: Habit, iconName: String, colorHex: String, completion: @escaping (Error?) -> Void) {
        guard let ref = habitsRef(), let habitId = habit.id else { return }
        
        ref.document(habitId).updateData([
            "iconName": iconName,
            "colorHex": colorHex
        ]) { error in
            completion(error)
        }
    }
}
