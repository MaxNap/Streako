//
//  TodayProgressCardView.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-13.
//

import SwiftUI

struct TodayProgressCardView: View {
    let completedCount: Int
    let totalCount: Int
    
    private var completionRate: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }
    
    private var completionRatePercent: Int {
        Int(completionRate * 100)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Progress")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("\(completedCount) of \(totalCount) habits completed")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("\(completionRatePercent)%")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
            }
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 12)
                
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.purple)
                        .frame(
                            width: max(0, geometry.size.width * completionRate),
                            height: 12
                        )
                }
                .frame(height: 12)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        TodayProgressCardView(
            completedCount: 3,
            totalCount: 5
        )
        .padding()
    }
}
