//
//  SettingsView.swift
//  Aqua-Minder
//
//  Created by Praveen Kumar on 09/09/2025.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var waterData: WaterDataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showingResetAlert = false
    @State private var showingSaveConfirmation = false
    
    var body: some View {
        NavigationView {
            List {
                // Daily Goal Section
                Section {
                    DailyGoalSection(waterData: waterData)
                } header: {
                    Text("Daily Goal")
                } footer: {
                    Text("Set your daily water intake target. The app will track your progress toward this goal.")
                }
                
                // Sip Size Section
                Section {
                    SipSizeSection(waterData: waterData)
                } header: {
                    Text("Sip Size")
                } footer: {
                    Text("This is the amount logged when you tap the water button once.")
                }
                
                // Bottle Sizes Section
                Section {
                    BottleSizesSection(waterData: waterData)
                } header: {
                    Text("Bottle Sizes")
                } footer: {
                    Text("Customize your bottle size presets for quick logging.")
                }
                
                // Quick Actions Section
                Section {
                    QuickActionsSection(
                        waterData: waterData,
                        showingResetAlert: $showingResetAlert
                    )
                } header: {
                    Text("Quick Actions")
                }
                
                // App Info Section
                Section {
                    AppInfoSection()
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSettings()
                    }
                    .fontWeight(.semibold)
                }
            }
            .alert("Reset All Data", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("This will delete all your water logs and reset settings to defaults. This action cannot be undone.")
            }
            .alert("Settings Saved", isPresented: $showingSaveConfirmation) {
                Button("OK") { }
            } message: {
                Text("Your settings have been saved successfully!")
            }
        }
    }
    
    private func saveSettings() {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        showingSaveConfirmation = true
    }
    
    private func resetAllData() {
        waterData.resetAllData()
        presentationMode.wrappedValue.dismiss()
    }
}

// Daily Goal Section
struct DailyGoalSection: View {
    @ObservedObject var waterData: WaterDataManager
    @State private var customGoal: String = ""
    @State private var showingCustomInput = false
    
    private let presetGoals = [1500, 2000, 2500, 3000, 3500, 4000]
    
