//
//  SettingsView.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-13.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("dailyRemindersEnabled") private var dailyRemindersEnabled = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var habitsViewModel: HabitsViewModel
    @State private var showSignOutAlert = false
    @State private var showDeleteAccountAlert = false
    @State private var showOnboarding = false
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 16) {
                    Toggle(isOn: $dailyRemindersEnabled) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Daily Reminders")
                                .foregroundColor(.white)
                                .font(.headline)
                            
                            Text("Get a reminder every day at 8:00 PM")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        }
                    }
                    .tint(.green)
                    .onChange(of: dailyRemindersEnabled) { _, newValue in
                        if newValue {
                            NotificationManager.shared.requestAuthorization { granted in
                                if granted {
                                    NotificationManager.shared.scheduleDailyReminder(hour: 20, minute: 0)
                                } else {
                                    DispatchQueue.main.async {
                                        dailyRemindersEnabled = false
                                    }
                                }
                            }
                        } else {
                            NotificationManager.shared.removeDailyReminder()
                        }
                    }
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                // Tutorial section
                VStack(spacing: 0) {
                    Button {
                        showOnboarding = true
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("View Tutorial")
                                    .foregroundColor(.white)
                                    .font(.headline)
                                
                                Text("Learn how to use Streako")
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "play.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                }
                
                // Test Data Generator (for development/testing only)
                #if DEBUG
                NavigationLink {
                    TestDataView()
                        .environmentObject(habitsViewModel)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("🧪 Test Data Generator")
                                .foregroundColor(.white)
                                .font(.headline)
                            
                            Text("Populate app with sample data")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "flask.fill")
                            .font(.title2)
                            .foregroundColor(.purple)
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                #endif
                
                if let user = authViewModel.user {
                    Text(user.email)
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
                
                Button {
                    showSignOutAlert = true
                } label: {
                    Text("Sign Out")
                        .font(.headline)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                
                Button {
                    showDeleteAccountAlert = true
                } label: {
                    Text("Delete Account")
                        .font(.headline)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                
                Spacer()
            }
            .padding()
            
            // Onboarding tutorial overlay
            if showOnboarding {
                OnboardingTutorialView(isPresented: $showOnboarding)
                    .transition(.opacity)
                    .zIndex(100)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Sign Out", isPresented: $showSignOutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                authViewModel.signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .alert("Delete Account", isPresented: $showDeleteAccountAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                authViewModel.deleteAccount { success in
                    if !success {
                        // Error is already shown in authViewModel.errorMessage
                        // You could show an additional alert here if needed
                    }
                }
            }
        } message: {
            Text("This will permanently delete your account and all associated data. This action cannot be undone.")
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AuthViewModel())
    }
}
