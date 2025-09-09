//
//  OnboardingView.swift
//  Aqua-Minder
//
//  Created by Praveen Kumar on 09/09/2025.
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var waterData: WaterDataManager
    @State private var currentStep = 0
    @State private var selectedGoal = 2500
    @State private var selectedSipSize = 50
    @State private var selectedBottleSize = 750
    @State private var showingCustomGoal = false
    @State private var showingCustomBottle = false
    
    private let totalSteps = 5
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.cyan.opacity(0.05)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress indicator
                ProgressIndicator(currentStep: currentStep, totalSteps: totalSteps)
                    .padding(.top, 20)
                
                // Main content
                TabView(selection: $currentStep) {
                    // Step 1: Welcome
                    WelcomeStep()
                        .tag(0)
                    
                    // Step 2: Daily Goal
                    GoalSetupStep(
                        selectedGoal: $selectedGoal,
                        showingCustomGoal: $showingCustomGoal
                    )
                    .tag(1)
                    
                    // Step 3: Sip Size
                    SipSetupStep(selectedSipSize: $selectedSipSize)
                        .tag(2)
                    
                    // Step 4: Bottle Size
                    BottleSetupStep(
                        selectedBottleSize: $selectedBottleSize,
                        showingCustomBottle: $showingCustomBottle
                    )
                    .tag(3)
                    
                    // Step 5: Completion
                    CompletionStep()
                        .tag(4)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)
                
                // Navigation buttons
                NavigationButtons(
                    currentStep: $currentStep,
                    totalSteps: totalSteps,
                    onComplete: completeOnboarding
                )
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showingCustomGoal) {
            CustomGoalSheet(
                currentGoal: selectedGoal,
                onSave: { newGoal in
                    selectedGoal = newGoal
                    showingCustomGoal = false
                }
            )
        }
        .sheet(isPresented: $showingCustomBottle) {
            CustomBottleSheet(
                currentBottle: selectedBottleSize,
                onSave: { newBottle in
                    selectedBottleSize = newBottle
                    showingCustomBottle = false
                }
            )
        }
    }
    
    private func completeOnboarding() {
        // Set the user's preferences
        waterData.settings.dailyGoal = selectedGoal
        waterData.settings.sipSize = selectedSipSize
        waterData.settings.bottleSize = selectedBottleSize
        
        // Mark onboarding as completed
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        // Send notification to update the app state
        NotificationCenter.default.post(name: NSNotification.Name("OnboardingCompleted"), object: nil)
    }
}

// Progress Indicator
struct ProgressIndicator: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { step in
                Circle()
                    .fill(step <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
        .padding(.horizontal)
    }
}

