//
//  EmptyStateView.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-14.
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.6))
            
            Text("No habits yet")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            Text("Start building consistency one step at a time")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text("Tap + to add your first habit")
                .font(.footnote)
                .foregroundColor(.gray.opacity(0.7))
                .padding(.top, 8)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 32)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        EmptyStateView()
    }
}
