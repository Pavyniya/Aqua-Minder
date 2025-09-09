//
//  HistoryView.swift
//  Aqua-Minder
//
//  Created by Praveen Kumar on 09/09/2025.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var waterData: WaterDataManager
    @State private var selectedTimeframe: Timeframe = .today
    @State private var showingDeleteAlert = false
    @State private var logToDelete: WaterLog?
    
    enum Timeframe: String, CaseIterable {
        case today = "Today"
        case week = "Week"
        case month = "Month"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with timeframe selector
                VStack(spacing: 16) {
                    // Timeframe picker
                    Picker("Timeframe", selection: $selectedTimeframe) {
                        ForEach(Timeframe.allCases, id: \.self) { timeframe in
                            Text(timeframe.rawValue).tag(timeframe)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Summary stats
                    SummaryStatsView(
                        waterData: waterData,
                        timeframe: selectedTimeframe
                    )
                }
                .padding(.top)
                .background(Color(.systemBackground))
                
                Divider()
                
                // Content based on selected timeframe
                switch selectedTimeframe {
                case .today:
                    TodayLogsView(
                        waterData: waterData,
                        onDeleteLog: { log in
                            logToDelete = log
                            showingDeleteAlert = true
                        }
                    )
                case .week:
                    WeeklyChartView(waterData: waterData)
                case .month:
                    MonthlyChartView(waterData: waterData)
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .alert("Delete Log", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let log = logToDelete {
                        deleteLog(log)
                    }
                }
            } message: {
                if let log = logToDelete {
                    Text("Are you sure you want to delete the \(formatAmount(log.amount)) log from \(formatTime(log.timestamp))?")
                }
            }
        }
    }
    
    private func deleteLog(_ log: WaterLog) {
        waterData.deleteLog(log)
    }
    
    private func formatAmount(_ amount: Int) -> String {
        if amount >= 1000 {
            return String(format: "%.1fL", Double(amount) / 1000.0)
        } else {
            return "\(amount)ml"
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Summary Stats View
struct SummaryStatsView: View {
    @ObservedObject var waterData: WaterDataManager
    let timeframe: HistoryView.Timeframe
    
    var body: some View {
        HStack(spacing: 20) {
            StatCard(
                title: "Total",
                value: formatAmount(totalAmount),
                color: .blue
            )
            
            StatCard(
                title: "Average",
                value: formatAmount(averageAmount),
                color: .green
            )
            
            StatCard(
                title: "Goal",
                value: "\(Int(goalPercentage))%",
                color: .orange
            )
        }
        .padding(.horizontal)
    }
    
    private var totalAmount: Int {
        switch timeframe {
        case .today:
            return waterData.todayTotal
        case .week:
            return waterData.getWeeklyTotal()
        case .month:
            return waterData.getMonthlyTotal()
        }
    }
    
    private var averageAmount: Int {
        let logs = getLogsForTimeframe()
        guard !logs.isEmpty else { return 0 }
        return totalAmount / logs.count
    }
    
    private var goalPercentage: Double {
        guard waterData.settings.dailyGoal > 0 else { return 0 }
        return min(Double(totalAmount) / Double(waterData.settings.dailyGoal), 1.0) * 100
    }
    
    private func getLogsForTimeframe() -> [WaterLog] {
        switch timeframe {
        case .today:
            return waterData.getTodayLogs()
        case .week:
            return waterData.getWeeklyLogs()
        case .month:
            return waterData.getMonthlyLogs()
        }
    }
    
    private func formatAmount(_ amount: Int) -> String {
        if amount >= 1000 {
            return String(format: "%.1fL", Double(amount) / 1000.0)
        } else {
            return "\(amount)ml"
        }
    }
}

// Stat Card Component
struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// Today's Logs View
struct TodayLogsView: View {
    @ObservedObject var waterData: WaterDataManager
    let onDeleteLog: (WaterLog) -> Void
    
    var body: some View {
        let todayLogs = waterData.getTodayLogs()
        
        if todayLogs.isEmpty {
            EmptyStateView()
        } else {
            List {
                ForEach(todayLogs) { log in
                    LogRowView(log: log, onDelete: {
                        onDeleteLog(log)
                    })
                }
            }
            .listStyle(PlainListStyle())
        }
    }
}

// Log Row View
struct LogRowView: View {
    let log: WaterLog
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Water drop icon
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "drop.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.blue)
            }
            
            // Log details
            VStack(alignment: .leading, spacing: 2) {
                Text(formatAmount(log.amount))
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(formatTime(log.timestamp))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 16))
                    .foregroundColor(.red)
                    .frame(width: 30, height: 30)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatAmount(_ amount: Int) -> String {
        if amount >= 1000 {
            return String(format: "%.1fL", Double(amount) / 1000.0)
        } else {
            return "\(amount)ml"
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Empty State View
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "drop.circle")
                .font(.system(size: 60))
                .foregroundColor(.blue.opacity(0.3))
            
            VStack(spacing: 8) {
                Text("No water logged today")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Start drinking water and log your intake!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

// Weekly Chart View
struct WeeklyChartView: View {
    @ObservedObject var waterData: WaterDataManager
    
    var body: some View {
        VStack {
            Text("Weekly Chart")
                .font(.headline)
                .padding()
            
            Text("Coming soon! This will show your water intake over the past 7 days.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

// Monthly Chart View
struct MonthlyChartView: View {
    @ObservedObject var waterData: WaterDataManager
    
    var body: some View {
        VStack {
            Text("Monthly Chart")
                .font(.headline)
                .padding()
            
            Text("Coming soon! This will show your water intake over the past 30 days.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    HistoryView()
        .environmentObject(WaterDataManager())
}
