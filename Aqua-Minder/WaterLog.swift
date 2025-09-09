//
//  WaterLog.swift
//  Aqua-Minder
//
//  Created by Praveen Kumar on 09/09/2025.
//

import Foundation

// Data model for a single water log entry
struct WaterLog: Identifiable, Codable {
    let id = UUID()
    let amount: Int // Amount in milliliters
    let timestamp: Date
    
    init(amount: Int) {
        self.amount = amount
        self.timestamp = Date()
    }
}

// Data model for daily water goal settings
struct WaterSettings: Codable {
    var dailyGoal: Int // Daily goal in milliliters
    var sipSize: Int // Default sip size in milliliters
    var bottleSize: Int // Default bottle size in milliliters
    
    init() {
        self.dailyGoal = 2500 // Default 2.5L
        self.sipSize = 50 // Default 50ml sip
        self.bottleSize = 750 // Default 750ml bottle
    }
}

// Observable class to manage water data
class WaterDataManager: ObservableObject {
    @Published var waterLogs: [WaterLog] = []
    @Published var settings = WaterSettings()
    
    // Calculate today's total water intake
    var todayTotal: Int {
        let calendar = Calendar.current
        let today = Date()
        
        return waterLogs.filter { log in
            calendar.isDate(log.timestamp, inSameDayAs: today)
        }.reduce(0) { $0 + $1.amount }
    }
    
    // Calculate progress percentage (0.0 to 1.0)
    var progressPercentage: Double {
        guard settings.dailyGoal > 0 else { return 0.0 }
        return min(Double(todayTotal) / Double(settings.dailyGoal), 1.0)
    }
    
    // Add a water log
    func addWaterLog(amount: Int) {
        let log = WaterLog(amount: amount)
        waterLogs.append(log)
    }
    
    // Remove the last water log (for undo functionality)
    func removeLastLog() {
        if !waterLogs.isEmpty {
            waterLogs.removeLast()
        }
    }
    
    // Get today's logs
    func getTodayLogs() -> [WaterLog] {
        let calendar = Calendar.current
        let today = Date()
        
        return waterLogs.filter { log in
            calendar.isDate(log.timestamp, inSameDayAs: today)
        }.sorted { $0.timestamp > $1.timestamp }
    }
    
    // Get weekly logs (past 7 days)
    func getWeeklyLogs() -> [WaterLog] {
        let calendar = Calendar.current
        let today = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: today) ?? today
        
        return waterLogs.filter { log in
            log.timestamp >= weekAgo && log.timestamp <= today
        }.sorted { $0.timestamp > $1.timestamp }
    }
    
    // Get monthly logs (past 30 days)
    func getMonthlyLogs() -> [WaterLog] {
        let calendar = Calendar.current
        let today = Date()
        let monthAgo = calendar.date(byAdding: .day, value: -30, to: today) ?? today
        
        return waterLogs.filter { log in
            log.timestamp >= monthAgo && log.timestamp <= today
        }.sorted { $0.timestamp > $1.timestamp }
    }
    
    // Get weekly total
    func getWeeklyTotal() -> Int {
        return getWeeklyLogs().reduce(0) { $0 + $1.amount }
    }
    
    // Get monthly total
    func getMonthlyTotal() -> Int {
        return getMonthlyLogs().reduce(0) { $0 + $1.amount }
    }
    
    // Delete a specific log
    func deleteLog(_ log: WaterLog) {
        waterLogs.removeAll { $0.id == log.id }
    }
}
