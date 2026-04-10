//
//  RootView.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-08.
//

import SwiftUI

struct RootView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.user != nil {
                HomeView()
                    .environmentObject(authViewModel)
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
    }
}

#Preview {
    RootView()
}


