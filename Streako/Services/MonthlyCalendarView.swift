//
//  MonthlyCalendarView.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-17.
//

import SwiftUI

struct MonthlyCalendarView: View {
    @Environment(\.dismiss) private var dismiss
    let completedDates: Set<String>
    @State private var selectedMonth: Date = Date()
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["M", "T", "W", "T", "F", "S", "S"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Month selector
                    monthSelector
                    
                    // Calendar grid
                    calendarGrid
                    
                    // Stats summary
                    monthStats
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Progress Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
    
    private var monthSelector: some View {
        HStack {
            Button {
                withAnimation {
                    selectedMonth = calendar.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
            }
            
            Spacer()
            
            Text(monthYearString)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Button {
                withAnimation {
                    selectedMonth = calendar.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
            }
            .disabled(calendar.isDate(selectedMonth, equalTo: Date(), toGranularity: .month))
            .opacity(calendar.isDate(selectedMonth, equalTo: Date(), toGranularity: .month) ? 0.3 : 1)
        }
    }
    
    private var calendarGrid: some View {
        VStack(spacing: 12) {
            // Days of week header
            HStack(spacing: 0) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar days
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isCompleted: isDateCompleted(date),
                            isToday: calendar.isDateInToday(date),
                            isFuture: date > Date()
                        )
                    } else {
                        Color.clear
                            .frame(height: 44)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    private var monthStats: some View {
        HStack(spacing: 16) {
            VStack(spacing: 4) {
                Text("\(completedDaysInMonth)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.purple)
                
                Text("Completed")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.purple.opacity(0.3), lineWidth: 1)
                    )
            )
            
            VStack(spacing: 4) {
                Text("\(completionPercentage)%")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.green)
                
                Text("Success Rate")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.green.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Helper Properties
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedMonth)
    }
    
    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedMonth),
              let firstWeekday = calendar.dateComponents([.weekday], from: monthInterval.start).weekday else {
            return []
        }
        
        let numberOfDays = calendar.range(of: .day, in: .month, for: selectedMonth)?.count ?? 0
        
        // Adjust for Monday start (weekday 1 = Sunday, 2 = Monday, etc.)
        let adjustedFirstWeekday = firstWeekday == 1 ? 6 : firstWeekday - 2
        
        var days: [Date?] = Array(repeating: nil, count: adjustedFirstWeekday)
        
        for day in 1...numberOfDays {
            if let date = calendar.date(bySetting: .day, value: day, of: selectedMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func isDateCompleted(_ date: Date) -> Bool {
        let dateString = Habit.dateString(from: date)
        return completedDates.contains(dateString)
    }
    
    private var completedDaysInMonth: Int {
        daysInMonth.compactMap { $0 }.filter { date in
            !date.isFuture && isDateCompleted(date)
        }.count
    }
    
    private var completionPercentage: Int {
        let pastDays = daysInMonth.compactMap { $0 }.filter { !$0.isFuture }
        guard !pastDays.isEmpty else { return 0 }
        let completed = pastDays.filter { isDateCompleted($0) }.count
        return Int((Double(completed) / Double(pastDays.count)) * 100)
    }
}

// MARK: - Day Cell

struct DayCell: View {
    let date: Date
    let isCompleted: Bool
    let isToday: Bool
    let isFuture: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: 14, weight: isToday ? .bold : .medium))
                .foregroundColor(textColor)
        }
        .frame(height: 44)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                if isCompleted {
                    Circle()
                        .fill(Color.purple)
                }
                
                if isToday {
                    Circle()
                        .strokeBorder(Color.purple, lineWidth: 2)
                }
            }
        )
        .opacity(isFuture ? 0.3 : 1)
    }
    
    private var textColor: Color {
        if isCompleted {
            return .white
        } else if isToday {
            return .white
        } else if isFuture {
            return .gray
        } else {
            return .white.opacity(0.7)
        }
    }
}

// MARK: - Date Extension

extension Date {
    var isFuture: Bool {
        self > Date()
    }
}

#Preview {
    MonthlyCalendarView(completedDates: Set([
        "2026-04-15",
        "2026-04-16",
        "2026-04-17",
        "2026-04-14",
        "2026-04-10"
    ]))
}
