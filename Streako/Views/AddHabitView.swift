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
    @State private var selectedIcon = "flame.fill"
    @State private var selectedColorHex = "#FF9500"
    @FocusState private var isEditingName: Bool
    
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
    
    private var trimmedHabitName: String {
        habitName.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var canSave: Bool {
        !trimmedHabitName.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        previewSection
                        nameSection
                        appearanceSection
                        saveButton
                    }
                    .padding()
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var previewSection: some View {
        VStack(spacing: 14) {
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 92, height: 92)
                .overlay {
                    Image(systemName: selectedIcon)
                        .font(.system(size: 34))
                        .foregroundColor(Color(hex: selectedColorHex))
                }
            
            Text(trimmedHabitName.isEmpty ? "Your Habit" : trimmedHabitName)
                .font(.title2.weight(.bold))
                .foregroundColor(.white)
            
            Text("Preview")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.top, 12)
    }
    
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Name")
                .font(.headline)
                .foregroundColor(.white)
            
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(isEditingName ? Color.white.opacity(0.10) : Color.white.opacity(0.06))
                    .animation(.easeInOut(duration: 0.2), value: isEditingName)
                
                HStack {
                    TextField("Enter habit name", text: $habitName)
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
        }
        .padding()
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 18) {
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
                                    .frame(width: 46, height: 46)
                                
                                Circle()
                                    .stroke(
                                        selectedIcon == icon ? Color(hex: selectedColorHex) : Color.clear,
                                        lineWidth: 2
                                    )
                                    .frame(width: 46, height: 46)
                                
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
                                .frame(width: 30, height: 30)
                                .overlay {
                                    if selectedColorHex == hex {
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2)
                                            .frame(width: 36, height: 36)
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private var saveButton: some View {
        Button {
            guard canSave else { return }
            
            habitsViewModel.addHabit(
                name: trimmedHabitName,
                iconName: selectedIcon,
                colorHex: selectedColorHex
            ) {
                isEditingName = false
                dismiss()
            }
        } label: {
            Text("Create Habit")
                .frame(maxWidth: .infinity)
                .padding()
                .background(canSave ? Color.green.opacity(0.18) : Color.white.opacity(0.06))
                .foregroundColor(canSave ? .green : .gray)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(!canSave)
    }
}

#Preview {
    AddHabitView()
        .environmentObject(HabitsViewModel())
}
