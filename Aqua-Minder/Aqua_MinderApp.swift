//
//  Aqua_MinderApp.swift
//  Aqua-Minder
//
//  Created by Praveen Kumar on 09/09/2025.
//

import SwiftUI
import UserNotifications

@main
struct Aqua_MinderApp: App {
    @StateObject private var waterData = WaterDataManager()
    @State private var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
                    .environmentObject(waterData)
                    .onAppear {
                        setupNotificationHandling()
                    }
            } else {
                OnboardingView(waterData: waterData)
                    .onAppear {
                        // Listen for onboarding completion
                        NotificationCenter.default.addObserver(
                            forName: NSNotification.Name("OnboardingCompleted"),
                            object: nil,
                            queue: .main
                        ) { _ in
                            hasCompletedOnboarding = true
                        }
                    }
            }
        }
    }
    
    private func setupNotificationHandling() {
        // Handle notification actions
        UNUserNotificationCenter.current().delegate = NotificationDelegate(waterData: waterData)
    }
}

// Notification delegate to handle interactive notifications
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    let waterData: WaterDataManager
    
    init(waterData: WaterDataManager) {
        self.waterData = waterData
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        waterData.reminderManager.handleNotificationAction(response.actionIdentifier, waterData: waterData)
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.alert, .sound, .badge])
    }
}
