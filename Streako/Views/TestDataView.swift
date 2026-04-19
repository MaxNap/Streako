//
//  TestDataView.swift
//  Streako
//
//  Created for testing purposes
//

import SwiftUI

struct TestDataView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var habitsViewModel: HabitsViewModel
    
    @State private var isGenerating = false
    @State private var isClearing = false
    @State private var message = ""
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "flask.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.purple)
                        
                        Text("Test Data Generator")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Simulate 1 week of realistic app usage")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // What it creates
                    VStack(alignment: .leading, spacing: 16) {
                        Text("What This Creates:")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        InfoRow(icon: "figure.walk", color: .orange, title: "Morning Exercise", subtitle: "7/7 days - Perfect week!")
                        InfoRow(icon: "book.fill", color: .green, title: "Read Book", subtitle: "6/7 days - Missed day 3")
                        InfoRow(icon: "bolt.fill", color: .purple, title: "Meditation", subtitle: "5/7 days - Strong finish")
                        InfoRow(icon: "drop.fill", color: .blue, title: "Drink Water", subtitle: "4/7 days - Scattered")
                        InfoRow(icon: "heart.fill", color: .red, title: "Journal", subtitle: "2/7 days - Needs work")
                        
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Today all habits completed - you'll see confetti!")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.05))
                    )
                    
                    // Generate button
                    Button {
                        generateTestData()
                    } label: {
                        HStack {
                            if isGenerating {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "wand.and.stars")
                                Text("Generate 1 Week of Data")
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(isGenerating || isClearing)
                    
                    // Clear button
                    Button {
                        showAlert = true
                    } label: {
                        HStack {
                            if isClearing {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "trash")
                                Text("Clear All Data")
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(isGenerating || isClearing)
                    
                    // Status message
                    if !message.isEmpty {
                        Text(message)
                            .font(.subheadline)
                            .foregroundColor(.green)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.green.opacity(0.1))
                            )
                    }
                    
                    // Warning
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.yellow)
                            Text("For Testing Only")
                                .font(.headline)
                                .foregroundColor(.yellow)
                        }
                        
                        Text("This will create 5 habits with 1 week of history. Use this to test features without manually creating data. Remove this view before production!")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.yellow.opacity(0.1))
                    )
                }
                .padding()
            }
        }
        .navigationTitle("Test Data")
        .navigationBarTitleDisplayMode(.inline)
        .alert(alertTitle, isPresented: $showAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete All", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func generateTestData() {
        isGenerating = true
        message = ""
        
        TestDataGenerator.shared.generate1WeekData { result in
            DispatchQueue.main.async {
                isGenerating = false
                
                switch result {
                case .success:
                    message = "✅ Test data created! Go back to Home to see it."
                    
                    // Refresh habits
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        habitsViewModel.fetchHabits()
                    }
                    
                case .failure(let error):
                    alertTitle = "Error"
                    alertMessage = error.localizedDescription
                    showAlert = true
                }
            }
        }
    }
    
    private func clearAllData() {
        isClearing = true
        message = ""
        
        TestDataGenerator.shared.clearAllData { result in
            DispatchQueue.main.async {
                isClearing = false
                
                switch result {
                case .success:
                    message = "✅ All data cleared!"
                    
                    // Refresh habits
                    habitsViewModel.fetchHabits()
                    
                case .failure(let error):
                    alertTitle = "Error"
                    alertMessage = error.localizedDescription
                    showAlert = true
                }
            }
        }
    }
}

struct InfoRow: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        TestDataView()
            .environmentObject(HabitsViewModel())
    }
}

