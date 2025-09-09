//
//  ContentView.swift
//  Aqua-Minder
//
//  Created by Praveen Kumar on 09/09/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var waterData = WaterDataManager()
    @State private var showUndo = false
    @State private var lastLogAmount = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.cyan.opacity(0.05)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    // Header with Settings button
                    VStack(spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Aqua Minder")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Text("Stay hydrated, stay healthy")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            NavigationLink(destination: SettingsView(waterData: waterData)) {
                                Image(systemName: "gearshape.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                    .frame(width: 44, height: 44)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(22)
                            }
                        }
                    }
                    .padding(.top, 20)
                    
                    // Progress Ring (tappable to open history)
                    NavigationLink(destination: HistoryView(waterData: waterData)) {
                        VStack(spacing: 8) {
                            ProgressRingView(
                                progress: waterData.progressPercentage,
                                totalAmount: waterData.todayTotal,
                                goalAmount: waterData.settings.dailyGoal
                            )
                            
                            Text("Tap to view history")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .opacity(0.7)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Quick Logging Button
                    QuickLogButton(waterData: waterData, showUndo: $showUndo, lastLogAmount: $lastLogAmount)
                    
                    Spacer()
                }
                .padding()
                
                // Undo Snackbar
                if showUndo {
                    VStack {
                        Spacer()
                        UndoSnackbar(
                            amount: lastLogAmount,
                            onUndo: {
                                waterData.removeLastLog()
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showUndo = false
                                }
                            },
                            onDismiss: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showUndo = false
                                }
                            }
                        )
                        .padding(.bottom, 50)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// Progress Ring View
struct ProgressRingView: View {
    let progress: Double
    let totalAmount: Int
    let goalAmount: Int
    
    @State private var isGoalReached = false
    @State private var celebrationScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.blue.opacity(0.2), lineWidth: 20)
                .frame(width: 200, height: 200)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: isGoalReached ? [Color.green, Color.mint] : [Color.blue, Color.cyan]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
                .scaleEffect(celebrationScale)
                .animation(.easeInOut(duration: 0.6), value: celebrationScale)
            
            // Celebration glow effect when goal is reached
            if isGoalReached {
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.green.opacity(0.3), Color.mint.opacity(0.3)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 30, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .opacity(0.6)
                    .scaleEffect(celebrationScale * 1.1)
            }
            
            // Center content
            VStack(spacing: 4) {
                Text("\(formatAmount(totalAmount))")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(isGoalReached ? .green : .primary)
                
                Text("of \(formatAmount(goalAmount))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundColor(isGoalReached ? .green : .blue)
                    .fontWeight(.medium)
                
                // Goal reached celebration text
                if isGoalReached {
                    Text("🎉 Goal Reached! 🎉")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .scaleEffect(celebrationScale)
                }
            }
        }
        .onChange(of: progress) { _, newProgress in
            let wasGoalReached = isGoalReached
            isGoalReached = newProgress >= 1.0
            
            // Trigger celebration animation when goal is first reached
            if !wasGoalReached && isGoalReached {
                withAnimation(.easeInOut(duration: 0.3)) {
                    celebrationScale = 1.2
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        celebrationScale = 1.0
                    }
                }
            }
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

// Quick Log Button
struct QuickLogButton: View {
    @ObservedObject var waterData: WaterDataManager
    @Binding var showUndo: Bool
    @Binding var lastLogAmount: Int
    @State private var showBottleOptions = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Main log button
            Button(action: {
                logSip()
            }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.cyan]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    Image(systemName: "drop.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
            }
            .scaleEffect(showBottleOptions ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: showBottleOptions)
            .onTapGesture {
                logSip()
            }
            .onLongPressGesture(minimumDuration: 0.5) {
                showBottleOptions = true
            }
            
            // Instructions
            VStack(spacing: 8) {
                Text("Tap to log a sip")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Hold for bottle options")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Bottle options (shown on long press)
            if showBottleOptions {
                VStack(spacing: 12) {
                    Text("Choose bottle size:")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 20) {
                        BottleOptionButton(
                            size: waterData.settings.bottleSize,
                            label: "Bottle",
                            action: {
                                logBottle(waterData.settings.bottleSize)
                                showBottleOptions = false
                            }
                        )
                        
                        BottleOptionButton(
                            size: 500,
                            label: "Small",
                            action: {
                                logBottle(500)
                                showBottleOptions = false
                            }
                        )
                        
                        BottleOptionButton(
                            size: 1000,
                            label: "Large",
                            action: {
                                logBottle(1000)
                                showBottleOptions = false
                            }
                        )
                    }
                    
                    Button("Cancel") {
                        showBottleOptions = false
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
        }
    }
    
    private func logSip() {
        // Add haptic feedback for successful log
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        waterData.addWaterLog(amount: waterData.settings.sipSize)
        lastLogAmount = waterData.settings.sipSize
        showUndoMessage()
    }
    
    private func logBottle(_ amount: Int) {
        // Add haptic feedback for successful log
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        waterData.addWaterLog(amount: amount)
        lastLogAmount = amount
        showUndoMessage()
    }
    
    private func showUndoMessage() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showUndo = true
        }
        
        // Auto-hide after 4 seconds (increased from 3 for better UX)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showUndo = false
            }
        }
    }
}

// Bottle Option Button
struct BottleOptionButton: View {
    let size: Int
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("\(size)ml")
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

// Undo Snackbar
struct UndoSnackbar: View {
    let amount: Int
    let onUndo: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Water drop icon with background
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 32, height: 32)
                
                Image(systemName: "drop.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
            }
            
            // Log message
            VStack(alignment: .leading, spacing: 2) {
                Text("Water logged!")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("\(formatAmount(amount)) added")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 8) {
                Button("Undo") {
                    // Add haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    onUndo()
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue)
                .cornerRadius(20)
                
                Button(action: {
                    // Add haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    onDismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 24, height: 24)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 20)
    }
    
    private func formatAmount(_ amount: Int) -> String {
        if amount >= 1000 {
            return String(format: "%.1fL", Double(amount) / 1000.0)
        } else {
            return "\(amount)ml"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}