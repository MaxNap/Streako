//
//  SettingsView.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-13.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("dailyRemindersEnabled") private var dailyRemindersEnabled = false
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var onboarding: OnboardingViewModel
    @State private var showSignOutAlert = false

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
                                .foregroundColor(.white.opacity(0.75))
                                .font(.subheadline)
                        }
                    }
                    .tint(.green)
                    .accessibilityHint(Text("Schedules a local notification every day at 8 PM"))
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
                    .onboardingAnchor(.remindersToggle)
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 20))

                // Replay tutorial row — satisfies the "allow re-running the
                // tutorial from Settings" requirement.
                Button {
                    onboarding.restart()
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Replay Tutorial")
                                .foregroundColor(.white)
                                .font(.headline)
                            Text("Walk through the app again from the beginning")
                                .foregroundColor(.white.opacity(0.75))
                                .font(.subheadline)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer()
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundColor(.white.opacity(0.9))
                            .font(.body.weight(.semibold))
                    }
                    .frame(minHeight: 44)
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .accessibilityLabel(Text("Replay tutorial"))
                .accessibilityHint(Text("Restart the first-run tutorial from the welcome step"))
                .onboardingAnchor(.replayTutorial)

                if let user = authViewModel.user {
                    Text(user.email)
                        .foregroundColor(.white.opacity(0.75))
                        .font(.subheadline)
                        .accessibilityLabel(Text("Signed in as \(user.email)"))
                }

                Button {
                    showSignOutAlert = true
                } label: {
                    Text("Sign Out")
                        .font(.headline)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .accessibilityHint(Text("Signs you out of your Streako account"))

                Spacer()
            }
            .padding()
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
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AuthViewModel())
            .environmentObject(OnboardingViewModel())
    }
}
