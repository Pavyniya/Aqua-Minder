//
//  ReminderManager.swift
//  Aqua-Minder
//
//  Created by Praveen Kumar on 09/09/2025.
//

import Foundation
import UserNotifications
import SwiftUI

// Reminder settings model
struct ReminderSettings: Codable {
    var isEnabled: Bool
    var reminderTimes: [ReminderTime]
    var reminderFrequency: ReminderFrequency
    var reminderMessage: String
    
    init() {
        self.isEnabled = true
        self.reminderTimes = [
            ReminderTime(hour: 9, minute: 0, isEnabled: true),
            ReminderTime(hour: 12, minute: 0, isEnabled: true),
            ReminderTime(hour: 15, minute: 0, isEnabled: true),
            ReminderTime(hour: 18, minute: 0, isEnabled: true)
        ]
        self.reminderFrequency = .daily
        self.reminderMessage = "Time for a sip 💧"
    }
}

// Individual reminder time
struct ReminderTime: Codable, Identifiable {
    var id = UUID()
    var hour: Int
    var minute: Int
    var isEnabled: Bool
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let date = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
        return formatter.string(from: date)
    }
}

// Reminder frequency options
enum ReminderFrequency: String, CaseIterable, Codable {
    case daily = "Daily"
    case weekdays = "Weekdays Only"
    case weekends = "Weekends Only"
    case custom = "Custom"
    
    var displayName: String {
        return self.rawValue
    }
}

// Reminder manager class
class ReminderManager: ObservableObject {
    @Published var settings = ReminderSettings()
    @Published var notificationPermissionStatus: UNAuthorizationStatus = .notDetermined
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    init() {
        checkNotificationPermission()
        loadSettings()
    }
    
    // MARK: - Permission Management
    
    func requestNotificationPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                notificationPermissionStatus = granted ? .authorized : .denied
            }
            return granted
        } catch {
            print("Error requesting notification permission: \(error)")
            return false
        }
    }
    
    private func checkNotificationPermission() {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationPermissionStatus = settings.authorizationStatus
            }
        }
    }
    
    // MARK: - Settings Management
    
    private func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: "ReminderSettings"),
           let settings = try? JSONDecoder().decode(ReminderSettings.self, from: data) {
            self.settings = settings
        }
    }
    
    func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: "ReminderSettings")
        }
    }
    
    // MARK: - Notification Scheduling
    
    func scheduleReminders() {
        guard settings.isEnabled else {
            cancelAllReminders()
            return
        }
        
        // Cancel existing reminders
        cancelAllReminders()
        
        // Schedule new reminders
        for reminderTime in settings.reminderTimes where reminderTime.isEnabled {
            scheduleReminder(for: reminderTime)
        }
    }
    
    private func scheduleReminder(for reminderTime: ReminderTime) {
        let content = UNMutableNotificationContent()
        content.title = "Aqua Minder"
        content.body = settings.reminderMessage
        content.sound = .default
        content.badge = 1
        
        // Add action buttons
        let sipAction = UNNotificationAction(
            identifier: "SIP_ACTION",
            title: "Log Sip",
            options: [.foreground]
        )
        let bottleAction = UNNotificationAction(
            identifier: "BOTTLE_ACTION",
            title: "Log Bottle",
            options: [.foreground]
        )
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS_ACTION",
            title: "Dismiss",
            options: []
        )
        
        let category = UNNotificationCategory(
            identifier: "WATER_REMINDER",
            actions: [sipAction, bottleAction, dismissAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        notificationCenter.setNotificationCategories([category])
        content.categoryIdentifier = "WATER_REMINDER"
        
        // Create date components for the reminder time
        var dateComponents = DateComponents()
        dateComponents.hour = reminderTime.hour
        dateComponents.minute = reminderTime.minute
        
        // Create trigger based on frequency
        let trigger: UNNotificationTrigger
        
        switch settings.reminderFrequency {
        case .daily:
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        case .weekdays:
            // Only schedule for weekdays (Monday = 2, Sunday = 1)
            var weekdayComponents = dateComponents
            weekdayComponents.weekday = 2 // Monday
            trigger = UNCalendarNotificationTrigger(dateMatching: weekdayComponents, repeats: true)
        case .weekends:
            // Only schedule for weekends (Saturday = 7, Sunday = 1)
            var weekendComponents = dateComponents
            weekendComponents.weekday = 7 // Saturday
            trigger = UNCalendarNotificationTrigger(dateMatching: weekendComponents, repeats: true)
        case .custom:
            // For now, treat custom as daily
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        }
        
        // Create request
        let request = UNNotificationRequest(
            identifier: "water_reminder_\(reminderTime.hour)_\(reminderTime.minute)",
            content: content,
            trigger: trigger
        )
        
        // Schedule the notification
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling reminder: \(error)")
            }
        }
    }
    
    func cancelAllReminders() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    // MARK: - Reminder Management
    
    func addReminderTime(hour: Int, minute: Int) {
        let newReminder = ReminderTime(hour: hour, minute: minute, isEnabled: true)
        settings.reminderTimes.append(newReminder)
        saveSettings()
        scheduleReminders()
    }
    
    func removeReminderTime(at index: Int) {
        guard index < settings.reminderTimes.count else { return }
        settings.reminderTimes.remove(at: index)
        saveSettings()
        scheduleReminders()
    }
    
    func toggleReminderTime(at index: Int) {
        guard index < settings.reminderTimes.count else { return }
        settings.reminderTimes[index].isEnabled.toggle()
        saveSettings()
        scheduleReminders()
    }
    
    func updateReminderTime(at index: Int, hour: Int, minute: Int) {
        guard index < settings.reminderTimes.count else { return }
        settings.reminderTimes[index].hour = hour
        settings.reminderTimes[index].minute = minute
        saveSettings()
        scheduleReminders()
    }
    
    // MARK: - Quick Actions
    
    func handleNotificationAction(_ actionIdentifier: String, waterData: WaterDataManager) {
        switch actionIdentifier {
        case "SIP_ACTION":
            waterData.addWaterLog(amount: waterData.settings.sipSize)
        case "BOTTLE_ACTION":
            waterData.addWaterLog(amount: waterData.settings.bottleSize)
        case "DISMISS_ACTION":
            // Just dismiss, no action needed
            break
        default:
            break
        }
    }
    
    // MARK: - Testing
    
    func scheduleTestReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Aqua Minder - Test"
        content.body = "This is a test reminder! 💧"
        content.sound = .default
        
        // Schedule for 5 seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(
            identifier: "test_reminder",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling test reminder: \(error)")
            }
        }
    }
    
    // MARK: - Status
    
    var hasPermission: Bool {
        return notificationPermissionStatus == .authorized
    }
    
    var needsPermission: Bool {
        return notificationPermissionStatus == .notDetermined || notificationPermissionStatus == .denied
    }
    
    var isRemindersEnabled: Bool {
        return settings.isEnabled && hasPermission
    }
}