// Welcome Step
struct WelcomeStep: View {
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // App icon and title
            VStack(spacing: 20) {
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
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 12) {
                    Text("Welcome to Aqua Minder")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text("Your personal hydration companion")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            // Features list
            VStack(spacing: 16) {
                FeatureRow(icon: "drop.fill", title: "Quick Logging", description: "Log water with just one tap")
                FeatureRow(icon: "chart.pie.fill", title: "Progress Tracking", description: "See your daily hydration progress")
                FeatureRow(icon: "bell.fill", title: "Smart Reminders", description: "Never forget to stay hydrated")
                FeatureRow(icon: "chart.bar.fill", title: "History & Insights", description: "Track your hydration patterns")
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

// Feature Row Component
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// Goal Setup Step
struct GoalSetupStep: View {
    @Binding var selectedGoal: Int
    @Binding var showingCustomGoal: Bool
    
    private let presetGoals = [1500, 2000, 2500, 3000, 3500, 4000]
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Header
            VStack(spacing: 16) {
                Image(systemName: "target")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                VStack(spacing: 8) {
                    Text("Set Your Daily Goal")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("How much water do you want to drink each day?")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            // Current selection display
            VStack(spacing: 8) {
                Text("Your Goal")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(formatAmount(selectedGoal))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(16)
            
            // Preset goals
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(presetGoals, id: \.self) { goal in
                    Button(action: {
                        selectedGoal = goal
                    }) {
                        VStack(spacing: 4) {
                            Text(formatAmount(goal))
                                .font(.headline)
                                .fontWeight(.medium)
                            
                            Text("ml")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            selectedGoal == goal ? 
                            Color.blue : Color.gray.opacity(0.1)
                        )
                        .foregroundColor(
                            selectedGoal == goal ? 
                            .white : .primary
                        )
                        .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            // Custom goal button
            Button(action: {
                showingCustomGoal = true
            }) {
                HStack {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                    
                    Text("Custom Goal")
                        .foregroundColor(.blue)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            
            Spacer()
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

// Sip Setup Step
struct SipSetupStep: View {
    @Binding var selectedSipSize: Int
    
    private let sipSizes = [25, 50, 75, 100, 125, 150]
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Header
            VStack(spacing: 16) {
                Image(systemName: "drop.circle")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                VStack(spacing: 8) {
                    Text("Choose Your Sip Size")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("How much water is one sip for you?")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            // Current selection display
            VStack(spacing: 8) {
                Text("Sip Size")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("\(selectedSipSize)ml")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(16)
            
            // Sip size options
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(sipSizes, id: \.self) { size in
                    Button(action: {
                        selectedSipSize = size
                    }) {
                        VStack(spacing: 4) {
                            Text("\(size)ml")
                                .font(.headline)
                                .fontWeight(.medium)
                            
                            Text("Sip")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            selectedSipSize == size ? 
                            Color.green : Color.gray.opacity(0.1)
                        )
                        .foregroundColor(
                            selectedSipSize == size ? 
                            .white : .primary
                        )
                        .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            // Description
            Text("This is the amount logged when you tap the water button once")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

// Bottle Setup Step
struct BottleSetupStep: View {
    @Binding var selectedBottleSize: Int
    @Binding var showingCustomBottle: Bool
    
    private let presetBottles = [250, 500, 750, 1000, 1500, 2000]
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Header
            VStack(spacing: 16) {
                Image(systemName: "waterbottle")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                
                VStack(spacing: 8) {
                    Text("Set Your Bottle Size")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("What's your typical bottle size?")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            // Current selection display
            VStack(spacing: 8) {
                Text("Bottle Size")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(formatAmount(selectedBottleSize))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.orange)
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(16)
            
            // Preset bottles
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(presetBottles, id: \.self) { size in
                    Button(action: {
                        selectedBottleSize = size
                    }) {
                        VStack(spacing: 4) {
                            Text(formatAmount(size))
                                .font(.headline)
                                .fontWeight(.medium)
                            
                            Text("Bottle")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            selectedBottleSize == size ? 
                            Color.orange : Color.gray.opacity(0.1)
                        )
                        .foregroundColor(
                            selectedBottleSize == size ? 
                            .white : .primary
                        )
                        .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            // Custom bottle button
            Button(action: {
                showingCustomBottle = true
            }) {
                HStack {
                    Image(systemName: "plus")
                        .foregroundColor(.orange)
                    
                    Text("Custom Bottle")
                        .foregroundColor(.orange)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            
            Spacer()
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

// Completion Step
struct CompletionStep: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Success animation
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.green, Color.mint]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 12) {
                    Text("You're All Set!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Aqua Minder is ready to help you stay hydrated")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            // Quick tips
            VStack(spacing: 16) {
                Text("Quick Tips")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                VStack(spacing: 12) {
                    TipRow(icon: "hand.tap.fill", text: "Tap the water button to log a sip")
                    TipRow(icon: "hand.raised.fill", text: "Hold for bottle options")
                    TipRow(icon: "chart.pie.fill", text: "Tap the progress ring to view history")
                    TipRow(icon: "gearshape.fill", text: "Tap settings to customize anytime")
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// Tip Row Component
struct TipRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

// Navigation Buttons
struct NavigationButtons: View {
    @Binding var currentStep: Int
    let totalSteps: Int
    let onComplete: () -> Void
    
    var body: some View {
        HStack {
            if currentStep > 0 {
                Button("Back") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep -= 1
                    }
                }
                .font(.headline)
                .foregroundColor(.blue)
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(25)
            }
            
            Spacer()
            
            Button(currentStep == totalSteps - 1 ? "Get Started" : "Next") {
                if currentStep == totalSteps - 1 {
                    onComplete()
                } else {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep += 1
                    }
                }
            }
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 30)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.cyan]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(25)
        }
        .padding(.horizontal, 40)
    }
}

// Custom Goal Sheet
struct CustomGoalSheet: View {
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

// Custom Bottle Sheet
struct CustomBottleSheet: View {
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

#Preview {
    OnboardingView(waterData: WaterDataManager())
}