    var body: some View {
        VStack(spacing: 16) {
            // Current goal display
            HStack {
                Text("Current Goal:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(formatAmount(waterData.settings.dailyGoal))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
            
            // Preset goals
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(presetGoals, id: \.self) { goal in
                    Button(action: {
                        waterData.settings.dailyGoal = goal
                    }) {
                        VStack(spacing: 4) {
                            Text(formatAmount(goal))
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text("ml")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            waterData.settings.dailyGoal == goal ? 
                            Color.blue : Color.gray.opacity(0.1)
                        )
                        .foregroundColor(
                            waterData.settings.dailyGoal == goal ? 
                            .white : .primary
                        )
                        .cornerRadius(8)
                    }
                }
            }
            
            // Custom goal input
            Button(action: {
                showingCustomInput = true
                customGoal = String(waterData.settings.dailyGoal)
            }) {
                HStack {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                    
                    Text("Custom Goal")
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
        }
        .sheet(isPresented: $showingCustomInput) {
            CustomGoalInputView(
                currentGoal: waterData.settings.dailyGoal,
                onSave: { newGoal in
                    waterData.settings.dailyGoal = newGoal
                }
            )
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

// Custom Goal Input View
struct CustomGoalInputView: View {
    let currentGoal: Int
    let onSave: (Int) -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var inputText: String = ""
    @State private var selectedUnit: Unit = .ml
    
    enum Unit: String, CaseIterable {
        case ml = "ml"
        case liters = "L"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Enter Custom Goal")
                        .font(.headline)
                    
                    Text("Set your daily water intake target")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    TextField("Amount", text: $inputText)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: .infinity)
                    
                    Picker("Unit", selection: $selectedUnit) {
                        ForEach(Unit.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 100)
                }
                
                // Preview
                if let amount = Int(inputText), amount > 0 {
                    VStack(spacing: 8) {
                        Text("Preview")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(formatAmount(amount, unit: selectedUnit))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Custom Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let amount = Int(inputText), amount > 0 {
                            let finalAmount = selectedUnit == .liters ? amount * 1000 : amount
                            onSave(finalAmount)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .disabled(inputText.isEmpty || Int(inputText) == nil || Int(inputText)! <= 0)
                }
            }
        }
        .onAppear {
            inputText = selectedUnit == .liters ? 
                String(currentGoal / 1000) : 
                String(currentGoal)
        }
    }
    
    private func formatAmount(_ amount: Int, unit: Unit) -> String {
        if unit == .liters {
            return String(format: "%.1fL", Double(amount))
        } else {
            return "\(amount)ml"
        }
    }
}

// Sip Size Section
struct SipSizeSection: View {
    @ObservedObject var waterData: WaterDataManager
    
    private let sipSizes = [25, 50, 75, 100, 125, 150]
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Current Sip Size:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(waterData.settings.sipSize)ml")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.green.opacity(0.1))
            .cornerRadius(8)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(sipSizes, id: \.self) { size in
                    Button(action: {
                        waterData.settings.sipSize = size
                    }) {
                        VStack(spacing: 4) {
                            Text("\(size)ml")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text("Sip")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            waterData.settings.sipSize == size ? 
                            Color.green : Color.gray.opacity(0.1)
                        )
                        .foregroundColor(
                            waterData.settings.sipSize == size ? 
                            .white : .primary
                        )
                        .cornerRadius(8)
                    }
                }
            }
        }
    }
}

// Bottle Sizes Section
struct BottleSizesSection: View {
    @ObservedObject var waterData: WaterDataManager
    @State private var showingCustomBottle = false
    
    private let presetBottles = [250, 500, 750, 1000, 1500, 2000]
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Default Bottle:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(formatAmount(waterData.settings.bottleSize))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(8)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(presetBottles, id: \.self) { size in
                    Button(action: {
                        waterData.settings.bottleSize = size
                    }) {
                        VStack(spacing: 4) {
                            Text(formatAmount(size))
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text("Bottle")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            waterData.settings.bottleSize == size ? 
                            Color.orange : Color.gray.opacity(0.1)
                        )
                        .foregroundColor(
                            waterData.settings.bottleSize == size ? 
                            .white : .primary
                        )
                        .cornerRadius(8)
                    }
                }
            }
            
            Button(action: {
                showingCustomBottle = true
            }) {
                HStack {
                    Image(systemName: "plus")
                        .foregroundColor(.orange)
                    
                    Text("Add Custom Bottle")
                        .foregroundColor(.orange)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
        }
        .sheet(isPresented: $showingCustomBottle) {
            CustomBottleInputView(
                currentBottle: waterData.settings.bottleSize,
                onSave: { newBottle in
                    waterData.settings.bottleSize = newBottle
                }
            )
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

// Custom Bottle Input View
struct CustomBottleInputView: View {
    let currentBottle: Int
    let onSave: (Int) -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var inputText: String = ""
    @State private var selectedUnit: Unit = .ml
    
    enum Unit: String, CaseIterable {
        case ml = "ml"
        case liters = "L"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Enter Bottle Size")
                        .font(.headline)
                    
                    Text("Set your default bottle size for quick logging")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    TextField("Amount", text: $inputText)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: .infinity)
                    
                    Picker("Unit", selection: $selectedUnit) {
                        ForEach(Unit.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 100)
                }
                
                // Preview
                if let amount = Int(inputText), amount > 0 {
                    VStack(spacing: 8) {
                        Text("Preview")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(formatAmount(amount, unit: selectedUnit))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Custom Bottle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let amount = Int(inputText), amount > 0 {
                            let finalAmount = selectedUnit == .liters ? amount * 1000 : amount
                            onSave(finalAmount)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .disabled(inputText.isEmpty || Int(inputText) == nil || Int(inputText)! <= 0)
                }
            }
        }
        .onAppear {
            inputText = selectedUnit == .liters ? 
                String(currentBottle / 1000) : 
                String(currentBottle)
        }
    }
    
    private func formatAmount(_ amount: Int, unit: Unit) -> String {
        if unit == .liters {
            return String(format: "%.1fL", Double(amount))
        } else {
            return "\(amount)ml"
        }
    }
}

// Quick Actions Section
struct QuickActionsSection: View {
    @ObservedObject var waterData: WaterDataManager
    @Binding var showingResetAlert: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: {
                showingResetAlert = true
            }) {
                HStack {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                    
                    Text("Reset All Data")
                        .foregroundColor(.red)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
            
            Button(action: {
                waterData.resetToDefaults()
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.blue)
                    
                    Text("Reset to Defaults")
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
        }
    }
}

// App Info Section
struct AppInfoSection: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Version")
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("1.0.0")
                    .fontWeight(.medium)
            }
            
            HStack {
                Text("Build")
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("B-005")
                    .fontWeight(.medium)
            }
            
            HStack {
                Text("Developer")
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Praveen Kumar")
                    .fontWeight(.medium)
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(WaterDataManager())
}
