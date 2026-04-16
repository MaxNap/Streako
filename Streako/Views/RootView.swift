//
//  RootView.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-08.
//

import SwiftUI

struct RootView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var onboarding = OnboardingViewModel()

    var body: some View {
        Group {
            if authViewModel.user != nil {
                HomeView()
                    .environmentObject(authViewModel)
                    .environmentObject(onboarding)
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
        // Rebind onboarding when the signed-in user changes so that the
        // completion flag is keyed per UID (Account A's "done" flag does
        // not suppress the tutorial for Account B on the same device).
        .onChange(of: authViewModel.user?.uid) { _, newUID in
            onboarding.bind(uid: newUID)
        }
        .onAppear {
            onboarding.bind(uid: authViewModel.user?.uid)
        }
    }
}

#Preview {
    RootView()
}
