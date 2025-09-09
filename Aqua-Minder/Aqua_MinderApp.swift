//
//  Aqua_MinderApp.swift
//  Aqua-Minder
//
//  Created by Praveen Kumar on 09/09/2025.
//

import SwiftUI

@main
struct Aqua_MinderApp: App {
    @StateObject private var waterData = WaterDataManager()
    @State private var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
                    .environmentObject(waterData)
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
}
