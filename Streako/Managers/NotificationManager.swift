//
//  NotificationManager.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-13.
//

import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                Log.error("Notification permission error: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            Log.success("Notification permission granted: \(granted)")
            completion(granted)
        }
    }
    
    func scheduleDailyReminder(hour: Int = 20, minute: Int = 0) {
        let content = UNMutableNotificationContent()
        content.title = "Don’t break your streak"
        content.body = "Open Streako and complete your habits for today."
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "daily_streako_reminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily_streako_reminder"])
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                Log.error("Failed to schedule daily reminder: \(error.localizedDescription)")
            } else {
                Log.success("Daily reminder scheduled for \(hour):\(String(format: "%02d", minute))")
            }
        }
    }
    
    func removeDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily_streako_reminder"])
        Log.info("Daily reminder removed")
    }
    
    func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Reminder"
        content.body = "This is a test notification from Streako."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(
            identifier: "test_streako_notification",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                Log.error("Failed to schedule test notification: \(error.localizedDescription)")
            } else {
                Log.success("Test notification scheduled")
            }
        }
    }
}
