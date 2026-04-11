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
    @State private var selectedIcon = "flame.fill"
    @State private var selectedColorHex = "#FF9500"
    
    @FocusState private var isEditingName: Bool
    
    private var habit: Habit? {
        habitsViewModel.habits.first { $0.id == habitId }
    }
    
    private let iconOptions = [
        "flame.fill",
        "book.fill",
        "figure.walk",
        "drop.fill",
        "heart.fill",
        "bolt.fill"
    ]
    
    private let colorOptions = [
        "#FF9500", // orange
        "#AF52DE", // purple
        "#34C759", // green
        "#FF3B30", // red
        "#007AFF", // blue
        "#FFD60A"  // yellow
    ]
    
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
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 88, height: 88)
                        .overlay {
                            Image(systemName: selectedIcon)
                                .font(.system(size: 34))
                                .foregroundColor(Color(hex: selectedColorHex))
                        }
                    
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
                                .submitLabel(.done)
                            
                            Image(systemName: "pencil")
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 16)
                    }
                    .frame(height: 56)
                    .frame(maxWidth: 320)
                    
                    if editedName.trimmingCharacters(in: .whitespacesAndNewlines) != habit.name &&
                        !editedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        
                        Button {
                            let trimmedName = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
                            habitsViewModel.renameHabit(habit, newName: trimmedName) {
                                editedName = trimmedName
                                isEditingName = false
                            }
                        } label: {
                            Text("Save Name")
                                .frame(maxWidth: 220)
                                .padding(.vertical, 10)
                                .background(Color.green.opacity(0.18))
                                .foregroundColor(.green)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
                    }
                    
                    Text(habit.isCompletedToday ? "Completed today" : "Not completed today")
                        .font(.subheadline)
                        .foregroundColor(habit.isCompletedToday ? .green : .gray)
                }
                .padding(.top, 30)
                .animation(.easeInOut(duration: 0.22), value: editedName)
                
                VStack(spacing: 14) {
                    infoRow(title: "Current streak", value: "\(habit.currentStreak) days")
                    infoRow(title: "Best streak", value: "\(habit.bestStreak) days")
                    infoRow(title: "Created", value: formattedCreatedDate(from: habit.createdAt))
                }
                .padding()
                .background(Color.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Appearance")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Icon")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 12) {
                            ForEach(iconOptions, id: \.self) { icon in
                                Button {
                                    selectedIcon = icon
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(Color.white.opacity(0.08))
                                            .frame(width: 44, height: 44)
                                        
                                        Circle()
                                            .stroke(
                                                selectedIcon == icon ? Color(hex: selectedColorHex) : Color.clear,
                                                lineWidth: 2
                                            )
                                            .frame(width: 44, height: 44)
                                        
                                        Image(systemName: icon)
                                            .foregroundColor(selectedIcon == icon ? Color(hex: selectedColorHex) : .white)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Color")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 12) {
                            ForEach(colorOptions, id: \.self) { hex in
                                Button {
                                    selectedColorHex = hex
                                } label: {
                                    Circle()
                                        .fill(Color(hex: hex))
                                        .frame(width: 28, height: 28)
                                        .overlay {
                                            if selectedColorHex == hex {
                                                Circle()
                                                    .stroke(Color.white, lineWidth: 2)
                                                    .frame(width: 34, height: 34)
                                            }
                                        }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    if selectedIcon != habit.iconName || selectedColorHex != habit.colorHex {
                        Button {
                            habitsViewModel.updateHabitAppearance(habit, iconName: selectedIcon, colorHex: selectedColorHex) {
                            }
                        } label: {
                            Text("Update Appearance")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: selectedColorHex).opacity(0.18))
                                .foregroundColor(Color(hex: selectedColorHex))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                }
                .padding()
                .background(Color.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                
                
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
            .padding(.bottom, 24)
        }
        .onAppear {
            if editedName.isEmpty {
                editedName = habit.name
            }
            selectedIcon = habit.iconName
            selectedColorHex = habit.colorHex
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
