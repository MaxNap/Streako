//
//  HabitDetailView.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-09.
//

import SwiftUI

struct HabitDetailView: View {
    let habitId: String
    
    @EnvironmentObject var habitsViewModel: HabitsViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showDeleteAlert = false
    @State private var editedName = ""
    
    @FocusState private var isEditingName: Bool
    
    private var habit: Habit? {
        habitsViewModel.habits.first { $0.id == habitId }
    }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            if let habit {
                contentView(for: habit)
            } else {
                Text("Habit not found")
                    .foregroundColor(.white)
            }
        }
        .navigationTitle("Habit")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Habit?", isPresented: $showDeleteAlert) {
            if let habit {
                Button("Delete", role: .destructive) {
                    habitsViewModel.deleteHabit(habit)
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This action cannot be undone.")
        }
    }
    
    @ViewBuilder
    private func contentView(for habit: Habit) -> some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 88, height: 88)
                    .overlay {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 34))
                            .foregroundColor(habit.isCompletedToday ? .purple : .orange)
                    }
                
                VStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(isEditingName ? Color.white.opacity(0.10) : Color.white.opacity(0.06))
                            .animation(.easeInOut(duration: 0.2), value: isEditingName)
                        
                        HStack {
                            TextField("Enter habit name", text: $editedName)
                                .textFieldStyle(.plain)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .focused($isEditingName)
                            
                            Image(systemName: "pencil")
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 16)
                    }
                    .frame(height: 56)
                    .frame(maxWidth: 320)
                    
                    Text("Tap to edit name")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text(habit.isCompletedToday ? "Completed today" : "Not completed today")
                    .font(.subheadline)
                    .foregroundColor(habit.isCompletedToday ? .green : .gray)
            }
            .padding(.top, 30)
            
            VStack(spacing: 14) {
                infoRow(title: "Current streak", value: "\(habit.currentStreak) days")
                infoRow(title: "Best streak", value: "\(habit.bestStreak) days")
                infoRow(title: "Created", value: formattedCreatedDate(from: habit.createdAt))
            }
            .padding()
            .background(Color.white.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            
            if editedName.trimmingCharacters(in: .whitespacesAndNewlines) != habit.name &&
                !editedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                
                Button {
                    let trimmedName = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
                    habitsViewModel.renameHabit(habit, newName: trimmedName) {
                        editedName = trimmedName
                    }
                } label: {
                    Text("Update Habit Name")
                        .frame(maxWidth: 320)
                        .padding()
                        .background(Color.green.opacity(0.18))
                        .foregroundColor(.green)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            
            Button {
                if habit.isCompletedToday {
                    habitsViewModel.uncompleteHabit(habit)
                } else {
                    habitsViewModel.completeHabit(habit)
                }
            } label: {
                Text(habit.isCompletedToday ? "Undo Today's Completion" : "Mark as Complete")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(habit.isCompletedToday ? Color.green.opacity(0.18) : Color.purple.opacity(0.18))
                    .foregroundColor(habit.isCompletedToday ? .green : .purple)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            
            Spacer()
            
            Button(role: .destructive) {
                showDeleteAlert = true
            } label: {
                Text("Delete Habit")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.18))
                    .foregroundColor(.red)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding()
        .onAppear {
            if editedName.isEmpty {
                editedName = habit.name
            }
        }
    }
    
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .foregroundColor(.white)
                .fontWeight(.semibold)
        }
    }
    
    private func formattedCreatedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        HabitDetailView(habitId: "1")
            .environmentObject(HabitsViewModel())
    }
}
