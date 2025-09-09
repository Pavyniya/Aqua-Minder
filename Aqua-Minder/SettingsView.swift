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
                
                // Reminders Section
                Section {
                    RemindersSection()
                } header: {
                    Text("Reminders")
                } footer: {
                    Text("Get gentle reminders to stay hydrated throughout the day.")
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

// Reminders Section
struct RemindersSection: View {
    @EnvironmentObject var waterData: WaterDataManager
    @State private var showingPermissionAlert = false
    @State private var showingAddReminder = false
    @State private var showingTestAlert = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Permission Status
            PermissionStatusView()
            
            // Reminder Toggle
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Enable Reminders")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(waterData.reminderManager.hasPermission ? 
                         "Get notified to drink water" : 
                         "Enable notifications to get reminders")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { waterData.reminderManager.settings.isEnabled && waterData.reminderManager.hasPermission },
                    set: { newValue in
                        if newValue && !waterData.reminderManager.hasPermission {
                            showingPermissionAlert = true
                        } else {
                            waterData.reminderManager.settings.isEnabled = newValue
                            waterData.updateReminderSettings(waterData.reminderManager.settings)
                        }
                    }
                ))
                .disabled(!waterData.reminderManager.hasPermission)
            }
            .padding(.vertical, 8)
            
            if waterData.reminderManager.hasPermission && waterData.reminderManager.settings.isEnabled {
                // Reminder Times
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Reminder Times")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button("Add") {
                            showingAddReminder = true
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                    
                    ForEach(Array(waterData.reminderManager.settings.reminderTimes.enumerated()), id: \.element.id) { index, reminder in
                        ReminderTimeRow(
                            reminder: reminder,
                            index: index
                        )
                    }
                }
                
                // Reminder Frequency
                VStack(alignment: .leading, spacing: 8) {
                    Text("Frequency")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Picker("Frequency", selection: Binding(
                        get: { waterData.reminderManager.settings.reminderFrequency },
                        set: { newValue in
                            waterData.reminderManager.settings.reminderFrequency = newValue
                            waterData.updateReminderSettings(waterData.reminderManager.settings)
                        }
                    )) {
                        ForEach(ReminderFrequency.allCases, id: \.self) { frequency in
                            Text(frequency.displayName).tag(frequency)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Custom Message
                VStack(alignment: .leading, spacing: 8) {
                    Text("Reminder Message")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Enter custom message", text: Binding(
                        get: { waterData.reminderManager.settings.reminderMessage },
                        set: { newValue in
                            waterData.reminderManager.settings.reminderMessage = newValue
                            waterData.updateReminderSettings(waterData.reminderManager.settings)
                        }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Test Reminder Button
                Button(action: {
                    waterData.reminderManager.scheduleTestReminder()
                    showingTestAlert = true
                }) {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.blue)
                        
                        Text("Send Test Reminder")
                            .foregroundColor(.blue)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .alert("Notification Permission Required", isPresented: $showingPermissionAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Enable Notifications") {
                Task {
                    await waterData.reminderManager.requestNotificationPermission()
                    if waterData.reminderManager.hasPermission {
                        waterData.reminderManager.settings.isEnabled = true
                        waterData.updateReminderSettings(waterData.reminderManager.settings)
                    }
                }
            }
        } message: {
            Text("Aqua Minder needs notification permission to send you water reminders. You can enable this in Settings > Notifications.")
        }
        .alert("Test Reminder Sent", isPresented: $showingTestAlert) {
            Button("OK") { }
        } message: {
            Text("A test reminder will arrive in 5 seconds!")
        }
        .sheet(isPresented: $showingAddReminder) {
            AddReminderTimeView()
        }
    }
}

// Permission Status View
struct PermissionStatusView: View {
    @EnvironmentObject var waterData: WaterDataManager
    
    var body: some View {
        HStack {
            Image(systemName: waterData.reminderManager.hasPermission ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundColor(waterData.reminderManager.hasPermission ? .green : .orange)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(waterData.reminderManager.hasPermission ? "Notifications Enabled" : "Notifications Disabled")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(waterData.reminderManager.hasPermission ? 
                     "You'll receive water reminders" : 
                     "Enable in Settings to get reminders")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if !waterData.reminderManager.hasPermission {
                Button("Enable") {
                    Task {
                        await waterData.reminderManager.requestNotificationPermission()
                    }
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(waterData.reminderManager.hasPermission ? 
                   Color.green.opacity(0.1) : 
                   Color.orange.opacity(0.1))
        .cornerRadius(8)
    }
}

// Reminder Time Row
struct ReminderTimeRow: View {
    let reminder: ReminderTime
    let index: Int
    @EnvironmentObject var waterData: WaterDataManager
    @State private var showingEditTime = false
    
    var body: some View {
        HStack {
            Button(action: {
                waterData.reminderManager.toggleReminderTime(at: index)
            }) {
                Image(systemName: reminder.isEnabled ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(reminder.isEnabled ? .green : .gray)
            }
            
            Text(reminder.timeString)
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: {
                showingEditTime = true
            }) {
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
            }
            
            Button(action: {
                waterData.reminderManager.removeReminderTime(at: index)
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showingEditTime) {
            EditReminderTimeView(index: index)
        }
    }
}

// Add Reminder Time View
struct AddReminderTimeView: View {
    @EnvironmentObject var waterData: WaterDataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedHour = 9
    @State private var selectedMinute = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Add Reminder Time")
                        .font(.headline)
                    
                    Text("Choose when you want to be reminded to drink water")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 16) {
                    HStack {
                        Text("Time")
                            .font(.headline)
                        
                        Spacer()
                        
                        Picker("Hour", selection: $selectedHour) {
                            ForEach(0..<24, id: \.self) { hour in
                                Text(String(format: "%02d", hour)).tag(hour)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 80)
                        
                        Text(":")
                            .font(.title)
                        
                        Picker("Minute", selection: $selectedMinute) {
                            ForEach(0..<60, id: \.self) { minute in
                                Text(String(format: "%02d", minute)).tag(minute)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 80)
                    }
                    
                    // Preview
                    VStack(spacing: 8) {
                        Text("Preview")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(formatTime(hour: selectedHour, minute: selectedMinute))
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
            .navigationTitle("Add Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        waterData.reminderManager.addReminderTime(hour: selectedHour, minute: selectedMinute)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func formatTime(hour: Int, minute: Int) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let date = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
        return formatter.string(from: date)
    }
}

// Edit Reminder Time View
struct EditReminderTimeView: View {
    @EnvironmentObject var waterData: WaterDataManager
    @Environment(\.presentationMode) var presentationMode
    let index: Int
    @State private var selectedHour: Int
    @State private var selectedMinute: Int
    
    init(index: Int) {
        self.index = index
        // We'll get the reminder data from the environment object
        self._selectedHour = State(initialValue: 9)
        self._selectedMinute = State(initialValue: 0)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Edit Reminder Time")
                        .font(.headline)
                    
                    Text("Update the reminder time")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 16) {
                    HStack {
                        Text("Time")
                            .font(.headline)
                        
                        Spacer()
                        
                        Picker("Hour", selection: $selectedHour) {
                            ForEach(0..<24, id: \.self) { hour in
                                Text(String(format: "%02d", hour)).tag(hour)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 80)
                        
                        Text(":")
                            .font(.title)
                        
                        Picker("Minute", selection: $selectedMinute) {
                            ForEach(0..<60, id: \.self) { minute in
                                Text(String(format: "%02d", minute)).tag(minute)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 80)
                    }
                    
                    // Preview
                    VStack(spacing: 8) {
                        Text("Preview")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(formatTime(hour: selectedHour, minute: selectedMinute))
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
            .navigationTitle("Edit Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if index < waterData.reminderManager.settings.reminderTimes.count {
                    let reminder = waterData.reminderManager.settings.reminderTimes[index]
                    selectedHour = reminder.hour
                    selectedMinute = reminder.minute
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        waterData.reminderManager.updateReminderTime(at: index, hour: selectedHour, minute: selectedMinute)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func formatTime(hour: Int, minute: Int) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let date = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
        return formatter.string(from: date)
    }
}

#Preview {
    SettingsView()
        .environmentObject(WaterDataManager())
}
