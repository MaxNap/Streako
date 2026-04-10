//
//  AddHabitView.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-09.
//

import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var habitsViewModel: HabitsViewModel
    
    @State private var habitName = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("Habit name", text: $habitName)
                    .padding()
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(10)
                
                Button("Save Habit") {
                    let trimmedName = habitName.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmedName.isEmpty else { return }
                    
                    habitsViewModel.addHabit(name: trimmedName) {
                        dismiss()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Spacer()
            }
            .padding()
            .navigationTitle("New Habit")
        }
    }
}

#Preview {
    AddHabitView()
}
